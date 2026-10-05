import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart' as legacy_api;
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _categories = <String, String>{
    'all': 'All',
    'purchases': 'Purchases',
    'transfers': 'Transfers',
    'kitchen': 'Kitchen',
    'waste': 'Waste',
    'inventory': 'Inventory',
  };

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;
  List<Map<String, dynamic>> _notifications = [];
  String _category = 'all';
  bool _unreadOnly = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _unreadCount = 0;
  int _page = 1;
  int _lastPage = 1;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNextPageWhenNearEnd);
    _loadNotifications(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_loadNextPageWhenNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadNextPageWhenNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 280 ||
        _page >= _lastPage) {
      return;
    }
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool reset = false}) async {
    if (!reset && (_isLoading || _isLoadingMore || _page >= _lastPage)) return;
    final requestVersion = reset ? ++_requestVersion : _requestVersion;
    final requestedPage = reset ? 1 : _page + 1;
    setState(() {
      if (reset) {
        _isLoading = true;
        _isLoadingMore = false;
        _error = null;
        _notifications = [];
        _page = 1;
        _lastPage = 1;
      } else {
        _isLoadingMore = true;
      }
    });

    final query = <String, String>{
      'page': '$requestedPage',
      'per_page': '25',
      if (_category != 'all') 'category': _category,
      if (_unreadOnly) 'unread': '1',
      if (_searchController.text.trim().isNotEmpty)
        'search': _searchController.text.trim(),
    };

    try {
      final response = await legacy_api.ApiClient.instance
          .get('/notifications?${Uri(queryParameters: query).query}');
      final data = Map<String, dynamic>.from(response['data'] as Map);
      final pagination = Map<String, dynamic>.from(data['pagination'] as Map);
      final pageItems = (data['notifications'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        if (reset) _notifications = [];
        _notifications.addAll(pageItems);
        _unreadCount = (data['unread_count'] as num?)?.toInt() ?? 0;
        _page = (pagination['current_page'] as num?)?.toInt() ?? requestedPage;
        _lastPage = (pagination['last_page'] as num?)?.toInt() ?? _page;
        _error = null;
      });
    } catch (error) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted && requestVersion == _requestVersion) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['read_at'] != null) return;
    try {
      final response = await legacy_api.ApiClient.instance.put(
        '/notifications/${notification['id']}/read',
        const {},
      );
      final data = Map<String, dynamic>.from(response['data'] as Map);
      if (!mounted) return;
      setState(() {
        notification['read_at'] =
            (data['notification'] as Map?)?['read_at'] ??
                DateTime.now().toIso8601String();
        _unreadCount = (data['unread_count'] as num?)?.toInt() ??
            (_unreadCount > 0 ? _unreadCount - 1 : 0);
        if (_unreadOnly) {
          _notifications.removeWhere((item) => item['id'] == notification['id']);
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not mark notification as read: $error')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadNotifications(reset: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            Text(
              '$_unreadCount unread',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search notifications',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchDebounce?.cancel();
                          _searchController.clear();
                          setState(() {});
                          _loadNotifications(reset: true);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _categories.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: _category == entry.key,
                    onSelected: (_) {
                      if (_category == entry.key) return;
                      setState(() => _category = entry.key);
                      _loadNotifications(reset: true);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Unread only'),
                avatar: const Icon(Icons.mark_email_unread_outlined, size: 18),
                selected: _unreadOnly,
                onSelected: (selected) {
                  setState(() => _unreadOnly = selected);
                  _loadNotifications(reset: true);
                },
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadNotifications(reset: true),
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading && _notifications.isEmpty) {
      return const ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null && _notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Center(child: Text('Could not load notifications')),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => _loadNotifications(reset: true),
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 110),
          Icon(Icons.notifications_none_rounded,
              size: 48, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _unreadOnly
                  ? 'You’re all caught up'
                  : 'No notifications match these filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _unreadOnly
                  ? 'New updates will appear here.'
                  : 'Try another category or search term.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final notification = _notifications[index];
        return _NotificationCard(
          notification: notification,
          categoryLabel:
              _categories[notification['category']] ?? 'Notification',
          onTap: () => _markAsRead(notification),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.categoryLabel,
    required this.onTap,
  });

  final Map<String, dynamic> notification;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = notification['read_at'] == null;
    final time = DateTime.tryParse('${notification['created_at'] ?? ''}');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: unread ? AppColors.softSurface : AppColors.cardSurface,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: CircleAvatar(
          backgroundColor:
              unread ? AppColors.accentGold.withOpacity(0.25) : AppColors.border,
          child: Icon(
            _categoryIcon(notification['category'] as String?),
            color: AppColors.darkGreen,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${notification['title'] ?? 'Notification'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${notification['message'] ?? ''}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      categoryLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(time),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: unread
            ? IconButton(
                tooltip: 'Mark as read',
                onPressed: onTap,
                icon: const Icon(Icons.done_rounded),
              )
            : null,
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'purchases':
        return Icons.shopping_bag_outlined;
      case 'transfers':
        return Icons.swap_horiz_rounded;
      case 'kitchen':
        return Icons.soup_kitchen_outlined;
      case 'waste':
        return Icons.delete_outline_rounded;
      case 'inventory':
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final local = time.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'Today, ${_clock(local)}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return 'Yesterday, ${_clock(local)}';
    }
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _clock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
