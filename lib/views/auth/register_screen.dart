import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/role_router.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedRole = 'trainee';
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final email = _emailController.text.trim().toLowerCase();
    print("🚀 Registering $email as $selectedRole");

    try {
      // ✅ Trainer Approval Check
      if (selectedRole == 'trainer') {
        final doc = await FirebaseFirestore.instance
            .collection('approvedTrainers')
            .doc(email)
            .get();

        if (!doc.exists) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ This email is not approved for trainer registration.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      // ✅ Create Firebase Auth User
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // ✅ Save User Data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'role': selectedRole,
        'createdAt': Timestamp.now(),
      });

      // ✅ Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Registration successful!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ Navigate to RoleRouter
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleRouter(uid: userCredential.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("❗ FirebaseAuthException: ${e.message}");
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Registration failed.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = ['trainer', 'trainee'];

    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                validator: (val) =>
                val!.isEmpty ? "Please enter your email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) => val!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: "Select Role"),
                items: roles
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              SizedBox(height: 30),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _register,
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
