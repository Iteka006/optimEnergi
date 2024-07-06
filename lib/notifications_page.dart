import 'package:flutter/material.dart';
import 'notification_manager.dart';
import 'notification_detail_page.dart';
import 'notification_data.dart';
import 'notification_type.dart'; // Import NotificationType
import 'package:intl/intl.dart'; // For date formatting

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<NotificationData> notifications = NotificationManager.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          String formattedTime = DateFormat.jm().format(notification.time);
          bool isToday = DateTime.now().difference(notification.time).inDays == 0;

          IconData iconData;
          Color iconColor;
          switch (notification.type) {
            case NotificationType.Important:
              iconData = Icons.error;
              iconColor = Colors.red;
              break;
            case NotificationType.Info:
              iconData = Icons.info;
              iconColor = Colors.blue;
              break;
            default:
              iconData = Icons.notifications;
              iconColor = Colors.grey;
          }

          return ListTile(
            leading: Icon(iconData, color: iconColor),
            title: Text(notification.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                SizedBox(height: 4),
                Text(
                  '$formattedTime ${isToday ? '(Today)' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailPage(notification: notification),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
