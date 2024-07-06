import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:optim_energi/real_time_energy_page_web.dart';
import 'package:optim_energi/report_page_web.dart';
import 'package:optim_energi/sign_in_page.dart';
import 'package:optim_energi/sign_in_page_web.dart';
import 'real_time_energy_page.dart';
import 'report_page.dart';
import 'predictive_analytics_page.dart';
import 'notification_manager.dart';
import 'budget_set.dart';
import 'carbon_footprint_page.dart';
import 'welcome_page.dart';
import 'welcome_page_web.dart'; 
import 'sign_up_page.dart'; 
import 'admin_notification_page.dart'; // Import AdminNotificationPage
import 'notifications_page.dart'; // Import NotificationsPage

import 'dart:js' as js;

void sendEmail(String serviceId, String templateId, String email, String message, List<dynamic> attachments) {
  js.context.callMethod('emailjs.send', [
    serviceId,
    templateId,
    {
      'to_email': email,
      'message': message,
      'attachments': attachments,
    },
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDPiZwP_vlLnnGo7nXIr35U9vM3_IxMzuM",
        authDomain: "optimenergi-44e00.firebaseapp.com",
        projectId: "optimenergi-44e00",
        storageBucket: "optimenergi-44e00.appspot.com",
        messagingSenderId: "951459639222",
        appId: "1:951459639222:web:3b3d7ecb780f9e6f975b17",
        measurementId: "G-0WL3S87GSX"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: kIsWeb ? WelcomePageWeb() : WelcomePage(),
      routes: {
        '/welcome': (context) => kIsWeb ? WelcomePageWeb() : WelcomePage(),
        '/sign-up': (context) => SignUpPage(),
        '/sign-in': (context) => kIsWeb ? SignInPageWeb() : SignInPage(),
        '/real-time-energy': (context) => kIsWeb ? RealTimeEnergyPageWeb() : RealTimeEnergyPage(),
        '/report': (context) => kIsWeb ? ReportPageWeb(usageData: []) : ReportPage(usageData: []),
        '/predictive-analytics': (context) => PredictiveAnalyticsPage(usageData: []),
        '/set-budget': (context) => BudgetSetPage(remainingEnergy: 1000.0),
        '/carbon-footprint': (context) => CarbonFootprintPage(usageData: []),
        '/admin-notification': (context) => AdminNotificationPage(),
        '/notifications': (context) => NotificationsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Text('View Notifications'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin-notification');
              },
              child: Text('Send Notification (Admin)'),
            ),
          ],
        ),
      ),
    );
  }
}
