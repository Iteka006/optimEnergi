import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:optim_energi/notifications_page.dart';
import 'notification_data.dart';
import 'notification_detail_page.dart';
import 'notification_type.dart'; // Import NotificationType
import 'notification_data.dart';
class NotificationManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final List<NotificationData> _notifications = [];
  static void addNotification(NotificationData notification) {
    notifications.add(notification);
  }
  static double _dailyBudget = 0;
  static bool _budgetExceededNotified = false; // Flag to track if notification has been shown

  static List<NotificationData> get notifications => _notifications;

  static Future<void> init(BuildContext context) async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS: IOSInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationsPage()),
        );
      },
    );

    // Reset the notification flag at the start of each day
    Timer.periodic(Duration(days: 1), (timer) {
      _budgetExceededNotified = false;
    });
  }
  

  static void setDailyBudget(double budget) {
    _dailyBudget = budget;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type, // Include NotificationType in parameters
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    _notifications.add(NotificationData(
      id: id,
      title: title,
      body: body,
      time: DateTime.now(),
      type: type, // Assign NotificationType to the NotificationData instance
    ));
  }

  static void checkBudget(double dailyUsage) {
    if (_dailyBudget > 0 && dailyUsage >= _dailyBudget && !_budgetExceededNotified) {
      showNotification(
        id: 1,
        title: 'Daily Budget Exceeded',
        body: 'You have exceeded your daily energy budget of $_dailyBudget kWh.',
        type: NotificationType.Info, // Example: Set NotificationType
      );

      _budgetExceededNotified = true; // Set the flag to prevent multiple notifications
    }
  }
}
