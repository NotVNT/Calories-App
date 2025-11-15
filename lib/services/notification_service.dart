import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';
import '../providers/notifications_provider.dart';
import 'firebase_service.dart';

/// Lightweight shim for notification functionality used by the app.
///
/// This file avoids heavy platform-specific plugin APIs so analysis and
/// builds remain simple while feature code (FCM/local notifications)
/// can be incrementally enabled by replacing this shim with the
/// full implementation when dependencies and platform setup are ready.
class NotificationService {
  final NotificationsProvider notificationsProvider;

  NotificationService({required this.notificationsProvider});

  Future<void> init({String? uid}) async {
    // In the shim we don't initialize platform plugins. If Firebase is
    // enabled the app can replace this with the real implementation.
    if (FirebaseService.shouldUseFirebase()) {
      debugPrint(
        'NotificationService shim: Firebase enabled but FCM not wired.',
      );
    }
  }

  Future<void> dispose() async {}

  Future<void> showLocalAndStore({
    required String id,
    required String title,
    required String body,
    String? deepLink,
  }) async {
    notificationsProvider.add(
      NotificationItem(id: id, title: title, body: body, deepLink: deepLink),
    );
  }

  Future<void> subscribeTopic(String topic) async {}

  Future<void> unsubscribeTopic(String topic) async {}

  Future<void> registerFcmToken(String? uid, String token) async {
    if (uid == null) return;
    if (!FirebaseService.shouldUseFirebase()) return;
    try {
      await FirebaseService.saveFcmToken(uid, token);
    } catch (e) {
      debugPrint('registerFcmToken failed: $e');
    }
  }

  Future<void> scheduleLocalReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduled,
  }) async {
    notificationsProvider.add(
      NotificationItem(
        id: id,
        title: title,
        body: body,
        timestamp: scheduled.toUtc(),
      ),
    );
  }
}
