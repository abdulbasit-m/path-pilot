import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'career_provider.dart';

class CareerExplorerScreen extends StatefulWidget {
  const CareerExplorerScreen({super.key});

  @override
  State<CareerExplorerScreen> createState() => _CareerExplorerScreenState();
}

class _CareerExplorerScreenState extends State<CareerExplorerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
    });
  }

  Color _parseColor(String hexCode) {
    String hex = hexCode.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  IconData _getIconForName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'cloud':
        return Icons.cloud_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'smartphone':
        return Icons.smartphone_outlined;
      case 'code':
        return Icons.code_outlined;
      case 'palette':
        return Icons.palette_outlined;
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CareerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Explore Careers',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : provider.errorMessage != null
              ? Center(child: Text('Error: ${provider.errorMessage}'))
              : _buildGrid(provider),
    );
  }

  Widget _buildGrid(CareerProvider provider) {
    if (provider.careers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off_outlined, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No careers available yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.careers.length,
      itemBuilder: (context, index) {
        final career = provider.careers[index];
        final color = _parseColor(career.hexColor); // The exact fix

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push('/roadmaps', extra: {
                'id': career.id,
                'title': career.title,
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForName(career.iconName),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    career.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    career.description ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
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