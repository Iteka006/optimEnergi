import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optim_energi/admin_notification_page.dart';
import 'package:optim_energi/admin_page.dart';
import 'package:optim_energi/admin_page_monitoring.dart';
import 'package:optim_energi/budget_set.dart';
import 'package:optim_energi/notification_type.dart';
import 'package:optim_energi/report_page_web.dart';
import 'notification_manager.dart';
import 'report_page.dart';
import 'predictive_analytics_page.dart';
import 'carbon_footprint_page.dart';
import 'energy_efficiency_page.dart';
import 'notifications_page.dart'; // Ensure you have this import
import 'report_page_web.dart';

class RealTimeEnergyPageWeb extends StatefulWidget {
  @override
  _RealTimeEnergyPageWebState createState() => _RealTimeEnergyPageWebState();
}

class _RealTimeEnergyPageWebState extends State<RealTimeEnergyPageWeb> {
  double _initialEnergy = 1000.0;
  double _remainingEnergy = 1000.0;
  double _totalEnergyUsed = 0.0;
  Timer? _timer;
  List<BarChartGroupData> _barChartData = [];
  int _days = 0;
  List<Map<String, dynamic>> _usageData = [];
  bool _isEnergyDepleted = false;
  DateTime _startDate = DateTime.now();
  // late String userName; // Variable to hold user's name
  bool _lowEnergyNotified = false;
  late String userID; 

  @override
  void initState() {
    super.initState();
    _startEnergySimulation();
    NotificationManager.init(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve user data from arguments passed during navigation
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    userID = args?['userID'] ?? ''; // Retrieve user ID
  }

Future<void> _storeUsageData(DateTime date, double dailyUsage) async {
  if (_isEnergyDepleted) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('energy_usage')
        .add({
          'date': Timestamp.fromDate(date),
          'usage': dailyUsage,
        });
  } catch (e) {
    print('Error storing data in Firestore: $e');
  }
}


  void _startEnergySimulation() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        if (_remainingEnergy <= 0) {
          _isEnergyDepleted = true;
          _remainingEnergy = 0;
          return;
        }

        double dailyUsage = Random().nextDouble() * 200;
        if (dailyUsage > _remainingEnergy) {
          dailyUsage = _remainingEnergy;
        }

        _remainingEnergy -= dailyUsage;
        _totalEnergyUsed = _initialEnergy - _remainingEnergy;
        _barChartData.add(BarChartGroupData(
          x: _days,
          barRods: [
            BarChartRodData(
              toY: dailyUsage,
              color: Colors.blue,
              width: 15,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ));
        DateTime currentDate = _startDate.add(Duration(days: _days));
        _usageData.add({
          'date': currentDate,
          'kwh': dailyUsage,
          'condition': dailyUsage > 400 ? 'ABNORMAL' : 'NORMAL'
        });
        _storeUsageData(currentDate, dailyUsage);

        _days++;

        if (_remainingEnergy <= 300 && !_isEnergyDepleted && !_lowEnergyNotified) {
          _lowEnergyNotified = true; // Flag to prevent multiple notifications
          NotificationManager.showNotification(
            id: 0,
            title: 'Low Energy Alert',
            body: 'Your energy is low. Please recharge your meter.',
            type: NotificationType.Important, // Example: Set NotificationType
          );
        }

        NotificationManager.checkBudget(dailyUsage);
      });
    });
  }

 Future<double> _fetchEnergyUsage(DateTime start, DateTime end) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .collection('energy_usage')
      .where('date', isGreaterThanOrEqualTo: start)
      .where('date', isLessThanOrEqualTo: end)
      .get();

  double totalUsage = 0;
  snapshot.docs.forEach((doc) {
    totalUsage += doc['usage'];
  });

  return totalUsage;
}


 Future<double> _fetchTodayEnergyUsage() async {
  DateTime today = DateTime.now();
  DateTime startOfDay = DateTime(today.year, today.month, today.day);
  DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
  return _fetchEnergyUsage(startOfDay, endOfDay);
}


 Future<double> _fetchYesterdayEnergyUsage() async {
  DateTime today = DateTime.now();
  DateTime startOfYesterday = DateTime(today.year, today.month, today.day - 1);
  DateTime endOfYesterday = DateTime(today.year, today.month, today.day - 1, 23, 59, 59);
  return _fetchEnergyUsage(startOfYesterday, endOfYesterday);
}


  String _getDayLabel(double value) {
    DateTime date = _startDate.add(Duration(days: value.toInt()));
    return '${date.month}/${date.day}';
  }

void _navigateToReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPageWeb(usageData: _usageData),
      ),
    );
  }


  void _navigateToPredictiveAnalyticsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictiveAnalyticsPage(usageData: _usageData),
      ),
    );
  }

  void _navigateToBudgetSetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetSetPage(remainingEnergy: _remainingEnergy), // Pass the remaining energy
      ),
    );
  }

  void _navigateToCarbonFootprintPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonFootprintPage(usageData: _usageData),
      ),
    );
  }

  void _navigateToEnergyEfficiencyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnergyEfficiencyPage(),
      ),
    );
  }

  void _navigateToNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(),
      ),
    );
  }
 
  void _navigateToAdminNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminNotificationPage(),
      ),
    );
  }

   void _navigateToAdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPage(),
      ),
    );
  }
  void _navigateToAdminEnergyUsagePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEnergyUsagePage(),
      ),
    );
  }
  void _logout() {
    // Navigate to welcome page
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  Widget _buildEnergyUsageCircle(String title, Future<double> futureUsage) {
    return FutureBuilder<double>(
      future: futureUsage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error');
        } else {
          return Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: Center(
                  child: Text(
                    '${snapshot.data?.toStringAsFixed(2) ?? '0.00'} kWh',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTotalEnergyUsageCircle() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: Center(
            child: Text(
              '${_totalEnergyUsed.toStringAsFixed(2)} kWh',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Total This Month',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Energy Monitoring',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _navigateToNotificationsPage,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userID,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Real-Time Energy Monitoring',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Real-Time Energy'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/real-time-energy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: _navigateToReportPage,
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Predictive Analytics'),
              onTap: _navigateToPredictiveAnalyticsPage,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Set Budget'),
              onTap: _navigateToBudgetSetPage,
            ),
            ListTile(
              leading: const Icon(Icons.eco),
              title: const Text('Recommendations Tips'),
              onTap: _navigateToEnergyEfficiencyPage,
            ),
            ListTile(
              leading: const Icon(Icons.eco),
              title: const Text('Carbon Footprint'),
              onTap: _navigateToCarbonFootprintPage,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin Notification'),
              onTap: _navigateToAdminNotificationPage,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin Monitoring'),
              onTap: _navigateToAdminEnergyUsagePage,
            ),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin Accounts'),
              onTap: _navigateToAdminPage,
            ),
            Divider(), // Add a divider before Logout button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEnergyUsageCircle('Today\'s Usage', _fetchTodayEnergyUsage()),
                _buildEnergyUsageCircle('Yesterday\'s Usage', _fetchYesterdayEnergyUsage()),
                _buildTotalEnergyUsageCircle(),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '         Remaining energy ${_remainingEnergy > 0 ? _remainingEnergy.toStringAsFixed(2) : "0.00"} kWh',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 243, 99, 89)),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _barChartData,
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60, // Increased to accommodate longer text
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} kWh',
                            style: TextStyle(fontSize: 14), // Adjust font size if needed
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _getDayLabel(value),
                            style: TextStyle(fontSize: 14), // Adjust font size if needed
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
