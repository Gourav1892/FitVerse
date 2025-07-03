import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/role_router.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in → check role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RoleRouter(uid: user.uid)),
        );
      } else {
        // Not logged in → go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your logo asset
            Image.asset("assets/logo.png", height: 120),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
