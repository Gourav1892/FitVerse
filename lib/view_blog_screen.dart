import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBlogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Articles & Resources")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final blogs = snapshot.data!.docs;

          if (blogs.isEmpty) {
            return Center(child: Text("No articles available."));
          }

          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final data = blogs[index].data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Untitled';
              final content = data['content'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image),
                  )
                      : null,
                  title: Text(title),
                  subtitle: Text(content.length > 60
                      ? content.substring(0, 60) + "..."
                      : content),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(title),
                      content: SingleChildScrollView(child: Text(content)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        )
                      ],
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
