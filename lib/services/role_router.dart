import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../views/trainer/trainer_dashboard.dart';
import '../views/user/user_dashboard.dart';

class RoleRouter extends StatelessWidget {
  final String uid;

  RoleRouter({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("User data not found.")),
          );
        }

        final role = snapshot.data?.get('role') ?? 'trainee';

        if (role == 'trainer') {
          return TrainerDashboard();
        } else {
          return UserDashboard(); // default to user
        }
      },
    );
  }
}
