import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_energy_report_page.dart'; // Import the new page

class AdminEnergyUsagePage extends StatefulWidget {
  @override
  _AdminEnergyUsagePageState createState() => _AdminEnergyUsagePageState();
}

class _AdminEnergyUsagePageState extends State<AdminEnergyUsagePage> {
  List<UserEnergyData> _userEnergyData = [];

  @override
  void initState() {
    super.initState();
    _fetchUserEnergyData();
  }

  Future<void> _fetchUserEnergyData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<UserEnergyData> usersData = [];

      for (var userDoc in querySnapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>; // Explicit cast

        var userID = userDoc.id;

        // Retrieve energy usage data for each user
        QuerySnapshot energySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('energy_usage')
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (energySnapshot.docs.isNotEmpty) {
          var energyData = energySnapshot.docs.first.data() as Map<String, dynamic>; // Explicit cast
          usersData.add(UserEnergyData(
            userID: userID,
            firstName: userData['firstName'] ?? 'Unknown',
            lastName: userData['lastName'] ?? 'Unknown',
            energyUsage: energyData['usage']?.toDouble() ?? 0.0,
            lastUpdated: (energyData['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        }
      }

      setState(() {
        _userEnergyData = usersData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _navigateToUserEnergyReport(UserEnergyData userData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserEnergyReportPage(userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Energy Usage'),
      ),
      body: _userEnergyData.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _userEnergyData.length,
              itemBuilder: (context, index) {
                var userData = _userEnergyData[index];
                return ListTile(
                  onTap: () => _navigateToUserEnergyReport(userData),
                  leading: Icon(Icons.person),
                  title: Text('${userData.firstName} ${userData.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Energy Usage: ${userData.energyUsage.toStringAsFixed(2)} kWh'),
                      Text('Last Updated: ${userData.lastUpdated.toString()}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class UserEnergyData {
  final String userID;
  final String firstName;
  final String lastName;
  final double energyUsage;
  final DateTime lastUpdated;

  UserEnergyData({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.energyUsage,
    required this.lastUpdated,
  });
}
