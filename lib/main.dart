import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/browse_food_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/my_food_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SOUWApp());
}

class SOUWApp extends StatelessWidget {
  const SOUWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'SOUW',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008F83)),

        scaffoldBackgroundColor: const Color(0xFFF5F9F8),

        appBarTheme: const AppBarTheme(elevation: 0),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(),

          enabledBorder: OutlineInputBorder(),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF008F83), width: 2),
          ),
        ),
      ),

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),

        '/login': (context) => const LoginScreen(),

        '/register': (context) => const RegisterScreen(),

        '/home': (context) => const HomeScreen(),

        '/browse-food': (context) => const BrowseFoodScreen(),

        '/add-food': (context) => const AddFoodScreen(),

        '/my-food': (context) => const MyFoodScreen(),

        '/requests': (context) => const RequestsScreen(),

        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
