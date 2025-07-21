import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/role_router.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;

  const StepProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentStep ? Colors.blue : Colors.grey.shade300,
              ),
            );
          }),
        ),
        SizedBox(height: 10),
        Center(
          child: Text("Step \${currentStep + 1} of 4",
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class RegisterFitnessScreen extends StatefulWidget {
  final String phoneOrEmail;
  final String name;
  final String age;
  final String gender;
  final String role;

  const RegisterFitnessScreen({
    required this.phoneOrEmail,
    required this.name,
    required this.age,
    required this.gender,
    required this.role,
  });

  @override
  State<RegisterFitnessScreen> createState() => _RegisterFitnessScreenState();
}

class _RegisterFitnessScreenState extends State<RegisterFitnessScreen> {
  final _goalController = TextEditingController();
  String _selectedLevel = '';
  String _selectedFrequency = '';
  List<String> _selectedGoals = [];

  bool _loading = false;

  Future<void> _completeRegistration() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    try {
      final userData = {
        'uid': uid,
        'emailOrPhone': widget.phoneOrEmail,
        'name': widget.name,
        'age': widget.age,
        'gender': widget.gender,
        'role': widget.role,
        'fitnessLevel': _selectedLevel,
        'workoutFrequency': _selectedFrequency,
        'goals': _selectedGoals,
        'customGoal': _goalController.text.trim(),
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Registration complete!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => RoleRouter(uid: uid)),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: \${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildGoalCheckbox(String label) {
    final isSelected = _selectedGoals.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedGoals.add(label);
          } else {
            _selectedGoals.remove(label);
          }
        });
      },
      selectedColor: Colors.blue.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              StepProgressIndicator(currentStep: 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tell us about your fitness",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),

              // Fitness Level
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Your Fitness Level", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Column(
                children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                  return RadioListTile(
                    title: Text(level),
                    value: level,
                    groupValue: _selectedLevel,
                    onChanged: (val) => setState(() => _selectedLevel = val!),
                  );
                }).toList(),
              ),

              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("How often do you want to workout?", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Column(
                children: [
                  'Once a week',
                  '2 days a week',
                  '3-5 days a week',
                  'Daily'
                ].map((freq) {
                  return RadioListTile(
                    title: Text(freq),
                    value: freq,
                    groupValue: _selectedFrequency,
                    onChanged: (val) => setState(() => _selectedFrequency = val!),
                  );
                }).toList(),
              ),

              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Your Fitness Goals", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Fat Loss',
                  'Yoga',
                  'Cardio',
                  'Strength Training',
                  'Gym'
                ].map(_buildGoalCheckbox).toList(),
              ),

              SizedBox(height: 16),
              TextField(
                controller: _goalController,
                decoration: InputDecoration(
                  labelText: "Other Goals (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              SizedBox(height: 30),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  if (_selectedLevel.isEmpty || _selectedFrequency.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select your fitness level and frequency")),
                    );
                    return;
                  }
                  _completeRegistration();
                },
                child: Text("Finish"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
