import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewScreen extends StatefulWidget {
  @override
  _AdminOverviewScreenState createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  int userCount = 0;
  int trainerCount = 0;
  int bookingCount = 0;
  int testimonialCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'trainee')
          .get();

      final trainers = await FirebaseFirestore.instance
          .collection('trainers')
          .get();

      final bookings = await FirebaseFirestore.instance
          .collection('bookings')
          .get();

      final testimonials = await FirebaseFirestore.instance
          .collection('testimonials')
          .where('approved', isEqualTo: true)
          .get();

      setState(() {
        userCount = users.size;
        trainerCount = trainers.size;
        bookingCount = bookings.size;
        testimonialCount = testimonials.size;
        loading = false;
      });
    } catch (e) {
      print("Error loading counts: $e");
    }
  }

  Widget _buildCard(String title, int count, Color color) {
    return Card(
      color: color,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: Text("$count",
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCard("Total Users", userCount, Colors.blue),
            _buildCard("Total Trainers", trainerCount, Colors.green),
            _buildCard("Total Bookings", bookingCount, Colors.orange),
            _buildCard("Success Stories", testimonialCount, Colors.purple),
          ],
        ),
      ),
    );
  }
}
