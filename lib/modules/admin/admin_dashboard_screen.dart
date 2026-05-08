import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAdminCard(
            context,
            title: 'Manage Careers',
            subtitle: 'Add, edit, or remove career fields',
            icon: Icons.work_outline_rounded,
            route: '/admin/careers',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Manage Roadmaps',
            subtitle: 'Create learning paths and assign fields',
            icon: Icons.map_outlined,
            route: '/admin/roadmaps',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Manage Steps',
            subtitle: 'Add specific milestones to roadmaps',
            icon: Icons.checklist_rtl_outlined,
            route: '/admin/steps',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Manage Resources',
            subtitle: 'Curate links, courses, and videos for steps',
            icon: Icons.library_books_outlined,
            route: '/admin/resources',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required String route}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFDC2626)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        onTap: () {
          if (route == '/admin/resources') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Module coming next!')),
            );
          } else {
            context.push(route);
          }
        },
      ),
    );
  }
}