import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'resource_screen.dart'; // Make sure this points to your ResourceScreen file

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
    
    // Configure the graph layout (Top to Bottom, like roadmap.sh)
    builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = (30)
      ..levelSeparation = (50)
      ..subtreeSeparation = (30)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
      
    _fetchAndBuildGraph();
  }

  Future<void> _fetchAndBuildGraph() async {
    try {
      // 1. Fetch steps strictly for this roadmap, ordered by step_order
      final response = await Supabase.instance.client
          .from('roadmap_steps')
          .select('*')
          .eq('roadmap_id', widget.roadmapId)
          .order('step_order', ascending: true);

      _steps = response as List;

      // 2. Build the graph nodes and connecting lines
      if (_steps.isNotEmpty) {
        List<Node> nodes = [];
        
        // Create a node for every step
        for (var step in _steps) {
          nodes.add(Node.Id(step));
        }

        // Draw connecting edges from Step 1 -> Step 2 -> Step 3
        for (int i = 0; i < nodes.length - 1; i++) {
          graph.addEdge(nodes[i], nodes[i + 1]);
        }
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.5,
                      maxScale: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
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

  // This is the physical UI of the boxes on the graph
  Widget _buildNodeWidget(Map<String, dynamic> stepData) {
    return InkWell(
      onTap: () {
        // Navigates to your existing ResourceScreen when a box is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceScreen(
              stepId: stepData['id'].toString(),
              stepTitle: stepData['title'].toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stepData['title'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            if (stepData['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                stepData['description'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}