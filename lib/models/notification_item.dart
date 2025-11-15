import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;
  final String? deepLink; // e.g. "/food/{id}" or "/diary/{entryId}"
  final String? topic;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.read = false,
    this.deepLink,
    this.topic,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? read,
    String? deepLink,
    String? topic,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      deepLink: deepLink ?? this.deepLink,
      topic: topic ?? this.topic,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'read': read,
    'deepLink': deepLink,
    'topic': topic,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
    id: m['id'] as String? ?? UniqueKey().toString(),
    title: m['title'] as String? ?? '',
    body: m['body'] as String? ?? '',
    timestamp: m['timestamp'] != null
        ? DateTime.tryParse(m['timestamp'] as String)
        : null,
    read: m['read'] as bool? ?? false,
    deepLink: m['deepLink'] as String?,
    topic: m['topic'] as String?,
  );
}
