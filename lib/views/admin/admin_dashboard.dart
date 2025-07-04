import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/dashboard_tile.dart';
import 'package:fitverse/trainer_list_for_shift.dart';
import 'package:fitverse/admin_overview_screen.dart';
import 'package:fitverse/add_blog_screen.dart';
import 'add_trainer_screen.dart'; // If created

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardTile(
              label: "Add Trainer",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTrainerScreen()),
              ),
            ),
            DashboardTile(
              label: "Admin Overview",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminOverviewScreen()),
              ),
            ),
            DashboardTile(
              label: "Add Blog Post",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBlogScreen()),
              ),
            ),
            DashboardTile(
              label: "Change Trainer Shifts",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerListForShift()),
              ),
            ),
            DashboardTile(
              label: "View All Reviews",
              onTap: () {}, // To be implemented
            ),
            DashboardTile(
              label: "Client Progress Tracker",
              onTap: () {}, // To be implemented
            ),
          ],
        ),
      ),
    );
  }
}
