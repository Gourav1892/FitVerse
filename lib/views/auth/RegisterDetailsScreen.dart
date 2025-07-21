import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'RegisterFitnessScreen.dart';

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
          child: Text("Step ${currentStep + 1} of 4",
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class RegisterDetailsScreen extends StatefulWidget {
  final String phoneOrEmail;
  final String role;

  const RegisterDetailsScreen({required this.phoneOrEmail, required this.role});

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDOB;
  int _calculatedAge = 0;
  String _gender = '';

  double _heightValue = 160;
  String _heightUnit = 'cm';

  double _weightValue = 60;
  String _weightUnit = 'kg';

  void _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month || (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      setState(() {
        _selectedDOB = picked;
        _calculatedAge = age;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                StepProgressIndicator(currentStep: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Your Personal Details",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? "Please enter your name" : null,
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _pickDOB,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDOB == null
                            ? "Select your date of birth"
                            : DateFormat('yyyy-MM-dd').format(_selectedDOB!)),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                if (_selectedDOB != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Age: $_calculatedAge"),
                    ),
                  ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Gender", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text("Male"),
                        value: "Male",
                        groupValue: _gender,
                        onChanged: (val) => setState(() => _gender = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text("Female"),
                        value: "Female",
                        groupValue: _gender,
                        onChanged: (val) => setState(() => _gender = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Height (${_heightUnit.toUpperCase()})"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: _heightUnit == 'cm' ? 100 : 40,
                        max: _heightUnit == 'cm' ? 220 : 90,
                        divisions: _heightUnit == 'cm' ? 120 : 50,
                        value: _heightValue,
                        onChanged: (val) => setState(() => _heightValue = val),
                      ),
                    ),
                    Text(_heightValue.toStringAsFixed(0)),
                    SizedBox(width: 8),
                    DropdownButton(
                      value: _heightUnit,
                      onChanged: (val) => setState(() {
                        _heightUnit = val!;
                        _heightValue = _heightUnit == 'cm'
                            ? _heightValue.clamp(100, 220)
                            : _heightValue.clamp(40, 90);
                      }),
                      items: ['cm', 'inches'].map((u) => DropdownMenuItem(
                        child: Text(u),
                        value: u,
                      )).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Weight (${_weightUnit.toUpperCase()})"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: _weightUnit == 'kg' ? 30 : 60,
                        max: _weightUnit == 'kg' ? 150 : 330,
                        divisions: _weightUnit == 'kg' ? 120 : 90,
                        value: _weightValue,
                        onChanged: (val) => setState(() => _weightValue = val),
                      ),
                    ),
                    Text(_weightValue.toStringAsFixed(0)),
                    SizedBox(width: 8),
                    DropdownButton(
                      value: _weightUnit,
                      onChanged: (val) => setState(() {
                        _weightUnit = val!;
                        _weightValue = _weightUnit == 'kg'
                            ? _weightValue.clamp(30, 150)
                            : _weightValue.clamp(60, 330);
                      }),
                      items: ['kg', 'lbs'].map((u) => DropdownMenuItem(
                        child: Text(u),
                        value: u,
                      )).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDOB == null) {
                        _showSnackbar("Please select your date of birth");
                        return;
                      }
                      if (_gender.isEmpty) {
                        _showSnackbar("Please select your gender");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterFitnessScreen(
                            phoneOrEmail: widget.phoneOrEmail,
                            name: _nameController.text.trim(),
                            age: _calculatedAge.toString(),
                            gender: _gender,
                            role: widget.role,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Next"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
