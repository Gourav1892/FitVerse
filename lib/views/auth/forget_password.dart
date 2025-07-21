import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _userName;
  String? _userId;
  String? _error;

  Future<void> _checkUser() async {
    setState(() {
      _loading = true;
      _error = null;
      _userName = null;
    });

    String input = _controller.text.trim();
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('emailOrPhone', isEqualTo: input)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      setState(() {
        _userName = doc['name'];
        _userId = doc.id;
      });
      // Navigate to OTP screen next
      Navigator.pushNamed(context, '/otp', arguments: {
        'userId': _userId,
        'contact': input,
      });
    } else {
      setState(() {
        _error = "No user found with that email or number.";
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter your email or phone number",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Email or Phone",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            if (_userName != null)
              Text("User found: $_userName",
                  style: TextStyle(color: Colors.green)),
            SizedBox(height: 20),
            _loading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _checkUser,
              child: Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
