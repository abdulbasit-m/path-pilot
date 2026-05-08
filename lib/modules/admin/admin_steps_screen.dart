import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../career/career_provider.dart';
import '../career/career_model.dart';
import '../roadmap/roadmap_provider.dart';
import '../roadmap/roadmap_model.dart';
import '../roadmap_steps/roadmap_step_provider.dart';

class AdminStepsScreen extends StatefulWidget {
  const AdminStepsScreen({super.key});

  @override
  State<AdminStepsScreen> createState() => _AdminStepsScreenState();
}

class _AdminStepsScreenState extends State<AdminStepsScreen> {
  Career? _selectedCareer;
  Roadmap? _selectedRoadmap;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  final _hoursController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
      Provider.of<RoadmapProvider>(context, listen: false).roadmaps.clear();
      Provider.of<RoadmapStepProvider>(context, listen: false).steps.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _orderController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _onCareerSelected(Career? career) {
    setState(() {
      _selectedCareer = career;
      _selectedRoadmap = null; 
    });
    Provider.of<RoadmapStepProvider>(context, listen: false).steps.clear();
    if (career != null) {
      Provider.of<RoadmapProvider>(context, listen: false).fetchRoadmaps(career.id);
    }
  }

  void _onRoadmapSelected(Roadmap? roadmap) {
    setState(() {
      _selectedRoadmap = roadmap;
    });
    if (roadmap != null) {
      Provider.of<RoadmapStepProvider>(context, listen: false).fetchSteps(roadmap.id);
    }
  }

  void _showAddStepSheet() {
    if (_selectedRoadmap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Roadmap first.')),
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
              'Add New Step',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Step Title (e.g., Learn IAM)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderController,
                    decoration: const InputDecoration(labelText: 'Step Order (e.g., 1)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    decoration: const InputDecoration(labelText: 'Est. Hours (e.g., 5)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;

                final provider = Provider.of<RoadmapStepProvider>(context, listen: false);
                final order = int.tryParse(_orderController.text) ?? 1;
                final hours = int.tryParse(_hoursController.text) ?? 5;

                final success = await provider.addStep(
                  _selectedRoadmap!.id,
                  _titleController.text.trim(),
                  _descController.text.trim(),
                  order,
                  hours,
                );

                if (success && mounted) {
                  _titleController.clear();
                  _descController.clear();
                  _orderController.text = (order + 1).toString(); 
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Step added successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Step', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Steps', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStepSheet,
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Step'),
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
                  decoration: const InputDecoration(
                    labelText: '1. Select Career Field',
                    border: OutlineInputBorder(),
                  ),
                  items: careerProvider.careers.map((career) {
                    return DropdownMenuItem(
                      value: career,
                      child: Text(career.title),
                    );
                  }).toList(),
                  onChanged: _onCareerSelected,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Roadmap>(
                  value: _selectedRoadmap,
                  decoration: const InputDecoration(
                    labelText: '2. Select Roadmap',
                    border: OutlineInputBorder(),
                  ),
                  items: roadmapProvider.roadmaps.map((roadmap) {
                    return DropdownMenuItem(
                      value: roadmap,
                      child: Text(roadmap.title),
                    );
                  }).toList(),
                  onChanged: _selectedCareer == null ? null : _onRoadmapSelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedRoadmap == null
                ? const Center(child: Text('Select a roadmap to view its steps', style: TextStyle(color: Colors.grey)))
                : stepProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
                    : stepProvider.steps.isEmpty
                        ? const Center(child: Text('No steps found for this roadmap.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: stepProvider.steps.length,
                            itemBuilder: (context, index) {
                              final step = stepProvider.steps[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF0F172A),
                                    child: Text('${step.stepOrder}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${step.estimatedHours} hours estimated'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => stepProvider.deleteStep(step.id, _selectedRoadmap!.id),
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