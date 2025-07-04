import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final bookings = FirebaseFirestore.instance
        .collection('bookings')
        .where('traineeId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

              final trainerName = data['trainerName'] ?? 'Trainer';
              final status = data['status'] ?? 'N/A';
              final statusColor = status == 'confirmed'
                  ? Colors.green
                  : (status == 'pending' ? Colors.orange : Colors.red);

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Trainer: $trainerName"),
                  subtitle: Text("Date: $formattedDate"),
                  trailing: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
