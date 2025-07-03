import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Text("No bookings found.");

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              return ListTile(
                title: Text("Session with ${data['traineeId']}"),
                subtitle: Text("Date: $date"),
                trailing: Text(data['status']),
              );
            },
          );
        },
      ),
    );
  }
}
