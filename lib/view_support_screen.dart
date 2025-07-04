import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final messages = FirebaseFirestore.instance
        .collection('supportMessages')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("User Support Messages")),
      body: StreamBuilder<QuerySnapshot>(
        stream: messages,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("No support messages."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = data['createdAt'] as Timestamp?;
              final dateStr = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                  .toLocal()
                  .toString()
                  .split('.')[0]
                  : 'Unknown';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("From: ${data['email'] ?? 'No Email'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${data['status']}"),
                      SizedBox(height: 5),
                      Text(data['message'] ?? ''),
                      SizedBox(height: 5),
                      Text("Sent: $dateStr", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  // Optional: Mark as resolved on tap
                  // onTap: () async {
                  //   await FirebaseFirestore.instance
                  //       .collection('supportMessages')
                  //       .doc(docs[index].id)
                  //       .update({'status': 'resolved'});
                  // },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
