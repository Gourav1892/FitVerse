import 'package:flutter/material.dart';

import '../../widgets/dashboard_tile.dart';
import 'package:fitverse/views/trainer/trainer_list_screen.dart';
import 'my_bookings_screen.dart';// Assuming this is the screen to book a session
import 'package:fitverse/view_progress_screen.dart'; // Assuming this is the screen to view progress

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trainee Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardTile(
              label: "Book a Session",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerListScreen()),
              ),
            ),
            DashboardTile(
              label: "My Bookings",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyBookingsScreen()),
              ),
            ),
            DashboardTile(
              label: "My Progress",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewProgressScreen()),
              ),
            ),


            DashboardTile(
              label: "Submit Review",
              onTap: () {},
            ),
            DashboardTile(
              label: "See Success Stories",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
