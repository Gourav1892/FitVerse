import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DashboardTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
