import 'package:flutter/material.dart';
import 'notification_manager.dart';
import 'notification_data.dart';
import 'notification_type.dart';

class AdminNotificationPage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  static int _notificationCounter = 0; // Counter to generate unique IDs

  void _sendNotification(BuildContext context) {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both title and body')),
      );
      return;
    }

    // Increment the counter for each new notification
    _notificationCounter++;

    NotificationData newNotification = NotificationData(
      id: _notificationCounter, // Assign the unique ID
      title: _titleController.text,
      body: _bodyController.text,
      time: DateTime.now(),
      type: NotificationType.Important,
    );

    NotificationManager.addNotification(newNotification);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent successfully')),
    );

    // Clear the text fields
    _titleController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendNotification(context),
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
