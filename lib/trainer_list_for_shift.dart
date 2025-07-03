import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_trainer_shift_screen.dart';

class TrainerListForShift extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Trainer")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trainers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final trainers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trainers.length,
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              final data = trainer.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';

              return ListTile(
                title: Text(name),
                subtitle: Text(data['expertise'] ?? ''),
                trailing: Icon(Icons.edit_calendar),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTrainerShiftScreen(
                        trainerId: trainer.id,
                        trainerName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
