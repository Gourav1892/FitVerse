import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookTrainerScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  BookTrainerScreen({required this.trainerId, required this.trainerName});

  @override
  _BookTrainerScreenState createState() => _BookTrainerScreenState();
}

class _BookTrainerScreenState extends State<BookTrainerScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _loading = false;

  Future<void> _submitBooking() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both date and time.")),
      );
      return;
    }

    DateTime? fullDateTime;
    try {
      fullDateTime = DateTime.parse("${_dateController.text} ${_timeController.text}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid date or time format.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'traineeId': uid,
        'trainerId': widget.trainerId,
        'trainerName': widget.trainerName,
        'date': fullDateTime,
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
              decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "Time (HH:MM)"),
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
