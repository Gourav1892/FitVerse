import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitTestimonialScreen extends StatefulWidget {
  @override
  _SubmitTestimonialScreenState createState() => _SubmitTestimonialScreenState();
}

class _SubmitTestimonialScreenState extends State<SubmitTestimonialScreen> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  File? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _messageController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child("testimonials/$uid-$timestamp.jpg");

      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('testimonials').add({
        'userId': uid,
        'name': _nameController.text.trim(),
        'message': _messageController.text.trim(),
        'photoUrl': imageUrl,
        'createdAt': Timestamp.now(),
        'approved': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submitted for approval")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Testimonial")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Your Name"),
              maxLength: 50,
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: "Your Story"),
              maxLines: 5,
              maxLength: 500,
            ),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : Text("No image selected"),
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text("Upload Image"),
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
