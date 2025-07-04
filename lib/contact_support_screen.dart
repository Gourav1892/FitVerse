import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactSupportScreen extends StatefulWidget {
  @override
  _ContactSupportScreenState createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _messageController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message cannot be empty")),
      );
      return;
    }

    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final email = FirebaseAuth.instance.currentUser!.email ?? '';

    try {
      await FirebaseFirestore.instance.collection('supportMessages').add({
        'userId': uid,
        'email': email,
        'message': _messageController.text.trim(),
        'status': 'open',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Support request submitted")),
      );

      await Future.delayed(Duration(milliseconds: 400));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Support")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Tell us what issue you’re facing:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: "Describe your issue...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}
