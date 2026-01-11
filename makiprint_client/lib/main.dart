import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Ensure these files exist in your lib/ folder or subfolders
import 'firebase_options.dart';
import 'pages/home.dart';
import 'pages/admin_page.dart';
import 'pages/owner_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sets clean URL paths for web deployment
  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MakiPrintApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Public Landing Page (maki-print.vercel.app/)
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    // Admin Portal (maki-print.vercel.app/adminpage)
    GoRoute(
      path: '/adminpage',
      builder: (context, state) => const AdminPage(),
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        // Allows access without email check for initial setup/testing
        return null;
      },
    ),
    // Owner Dashboard (maki-print.vercel.app/ownerpage)
    GoRoute(path: '/ownerpage', builder: (context, state) => const OwnerPage()),
    // Profile Page (maki-print.vercel.app/profile)
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);

class MakiPrintApp extends StatelessWidget {
  const MakiPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MakiPrint',
      routerConfig: _router,
      theme: ThemeData(
        // Setting the header/AppBar color globally to green #a1d39a
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFa1d39a),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFa1d39a),
          primary: const Color(0xFFa1d39a),
        ),
        useMaterial3: true,
      ),
    );
  }
}
