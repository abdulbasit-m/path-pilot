import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../career/career_provider.dart';
import '../career/career_model.dart';
import '../roadmap/roadmap_provider.dart';

class AdminRoadmapsScreen extends StatefulWidget {
  const AdminRoadmapsScreen({super.key});

  @override
  State<AdminRoadmapsScreen> createState() => _AdminRoadmapsScreenState();
}

class _AdminRoadmapsScreenState extends State<AdminRoadmapsScreen> {
  Career? _selectedCareer;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _difficultyController = TextEditingController(text: 'beginner');
  final _hoursController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
      Provider.of<RoadmapProvider>(context, listen: false).roadmaps.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _difficultyController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _onCareerSelected(Career? career) {
    setState(() {
      _selectedCareer = career;
    });
    if (career != null) {
      Provider.of<RoadmapProvider>(context, listen: false).fetchRoadmaps(career.id);
    }
  }

  void _showAddRoadmapSheet() {
    if (_selectedCareer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a career field first.')),
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
              'Add New Roadmap',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Roadmap Title (e.g., AWS Fundamentals)'),
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
                    controller: _difficultyController,
                    decoration: const InputDecoration(labelText: 'Difficulty (beginner/intermediate/advanced)'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    decoration: const InputDecoration(labelText: 'Est. Hours (e.g., 10)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;

                final provider = Provider.of<RoadmapProvider>(context, listen: false);
                final hours = int.tryParse(_hoursController.text) ?? 0;

                final success = await provider.addRoadmap(
                  _selectedCareer!.id,
                  _titleController.text.trim(),
                  _descController.text.trim(),
                  _difficultyController.text.trim().toLowerCase(),
                  hours,
                );

                if (success && mounted) {
                  _titleController.clear();
                  _descController.clear();
                  _hoursController.text = '10';
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Roadmap added successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Roadmaps', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoadmapSheet,
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Roadmap'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: DropdownButtonFormField<Career>(
              value: _selectedCareer,
              decoration: const InputDecoration(
                labelText: '1. Select a Career Field first',
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
          ),
          Expanded(
            child: _selectedCareer == null
                ? const Center(child: Text('Select a career to view its roadmaps', style: TextStyle(color: Colors.grey)))
                : roadmapProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
                    : roadmapProvider.roadmaps.isEmpty
                        ? const Center(child: Text('No roadmaps found for this career.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: roadmapProvider.roadmaps.length,
                            itemBuilder: (context, index) {
                              final roadmap = roadmapProvider.roadmaps[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(roadmap.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${roadmap.difficultyLevel.toUpperCase()} • ${roadmap.estimatedHours} hrs'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => roadmapProvider.deleteRoadmap(roadmap.id, _selectedCareer!.id),
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