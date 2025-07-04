import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrainerBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final bookings = FirebaseFirestore.instance
        .collection('bookings')
        .where('trainerId', isEqualTo: uid)
        .orderBy('date', descending: false)
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
            return Center(child: Text("No bookings found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

              final trainee = data['traineeEmail'] ?? data['traineeId'] ?? "User";
              final status = data['status'] ?? 'N/A';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Session with $trainee"),
                  subtitle: Text("Date: $formattedDate"),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: status == 'confirmed'
                          ? Colors.green
                          : (status == 'pending' ? Colors.orange : Colors.red),
                      fontWeight: FontWeight.bold,
                    ),
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
