import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_trainer_screen.dart';

class TrainerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Trainers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trainers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final trainers = snapshot.data!.docs;

          if (trainers.isEmpty) {
            return Center(child: Text("No trainers available."));
          }

          return ListView.builder(
            itemCount: trainers.length,
            itemBuilder: (context, index) {
              final data = trainers[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['name'] ?? "No Name"),
                  subtitle: Text(data['expertise'] ?? "No Expertise"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookTrainerScreen(
                        trainerId: trainers[index].id,
                        trainerName: data['name'] ?? "",
                      ),
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
