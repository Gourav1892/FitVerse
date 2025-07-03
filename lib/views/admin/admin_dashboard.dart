import 'package:flutter/material.dart';

import '../../widgets/dashboard_tile.dart';
import 'package:fitverse/trainer_list_for_shift.dart';
import 'package:fitverse/admin_overview_screen.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardTile(
              label: "Add Trainer",
              onTap: () {
                // Navigate to AddTrainerScreen (to be built)
              },
            ),
            DashboardTile(
              label: "Admin Overview",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminOverviewScreen()),
              ),
            ),


      DashboardTile(
      label: "Change Trainer Shifts",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TrainerListForShift()),
          );
        },
      ),


      DashboardTile(
              label: "View All Reviews",
              onTap: () {},
            ),
            DashboardTile(
              label: "Client Progress Tracker",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
