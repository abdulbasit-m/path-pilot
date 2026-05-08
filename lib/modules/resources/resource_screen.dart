import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'resource_provider.dart';

class ResourceScreen extends StatefulWidget {
  final String stepId;
  final String stepTitle;

  const ResourceScreen({
    super.key,
    required this.stepId,
    required this.stepTitle,
  });

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResourceProvider>(context, listen: false)
          .fetchResources(widget.stepId);
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'course':
        return Icons.school_rounded;
      case 'article':
      default:
        return Icons.article_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return const Color(0xFFDC2626);
      case 'course':
        return const Color(0xFF0D9488);
      case 'article':
      default:
        return const Color(0xFF2563EB);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.stepTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : provider.errorMessage != null
              ? Center(child: Text('Error: ${provider.errorMessage}'))
              : _buildList(provider),
    );
  }

  Widget _buildList(ResourceProvider provider) {
    if (provider.resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No resources added yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.resources.length,
      itemBuilder: (context, index) {
        final resource = provider.resources[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _launchUrl(resource.url),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getColorForType(resource.resourceType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(resource.resourceType),
                      color: _getColorForType(resource.resourceType),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                resource.resourceType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
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