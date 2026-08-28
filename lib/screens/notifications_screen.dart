import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await NotificationService.fetchAll();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (item['is_read'] == true) return;
    await NotificationService.markRead(int.parse(item['notification_id'].toString()));
    await _load();
  }

  @override
  Widget build(BuildContext context) => buildScreenShell(
        context,
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await NotificationService.markAllRead();
              await _load();
            },
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('No notifications yet'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, index) {
                        final item = _items[index];
                        final read = item['is_read'] == true;
                        return ListTile(
                          leading: Icon(read ? Icons.notifications_none : Icons.notifications,
                              color: read ? Colors.grey : Colors.blue),
                          title: Text(item['title']?.toString() ?? 'Notification',
                              style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(item['message']?.toString() ?? ''),
                          onTap: () => _markRead(item),
                        );
                      },
                    ),
        ),
      );
}
