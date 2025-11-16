import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController() {
    _items = List.from(DummyData.notifications);
  }

  late List<NuviqNotification> _items;
  String _filter = 'All';

  List<NuviqNotification> get items {
    if (_filter == 'All') return _sorted();
    return _sorted().where((item) => item.type == _filter).toList();
  }

  String get filter => _filter;
  int get unreadCount => _items.where((n) => !n.read).length;
  List<String> get filters => const ['All', 'Planning', 'Tasks', 'Gallery'];

  void filterBy(String value) {
    _filter = value;
    notifyListeners();
  }

  void markRead(String id) {
    _items = _items
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(read: true)
              : notification,
        )
        .toList();
    DummyData.notifications = List.from(_items);
    notifyListeners();
  }

  void toggleRead(String id) {
    _items = _items
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(read: !notification.read)
              : notification,
        )
        .toList();
    DummyData.notifications = List.from(_items);
    notifyListeners();
  }

  void markAllRead() {
    _items = _items.map((notification) => notification.copyWith(read: true)).toList();
    DummyData.notifications = List.from(_items);
    notifyListeners();
  }

  List<NuviqNotification> _sorted() {
    final copy = [..._items];
    copy.sort((a, b) => b.time.compareTo(a.time));
    return copy;
  }
}
