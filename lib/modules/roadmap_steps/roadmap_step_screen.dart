import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutterproject/modules/resources/resource_screen.dart';
import 'package:flutterproject/modules/progress/progress_provider.dart';

class RoadmapStepScreen extends StatefulWidget {
  final String roadmapId;
  final String roadmapTitle;

  const RoadmapStepScreen({
    super.key,
    required this.roadmapId,
    required this.roadmapTitle,
  });

  @override
  State<RoadmapStepScreen> createState() => _RoadmapStepScreenState();
}

class _RoadmapStepScreenState extends State<RoadmapStepScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _steps = [];
  
  final Graph graph = Graph()..isTree = true;
  late BuchheimWalkerConfiguration builder;

  @override
  void initState() {
    super.initState();
    
    builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = (40)
      ..levelSeparation = (60)
      ..subtreeSeparation = (40)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
      
    // Fetch roadmap structure and user completion status together
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(context, listen: false).fetchProgress();
      _fetchAndBuildGraph();
    });
  }

  Future<void> _fetchAndBuildGraph() async {
    try {
      final response = await Supabase.instance.client
          .from('roadmap_steps')
          .select('*')
          .eq('roadmap_id', widget.roadmapId)
          .order('step_order', ascending: true);

      _steps = response as List;

      if (_steps.isNotEmpty) {
        Map<String, Node> nodeMap = {};
        
        for (var step in _steps) {
          String currentId = step['id'].toString();
          nodeMap[currentId] = Node.Id(step);
        }

        for (var step in _steps) {
          String currentId = step['id'].toString();
          var parentIdValue = step['parent_step_id'];

          Node currentNode = nodeMap[currentId]!;

          if (parentIdValue != null) {
            String parentId = parentIdValue.toString();
            Node? parentNode = nodeMap[parentId];

            if (parentNode != null) {
              graph.addEdge(parentNode, currentNode);
            }
          } else {
            graph.addNode(currentNode);
          }
        }
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.roadmapTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _steps.isEmpty
                  ? const Center(child: Text('No steps available yet.'))
                  : InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(500),
                      minScale: 0.2,
                      maxScale: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                          paint: Paint()
                            ..color = const Color(0xFF94A3B8)
                            ..strokeWidth = 2
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            var stepData = node.key!.value as Map<String, dynamic>;
                            return _buildNodeWidget(stepData);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildNodeWidget(Map<String, dynamic> stepData) {
    final String currentStepId = stepData['id'].toString();

    // Consume the live completion states from the progress provider
    return Consumer<ProgressProvider>(
      builder: (context, progress, child) {
        final bool isDone = progress.completedStepIds.contains(currentStepId);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResourceScreen(
                  stepId: currentStepId,
                  stepTitle: stepData['title'].toString(),
                ),
              ),
            );
          },
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // If node is checked off, color it emerald green, else keep it crisp white
              color: isDone ? const Color(0xFFE6F4EA) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDone ? const Color(0xFF137333) : const Color(0xFFE2E8F0), 
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Clickable milestone checkbox icon
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isDone ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isDone ? const Color(0xFF137333) : const Color(0xFF64748B),
                        size: 22,
                      ),
                      onPressed: () {
                        progress.toggleStepCompletion(currentStepId);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stepData['title'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDone ? const Color(0xFF137333) : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                if (stepData['description'] != null && stepData['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    stepData['description'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDone ? const Color(0xFF137333).withOpacity(0.8) : const Color(0xFF64748B),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}