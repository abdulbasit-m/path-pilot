import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../profile/profile_provider.dart';
import '../career/career_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch fresh data when the home screen loads
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      Provider.of<CareerProvider>(context, listen: false).fetchCareers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final careerProvider = Provider.of<CareerProvider>(context);

    // Extract user details using proper Dart object dot notation
    final isAdmin = profileProvider.profile?.role == 'admin';
    final fullName = profileProvider.profile?.fullName; 
    
    final firstName = fullName != null && fullName.isNotEmpty 
        ? fullName.split(' ').first 
        : 'Explorer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Path Pilot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileProvider.fetchProfile();
          await careerProvider.fetchCareers();
        },
        color: const Color(0xFF0D9488),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personalized Greeting
              Text(
                'Welcome back,',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '$firstName!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 32),

              // 2. Main Call-to-Action Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.explore_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Find Your Next Path',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore curated learning roadmaps designed to take you from beginner to professional.',
                      style: TextStyle(color: Colors.grey.shade300, height: 1.5, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/career_explorer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Explore Careers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Dynamic Admin Portal
              if (isAdmin) ...[
                const Text(
                  'Admin Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade200, width: 2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/admin'),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.red, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                SizedBox(height: 4),
                                Text('Manage platform content', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 4. Horizontal Featured Careers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Fields',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  TextButton(
                    onPressed: () => context.push('/career_explorer'),
                    child: const Text('View All', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (careerProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
              else if (careerProvider.careers.isEmpty)
                Text('No careers available yet.', style: TextStyle(color: Colors.grey.shade600))
              else
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: careerProvider.careers.length > 5 ? 5 : careerProvider.careers.length,
                    itemBuilder: (context, index) {
                      final career = careerProvider.careers[index];
                      
                      IconData getIcon(String name) {
                        switch (name.toLowerCase()) {
                          case 'cloud': return Icons.cloud_outlined;
                          case 'security': return Icons.security_outlined;
                          case 'code': return Icons.code_outlined;
                          default: return Icons.work_outline_rounded;
                        }
                      }

                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(getIcon(career.iconName), color: const Color(0xFF0F172A), size: 28),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  career.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}