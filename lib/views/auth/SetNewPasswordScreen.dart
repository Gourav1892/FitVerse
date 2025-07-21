import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String phoneOrEmail;

  const SetNewPasswordScreen({required this.phoneOrEmail});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newPasswordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      // Re-authentication is required before password update
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(_newPasswordController.text.trim());
        await FirebaseAuth.instance.signOut(); // Logout after update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Password updated successfully")),
        );
        Navigator.popUntil(context, (route) => route.isFirst); // Go to Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set New Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text("Create New Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Enter a strong password for ${widget.phoneOrEmail}"),
            SizedBox(height: 30),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            SizedBox(height: 30),
            _loading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _resetPassword,
              child: Text("Update Password"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
