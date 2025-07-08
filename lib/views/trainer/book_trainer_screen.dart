import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookTrainerScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  BookTrainerScreen({required this.trainerId, required this.trainerName});

  @override
  _BookTrainerScreenState createState() => _BookTrainerScreenState();
}

class _BookTrainerScreenState extends State<BookTrainerScreen> {
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  bool _loading = false;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
  }

  Future<void> _submitBooking() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (_dateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select date, start time, and end time.")),
      );
      return;
    }

    DateTime? fullDate;
    try {
      fullDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid date format.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'traineeId': uid,
        'trainerId': widget.trainerId,
        'trainerName': widget.trainerName,
        'date': fullDate,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'status': 'confirmed',
        'createdAt': Timestamp.now()
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session booked with ${widget.trainerName}")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book ${widget.trainerName}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date (YYYY-MM-DD)",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
            TextField(
              controller: _startTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Start Time (hh:mm AM/PM)",
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _pickTime(_startTimeController),
            ),
            TextField(
              controller: _endTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "End Time (hh:mm AM/PM)",
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _pickTime(_endTimeController),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitBooking,
              child: Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}