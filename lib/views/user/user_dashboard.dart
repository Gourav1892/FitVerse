import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/dashboard_tile.dart';
import 'package:fitverse/views/trainer/trainer_list_screen.dart';
import 'my_bookings_screen.dart';
import 'package:fitverse/view_progress_screen.dart';
import 'package:fitverse/view_blog_screen.dart';
import 'package:fitverse/contact_support_screen.dart';
import 'package:fitverse/submit_testimonial_screen.dart';
import 'package:fitverse/view_testimonials_screen.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trainee Dashboard"),
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
              label: "Resources",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewBlogScreen()),
              ),
            ),
            DashboardTile(
              label: "Contact Support",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactSupportScreen()),
              ),
            ),
            DashboardTile(
              label: "Submit Review",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SubmitTestimonialScreen()),
              ),
            ),
            DashboardTile(
              label: "See Success Stories",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewTestimonialsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
