import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../career/career_provider.dart';

class AdminCareersScreen extends StatefulWidget {
  const AdminCareersScreen({super.key});

  @override
  State<AdminCareersScreen> createState() => _AdminCareersScreenState();
}

class _AdminCareersScreenState extends State<AdminCareersScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _iconController = TextEditingController(text: 'work');
  final _colorController = TextEditingController(text: '#0D9488');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _showAddCareerSheet() {
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
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Career Field',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Career Title (e.g., Cloud & DevOps)'),
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
                    controller: _iconController,
                    decoration: const InputDecoration(labelText: 'Material Icon Name'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Hex Color (e.g., #DC2626)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;
                
                final provider = Provider.of<CareerProvider>(context, listen: false);
                final success = await provider.addCareer(
                  _titleController.text.trim(),
                  _descController.text.trim(),
                  _iconController.text.trim(),
                  _colorController.text.trim(),
                );

                if (success && mounted) {
                  _titleController.clear();
                  _descController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Career added successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Career', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CareerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Careers', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCareerSheet,
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Career'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: provider.careers.length,
              itemBuilder: (context, index) {
                final career = provider.careers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: ListTile(
                    title: Text(career.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(career.description ?? 'No description', maxLines: 1),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => provider.deleteCareer(career.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}