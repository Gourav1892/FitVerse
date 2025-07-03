import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTrainerShiftScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  EditTrainerShiftScreen({required this.trainerId, required this.trainerName});

  @override
  _EditTrainerShiftScreenState createState() => _EditTrainerShiftScreenState();
}

class _EditTrainerShiftScreenState extends State<EditTrainerShiftScreen> {
  final Map<String, List<String>> availability = {
    'mon': [],
    'tue': [],
    'wed': [],
    'thu': [],
    'fri': [],
    'sat': [],
    'sun': [],
  };

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final doc = await FirebaseFirestore.instance
        .collection('trainers')
        .doc(widget.trainerId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final stored = data['availability'] as Map<String, dynamic>?;

      if (stored != null) {
        stored.forEach((day, times) {
          availability[day] = List<String>.from(times);
        });
        setState(() {});
      }
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('trainers')
        .doc(widget.trainerId)
        .update({'availability': availability});

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Availability Updated")));

    setState(() => _loading = false);
  }

  void _editDay(String day) async {
    final controller = TextEditingController();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Enter comma-separated time slots for $day"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "e.g. 10:00,14:00,16:00"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final times = controller.text.split(',').map((e) => e.trim()).toList();
              Navigator.pop(context, times);
            },
            child: Text("Save"),
          )
        ],
      ),
    );

    if (result != null) {
      setState(() {
        availability[day] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Shift - ${widget.trainerName}")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ...availability.keys.map((day) {
            final times = availability[day]!.join(", ");
            return Card(
              child: ListTile(
                title: Text(day.toUpperCase()),
                subtitle: Text(times.isEmpty ? "No Slots" : times),
                trailing: Icon(Icons.edit),
                onTap: () => _editDay(day),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          _loading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
              onPressed: _saveAvailability, child: Text("Save All")),
        ],
      ),
    );
  }
}
