import 'package:flutter/material.dart';

import '../../core/models/seen_notification.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/async_state.dart';
import '../../core/theme/seen_theme.dart';
import '../auth/login_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.repository,
  });

  final SeenRepository repository;

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<SeenNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SeenNotification>> _load() {
    return widget.repository.fetchNotifications();
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> _markAsRead(SeenNotification item) async {
    if (item.read) return;

    try {
      await widget.repository.markNotificationRead(item.id);

      if (mounted) {
        _refresh();
      }
    } catch (e) {
      _message(e.toString());
    }
  }

  Future<void> _clearRead() async {
    try {
      await widget.repository.clearReadNotifications();

      if (mounted) {
        _refresh();
      }
    } catch (e) {
      _message(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SessionService.instance.isSignedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: SeenColors.teal,
              ),
              const SizedBox(height: 12),
              const Text('سجّل الدخول لعرض إشعاراتك'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            tooltip: 'حذف المقروء',
            onPressed: _clearRead,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<SeenNotification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? <SeenNotification>[];

          if (items.isEmpty) {
            return const EmptyState(
              title: 'لا إشعارات جديدة',
              subtitle: 'سنضع التحديثات المهمة هنا.',
              icon: Icons.notifications_none_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            separatorBuilder: (_, _) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.read
                        ? SeenColors.line
                        : SeenColors.teal.withValues(alpha: .12),
                    child: Icon(
                      item.read
                          ? Icons.notifications_none
                          : Icons.notifications_active_outlined,
                      color: SeenColors.teal,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.read
                          ? FontWeight.w500
                          : FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(item.message),
                  onTap: () => _markAsRead(item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}