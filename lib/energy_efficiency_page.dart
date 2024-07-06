import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyEfficiencyPage extends StatelessWidget {
  final List<Map<String, dynamic>> tips = [
    {
      'title': 'Turn Off Lights',
      'description': 'Switch off lights when leaving a room.',
      'icon': Icons.lightbulb_outline,
    },
    {
      'title': 'Use Energy-Efficient Appliances',
      'description': 'Upgrade to appliances with high energy efficiency ratings.',
      'icon': Icons.devices,
    },
    {
      'title': 'Adjust Thermostat',
      'description': 'Set thermostat to optimal temperatures based on season.',
      'icon': Icons.ac_unit,
    },
    {
      'title': 'Seal Leaks',
      'description': 'Check and seal leaks around doors and windows to conserve energy.',
      'icon': Icons.build,
    },
  ];

  Future<double> _fetchTodayEnergyUsage() async {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('energyUsage')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    double totalUsage = 0;
    snapshot.docs.forEach((doc) {
      totalUsage += doc['kwh'];
    });

    return totalUsage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Efficiency Recommendations'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<double>(
                future: _fetchTodayEnergyUsage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error fetching data');
                  } else {
                    return Column(
                      children: [
                        Text(
                          'Today\'s Energy Usage:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.data?.toStringAsFixed(2) ?? '0.00'} kWh',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return _buildTipCard(tips[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                tip['icon'],
                size: 36,
                color: Colors.red,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            tip['description'],
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
