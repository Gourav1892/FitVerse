import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNutritionPlanScreen extends StatefulWidget {
  @override
  _AddNutritionPlanScreenState createState() => _AddNutritionPlanScreenState();
}

class _AddNutritionPlanScreenState extends State<AddNutritionPlanScreen> {
  final _titleController = TextEditingController();
  final _levelController = TextEditingController();
  final _typeController = TextEditingController();
  final Map<String, Map<String, String>> _meals = {
    "day1": {"breakfast": "", "lunch": "", "dinner": ""},
    "day2": {"breakfast": "", "lunch": "", "dinner": ""},
  };

  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('nutritionPlans').add({
        'title': _titleController.text.trim(),
        'level': _levelController.text.trim(),
        'type': _typeController.text.trim(),
        'meals': _meals,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Diet plan added")),
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

  Widget _buildMealInput(String day, String meal) {
    return TextFormField(
      decoration: InputDecoration(labelText: "$day - $meal"),
      onChanged: (value) {
        _meals[day]![meal] = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Diet Plan")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Plan Title")),
            TextField(controller: _levelController, decoration: InputDecoration(labelText: "Level")),
            TextField(controller: _typeController, decoration: InputDecoration(labelText: "Type")),
            ..._meals.entries.expand((entry) {
              final day = entry.key;
              return entry.value.keys.map((meal) => _buildMealInput(day, meal)).toList();
            }),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text("Add Plan")),
          ],
        ),
      ),
    );
  }
}
