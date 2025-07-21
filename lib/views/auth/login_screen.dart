import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/role_router.dart';
import 'register_screen.dart';
import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _passwordVisible = false;
  String _error = "";

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final identifier = _identifierController.text.trim();
      String? emailToLogin;

      if (identifier.contains('@')) {
        emailToLogin = identifier;
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: identifier)
            .get();

        if (querySnapshot.docs.isEmpty) {
          setState(() => _error = "No user found with this phone number");
          return;
        } else {
          emailToLogin = querySnapshot.docs.first.data()['email'];
        }
      }

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailToLogin!,
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleRouter(uid: userCredential.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit App"),
            content: Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Exit"),
              ),
            ],
          ),
        );
        return shouldExit;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 40),
                  Text("Welcome Back",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800)),
                  SizedBox(height: 8),
                  Text("Sign in to continue your fitness journey",
                      style: TextStyle(color: Colors.grey.shade600)),
                  SizedBox(height: 24),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error, style: TextStyle(color: Colors.red)),
                    ),
                  Text("Email or Phone Number"),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Enter your email or phone",
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (val) =>
                    val!.isEmpty ? "Please enter your email or phone" : null,
                  ),
                  SizedBox(height: 16),
                  Text("Password"),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (val) =>
                    val!.length < 6 ? "Minimum 6 characters required" : null,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  SizedBox(height: 10),
                  _loading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _login,
                    child: Text("Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          children: [
                            TextSpan(
                              text: "Register",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
