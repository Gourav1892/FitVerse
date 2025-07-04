import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBlogScreen extends StatefulWidget {
  @override
  _AddBlogScreenState createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Title and content are required")));
      return;
    }

    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('blogs').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'authorId': uid,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Blog posted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Blog Post")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              maxLength: 100,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: "Image URL (optional)"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: "Content"),
                maxLines: null,
                expands: true,
              ),
            ),
            SizedBox(height: 10),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text("Post")),
          ],
        ),
      ),
    );
  }
}
