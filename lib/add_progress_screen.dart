import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProgressScreen extends StatefulWidget {
  final String traineeId;

  AddProgressScreen({required this.traineeId});

  @override
  _AddProgressScreenState createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends State<AddProgressScreen> {
  final _noteController = TextEditingController();
  final _weightController = TextEditingController();
  final _fatController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('progressLogs').add({
        'traineeId': widget.traineeId,
        'trainerId': FirebaseAuth.instance.currentUser!.uid,
        'note': _noteController.text.trim(),
        'weight': double.tryParse(_weightController.text.trim()) ?? 0,
        'fatPercent': double.tryParse(_fatController.text.trim()) ?? 0,
        'date': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Progress")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: "Progress Note"),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fatController,
              decoration: InputDecoration(labelText: "Fat %"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: Text("Save Progress"),
            ),
          ],
        ),
      ),
    );
  }
}
