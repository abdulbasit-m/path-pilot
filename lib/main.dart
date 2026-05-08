import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/constants.dart';
import 'modules/auth/auth_provider.dart';
import 'modules/auth/login_screen.dart';
import 'modules/home/home_screen.dart';
import 'modules/profile/profile_provider.dart';
import 'modules/profile/profile_screen.dart';
import 'modules/career/career_provider.dart';
import 'modules/career/career_explorer_screen.dart';
import 'modules/roadmap/roadmap_provider.dart';
import 'modules/roadmap/roadmap_screen.dart';
import 'modules/roadmap_steps/roadmap_step_provider.dart';
import 'modules/roadmap_steps/roadmap_step_screen.dart';
import 'modules/resources/resource_provider.dart';
import 'modules/resources/resource_screen.dart';
import 'modules/admin/admin_dashboard_screen.dart';
import 'modules/admin/admin_careers_screen.dart';
import 'modules/admin/admin_roadmaps_screen.dart';
import 'modules/admin/admin_steps_screen.dart';
import 'modules/admin/admin_resources_screen.dart';
import 'modules/progress/progress_provider.dart'; // NEW IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  runApp(const PathPilotApp());
}

class PathPilotApp extends StatelessWidget {
  const PathPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CareerProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapStepProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()), // NEW PROVIDER
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          final router = GoRouter(
            initialLocation: '/login',
            refreshListenable: authProvider,
            redirect: (context, state) {
              final isLoggedIn = authProvider.user != null;
              final isGoingToAuth = state.matchedLocation == '/login';
              
              if (!isLoggedIn && !isGoingToAuth) return '/login';
              if (isLoggedIn && isGoingToAuth) return '/home';
              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/career_explorer',
                builder: (context, state) => const CareerExplorerScreen(),
              ),
              GoRoute(
                path: '/roadmaps',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>? ?? {};
                  return RoadmapScreen(
                    careerFieldId: extras['id'] ?? '',
                    careerTitle: extras['title'] ?? 'Roadmaps',
                  );
                },
              ),
              GoRoute(
                path: '/roadmap_steps',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>? ?? {};
                  return RoadmapStepScreen(
                    roadmapId: extras['id'] ?? '',
                    roadmapTitle: extras['title'] ?? 'Steps',
                  );
                },
              ),
              GoRoute(
                path: '/resources',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>? ?? {};
                  return ResourceScreen(
                    stepId: extras['stepId'] ?? '',
                    stepTitle: extras['stepTitle'] ?? 'Resources',
                  );
                },
              ),
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
              GoRoute(
                path: '/admin/careers',
                builder: (context, state) => const AdminCareersScreen(),
              ),
              GoRoute(
                path: '/admin/roadmaps',
                builder: (context, state) => const AdminRoadmapsScreen(),
              ),
              GoRoute(
                path: '/admin/steps',
                builder: (context, state) => const AdminStepsScreen(),
              ),
              GoRoute(
                path: '/admin/resources',
                builder: (context, state) => const AdminResourcesScreen(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Path Pilot',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              primaryColor: const Color(0xFF0F172A),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0F172A),
                primary: const Color(0xFF0F172A),
                secondary: const Color(0xFF0D9488),
              ),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}