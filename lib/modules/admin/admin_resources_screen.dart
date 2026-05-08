import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../career/career_provider.dart';
import '../career/career_model.dart';
import '../roadmap/roadmap_provider.dart';
import '../roadmap/roadmap_model.dart';
import '../roadmap_steps/roadmap_step_provider.dart';
import '../roadmap_steps/roadmap_step_model.dart';
import '../resources/resource_provider.dart';

class AdminResourcesScreen extends StatefulWidget {
  const AdminResourcesScreen({super.key});

  @override
  State<AdminResourcesScreen> createState() => _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends State<AdminResourcesScreen> {
  Career? _selectedCareer;
  Roadmap? _selectedRoadmap;
  RoadmapStep? _selectedStep;

  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _typeController = TextEditingController(text: 'article');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
      Provider.of<RoadmapProvider>(context, listen: false).roadmaps.clear();
      Provider.of<RoadmapStepProvider>(context, listen: false).steps.clear();
      Provider.of<ResourceProvider>(context, listen: false).resources.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _onCareerSelected(Career? career) {
    setState(() {
      _selectedCareer = career;
      _selectedRoadmap = null;
      _selectedStep = null;
    });
    Provider.of<RoadmapStepProvider>(context, listen: false).steps.clear();
    Provider.of<ResourceProvider>(context, listen: false).resources.clear();
    if (career != null) {
      Provider.of<RoadmapProvider>(context, listen: false).fetchRoadmaps(career.id);
    }
  }

  void _onRoadmapSelected(Roadmap? roadmap) {
    setState(() {
      _selectedRoadmap = roadmap;
      _selectedStep = null;
    });
    Provider.of<ResourceProvider>(context, listen: false).resources.clear();
    if (roadmap != null) {
      Provider.of<RoadmapStepProvider>(context, listen: false).fetchSteps(roadmap.id);
    }
  }

  void _onStepSelected(RoadmapStep? step) {
    setState(() {
      _selectedStep = step;
    });
    if (step != null) {
      Provider.of<ResourceProvider>(context, listen: false).fetchResources(step.id);
    }
  }

  void _showAddResourceSheet() {
    if (_selectedStep == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Step first.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Resource',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Resource Title (e.g., Official Docs)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL (https://...)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type (video/article/course)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _urlController.text.isEmpty) return;

                final provider = Provider.of<ResourceProvider>(context, listen: false);

                final success = await provider.addResource(
                  _selectedStep!.id,
                  _titleController.text.trim(),
                  _urlController.text.trim(),
                  _typeController.text.trim().toLowerCase(),
                );

                if (success && mounted) {
                  _titleController.clear();
                  _urlController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resource added successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Resource', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final careerProvider = Provider.of<CareerProvider>(context);
    final roadmapProvider = Provider.of<RoadmapProvider>(context);
    final stepProvider = Provider.of<RoadmapStepProvider>(context);
    final resourceProvider = Provider.of<ResourceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Resources', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddResourceSheet,
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Resource'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                DropdownButtonFormField<Career>(
                  value: _selectedCareer,
                  decoration: const InputDecoration(labelText: '1. Select Career', border: OutlineInputBorder()),
                  items: careerProvider.careers.map((c) => DropdownMenuItem(value: c, child: Text(c.title))).toList(),
                  onChanged: _onCareerSelected,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Roadmap>(
                  value: _selectedRoadmap,
                  decoration: const InputDecoration(labelText: '2. Select Roadmap', border: OutlineInputBorder()),
                  items: roadmapProvider.roadmaps.map((r) => DropdownMenuItem(value: r, child: Text(r.title))).toList(),
                  onChanged: _selectedCareer == null ? null : _onRoadmapSelected,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RoadmapStep>(
                  value: _selectedStep,
                  decoration: const InputDecoration(labelText: '3. Select Step', border: OutlineInputBorder()),
                  items: stepProvider.steps.map((s) => DropdownMenuItem(value: s, child: Text('${s.stepOrder}. ${s.title}'))).toList(),
                  onChanged: _selectedRoadmap == null ? null : _onStepSelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedStep == null
                ? const Center(child: Text('Select a step to view resources', style: TextStyle(color: Colors.grey)))
                : resourceProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
                    : resourceProvider.resources.isEmpty
                        ? const Center(child: Text('No resources found.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: resourceProvider.resources.length,
                            itemBuilder: (context, index) {
                              final resource = resourceProvider.resources[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    resource.resourceType == 'video' ? Icons.play_circle_outline :
                                    resource.resourceType == 'course' ? Icons.school_outlined :
                                    Icons.article_outlined,
                                  ),
                                  title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(resource.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => resourceProvider.deleteResource(resource.id, _selectedStep!.id),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}