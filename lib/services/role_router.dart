import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../views/admin/admin_dashboard.dart';
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
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final role = snapshot.data?.get('role') ?? 'user';

        if (role == 'admin') {
          return AdminDashboard();
        } else if (role == 'trainer') {
          return TrainerDashboard();
        } else {
          return UserDashboard();
        }
      },
    );
  }
}
