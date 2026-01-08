import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'pages/home.dart';
import 'pages/admin_page.dart';
import 'pages/owner_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MakiPrintApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/adminpage',
      builder: (context, state) => const AdminPage(),
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        // FIX: For testing, I've commented out the email check.
        // Once you have created your CEO account, uncomment and use your email.
        // if (user == null || user.email != "your-email@gmail.com") return '/';
        return null;
      },
    ),
    GoRoute(path: '/ownerpage', builder: (context, state) => const OwnerPage()),
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
        // Setting the header/AppBar color globally to your green #a1d39a
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFa1d39a),
          foregroundColor: Colors.black, // Text color on the green header
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
