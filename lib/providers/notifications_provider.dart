import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationItem> _items = [];

  List<NotificationItem> get items {
    final copy = List<NotificationItem>.from(_items);
    copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(copy);
  }

  void add(NotificationItem item) {
    _items.add(item);
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final cur = _items[idx];
    _items[idx] = cur.copyWith(read: true);
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
