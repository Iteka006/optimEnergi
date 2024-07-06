import 'package:flutter/material.dart';
import 'package:optim_energi/admin_page_monitoring.dart';

class UserEnergyReportPage extends StatelessWidget {
  final UserEnergyData userData;

  const UserEnergyReportPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userData.firstName} ${userData.lastName} Energy Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${userData.userID}'),
            SizedBox(height: 20),
            Text('First Name: ${userData.firstName}'),
            Text('Last Name: ${userData.lastName}'),
            Text('Energy Usage: ${userData.energyUsage.toStringAsFixed(2)} kWh'),
            Text('Last Updated: ${userData.lastUpdated.toString()}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
