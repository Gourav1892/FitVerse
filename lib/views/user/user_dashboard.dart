import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitverse/views/trainer/trainer_list_screen.dart';
import 'my_bookings_screen.dart';
import 'package:fitverse/view_progress_screen.dart';
import 'package:fitverse/view_blog_screen.dart';
import 'package:fitverse/contact_support_screen.dart';
import 'package:fitverse/submit_testimonial_screen.dart';
import 'package:fitverse/view_testimonials_screen.dart';

class DashboardTile extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardTile({
    required this.label,
    this.subLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (subLabel != null)
                Text(
                  subLabel!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('name')) {
        setState(() {
          userName = doc['name'];
        });
      } else {
        setState(() {
          userName = user.email ?? "User";
        });
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dashboard"),
              Text("Welcome back, $userName",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700))
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    user?.photoURL ?? 'https://i.pravatar.cc/300'),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final aspectRatio = constraints.maxHeight < 700 ? 1.1 : 1.3;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  DashboardTile(
                    label: "Book a Session",
                    subLabel: "Schedule your next coaching call",
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TrainerListScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "My Bookings",
                    subLabel: "2 upcoming sessions",
                    icon: Icons.access_time,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBookingsScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "My Progress",
                    subLabel: "You're doing great!",
                    icon: Icons.show_chart,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewProgressScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "Resources",
                    subLabel: "12 new articles",
                    icon: Icons.menu_book,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewBlogScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "Contact Support",
                    subLabel: "We're here to help",
                    icon: Icons.support_agent,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactSupportScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "Submit Review",
                    subLabel: "Share your experience",
                    icon: Icons.rate_review,
                    color: Colors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SubmitTestimonialScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "Success Stories",
                    subLabel: "Get inspired",
                    icon: Icons.emoji_events,
                    color: Colors.yellow.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewTestimonialsScreen()),
                    ),
                  ),
                  DashboardTile(
                    label: "Logout",
                    subLabel: "End session",
                    icon: Icons.logout,
                    color: Colors.red,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
