import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewTestimonialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stories = FirebaseFirestore.instance
        .collection('testimonials')
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("Success Stories")),
      body: StreamBuilder<QuerySnapshot>(
        stream: stories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Text("No stories yet.");

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['photoUrl']),
                    radius: 30,
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['message']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
