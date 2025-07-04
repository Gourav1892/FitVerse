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
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("No success stories available."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Anonymous';
              final message = data['message'] ?? '';
              final photoUrl = data['photoUrl'];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: photoUrl != null
                      ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(photoUrl),
                    onBackgroundImageError: (_, __) {},
                  )
                      : CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
