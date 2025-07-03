import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/role_router.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _error = "";

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error.isNotEmpty)
                Text(_error, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (val) =>
                val!.isEmpty ? "Please enter your email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) =>
                val!.length < 6 ? "Minimum 6 characters required" : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: Text("Don't have an account? Register here"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
