import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewNutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nutrition Plans")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('nutritionPlans').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final plans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final data = plans[index].data() as Map<String, dynamic>;
              final meals = data['meals'] as Map<String, dynamic>;

              return ExpansionTile(
                title: Text(data['title']),
                subtitle: Text("${data['level']} - ${data['type']}"),
                children: meals.entries.map((entry) {
                  final day = entry.key;
                  final dayMeals = entry.value as Map<String, dynamic>;
                  return ListTile(
                    title: Text(day.toUpperCase()),
                    subtitle: Text(
                      "Breakfast: ${dayMeals['breakfast']}\n"
                          "Lunch: ${dayMeals['lunch']}\n"
                          "Dinner: ${dayMeals['dinner']}",
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

