import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _bioController = TextEditingController();
  final _expertiseController = TextEditingController();
  bool _loading = false;

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('trainers')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      final data = doc.docs.first.data();
      _bioController.text = data['bio'] ?? '';
      _expertiseController.text = data['expertise'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final query = await FirebaseFirestore.instance
        .collection('trainers')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await FirebaseFirestore.instance
          .collection('trainers')
          .doc(docId)
          .update({
        'bio': _bioController.text.trim(),
        'expertise': _expertiseController.text.trim()
      });
    }
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile updated")));
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _expertiseController,
              decoration: InputDecoration(labelText: "Expertise"),
            ),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: "Bio"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                onPressed: _saveProfile, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
