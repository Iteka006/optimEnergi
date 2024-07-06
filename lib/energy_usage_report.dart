import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyUsageReport extends StatelessWidget {
  final String userID;
  final String firstName;
  final String lastName;

  EnergyUsageReport({required this.userID, required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$firstName $lastName - Energy Usage Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('energy_usage')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var usageData = snapshot.data!.docs;

            return ListView.builder(
              itemCount: usageData.length,
              itemBuilder: (context, index) {
                var usage = usageData[index];
                return ListTile(
                  title: Text('Date: ${usage['date']}'),
                  subtitle: Text('Usage: ${usage['usage']} kWh'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
