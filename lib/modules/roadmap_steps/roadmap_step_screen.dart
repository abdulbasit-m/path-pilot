import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'roadmap_step_provider.dart';
import '../progress/progress_provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoadmapStepProvider>(context, listen: false)
          .fetchSteps(widget.roadmapId);
      Provider.of<ProgressProvider>(context, listen: false)
          .fetchProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = Provider.of<RoadmapStepProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    // Calculate overall progress
    final totalSteps = stepProvider.steps.length;
    final completedSteps = stepProvider.steps.where((s) => progressProvider.isStepCompleted(s.id)).length;
    final progressPercentage = totalSteps == 0 ? 0.0 : completedSteps / totalSteps;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.roadmapTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
            minHeight: 6.0,
          ),
        ),
      ),
      body: stepProvider.isLoading || progressProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : stepProvider.errorMessage != null
              ? Center(child: Text('Error: ${stepProvider.errorMessage}'))
              : _buildList(stepProvider, progressProvider),
    );
  }

  Widget _buildList(RoadmapStepProvider stepProvider, ProgressProvider progressProvider) {
    if (stepProvider.steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.format_list_numbered_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No steps available yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: stepProvider.steps.length,
      itemBuilder: (context, index) {
        final step = stepProvider.steps[index];
        final isCompleted = progressProvider.isStepCompleted(step.id);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: isCompleted ? const Color(0xFFF0FDFA) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isCompleted ? const Color(0xFF5EEAD4) : Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push('/resources', extra: {
                'stepId': step.id,
                'stepTitle': step.title,
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => progressProvider.toggleStepCompletion(step.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF0D9488) : Colors.white,
                        border: Border.all(
                          color: isCompleted ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                            : Text(
                                '${step.stepOrder}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? const Color(0xFF0F172A).withOpacity(0.5) : const Color(0xFF0F172A),
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (step.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            step.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}