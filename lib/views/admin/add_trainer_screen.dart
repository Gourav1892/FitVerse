import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTrainerScreen extends StatefulWidget {
  @override
  _AddTrainerScreenState createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = false;
  String _error = "";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      await FirebaseFirestore.instance.collection('trainers').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'expertise': _expertiseController.text.trim(),
        'bio': _bioController.text.trim(),
        'createdAt': Timestamp.now(),
        'availability': {},
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trainer added successfully")),
      );

      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _expertiseController.clear();
      _bioController.clear();
    } catch (e) {
      setState(() => _error = "Error: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Trainer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error.isNotEmpty)
                Text(_error, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Trainer Name"),
                validator: (val) =>
                val!.isEmpty ? "Please enter a name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Trainer Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Please enter an email";
                  if (!val.contains('@')) return "Invalid email";
                  return null;
                },
              ),
              TextFormField(
                controller: _expertiseController,
                decoration: InputDecoration(labelText: "Expertise"),
                validator: (val) =>
                val!.isEmpty ? "Please enter expertise" : null,
              ),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: "Short Bio"),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                  onPressed: _submit, child: Text("Add Trainer")),
            ],
          ),
        ),
      ),
    );
  }
}
