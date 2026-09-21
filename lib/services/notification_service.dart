import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AppNotification>> fetch({int limit = 50}) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map((r) => AppNotification.fromMap(r)).toList();
  }

  Future<int> unreadCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    final rows = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false);
    return rows.length;
  }

  Future<void> markAllRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }
}

class NotificationsController extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  Timer? _timer;
  int _unread = 0;

  int get unread => _unread;

  void start() {
    _timer?.cancel();
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  Future<void> refresh() async {
    try {
      final count = await _service.unreadCount();
      if (count != _unread) {
        _unread = count;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    _unread = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
