import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewProgressScreen extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final progressLogs = FirebaseFirestore.instance
        .collection('progressLogs')
        .where('traineeId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("My Progress")),
      body: StreamBuilder<QuerySnapshot>(
        stream: progressLogs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("No progress logs yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy').format(date);

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['note'] ?? ''),
                  subtitle: Text("Weight: ${data['weight']}kg  •  Fat: ${data['fatPercent']}%"),
                  trailing: Text(formattedDate),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
