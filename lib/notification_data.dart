// notification_data.dart
import 'notification_type.dart';

class NotificationData {
  final int id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  NotificationData copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? time,
    NotificationType? type,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      type: type ?? this.type,
    );
  }
}

