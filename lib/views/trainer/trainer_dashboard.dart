import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/dashboard_tile.dart';
import 'package:fitverse/views/trainer/trainer_bookings_screen.dart';
import 'package:fitverse/views/trainer/trainer_profile_screen.dart';
import 'package:fitverse/views/auth/login_screen.dart'; // Make sure this import exists

class TrainerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trainer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardTile(
              label: "My Profile",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerProfileScreen()),
              ),
            ),
            DashboardTile(
              label: "My Bookings",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerBookingsScreen()),
              ),
            ),
            DashboardTile(
              label: "Track Client Progress",
              onTap: () {
                // Open user list first, then call AddProgressScreen(traineeId: ...)
              },
            ),
          ],
        ),
      ),
    );
  }
}
