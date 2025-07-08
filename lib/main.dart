import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/splash_screen.dart';
import 'package:fitverse/views/auth/login_screen.dart';
import 'package:fitverse/views/user/user_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => UserDashboard(),
      },
    );
  }
}
