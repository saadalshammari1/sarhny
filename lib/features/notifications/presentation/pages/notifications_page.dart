import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 400) {
      ref.read(notificationsListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final notifs = ref.watch(notificationsListProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final n = await ref
                    .read(notificationsRepositoryProvider)
                    .markAllRead();
                Fluttertoast.showToast(msg: 'تم وضع علامة كمقروء ($n)');
                ref.invalidate(notificationsListProvider);
                ref.invalidate(unreadNotificationsCountProvider);
              } catch (_) {
                Fluttertoast.showToast(msg: 'تعذّر التحديث');
              }
            },
            child: Text(
              'الكل مقروء',
              style: TextStyle(color: colors.moment),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(notificationsListProvider);
          await ref.read(notificationsListProvider.future);
        },
        child: notifs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(notificationsListProvider),
          ),
          data: (state) {
            if (state.items.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'لا توجد إشعارات',
                  subtitle: 'سيظهر هنا تنبيهك عن كل جديد',
                ),
              );
            }
            return ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length + (state.reachedEnd ? 0 : 1),
              itemBuilder: (_, i) {
                if (i >= state.items.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.moment,
                        ),
                      ),
                    ),
                  );
                }
                return _NotifTile(notification: state.items[i]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notification});
  final NotificationDto notification;

  ({IconData icon, String label, Color color, String? target}) _resolve(
      SarhnyColors colors) {
    final p = notification.payload;
    switch (notification.type) {
      case 'like':
        return (
          icon: Icons.favorite,
          label: 'أعجبهم منشورك',
          color: const Color(0xFFE2685A),
          target: p['post_id'] != null ? '/post/${p['post_id']}' : null
        );
      case 'comment':
        return (
          icon: Icons.chat_bubble_outline,
          label: 'علّق على منشورك',
          color: colors.face,
          target: p['post_id'] != null ? '/post/${p['post_id']}' : null
        );
      case 'follow':
        return (
          icon: Icons.person_add_alt_1_outlined,
          label: 'بدأ متابعتك',
          color: colors.mind,
          target: p['username'] != null ? '/u/${p['username']}' : null
        );
      case 'question':
      case 'anon_question':
        return (
          icon: Icons.visibility_off_outlined,
          label: 'وصلك سؤال مجهول',
          color: colors.moment,
          target: '/inbox'
        );
      case 'crystal':
      case 'crystallized':
        return (
          icon: Icons.diamond_outlined,
          label: 'منشورك تبلور ✦',
          color: colors.crystal,
          target: p['post_id'] != null ? '/post/${p['post_id']}' : null
        );
      default:
        return (
          icon: Icons.notifications_none_outlined,
          label: notification.type,
          color: colors.textSecondary,
          target: null
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final r = _resolve(colors);
    return InkWell(
      onTap: r.target == null
          ? null
          : () => context.push(r.target!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.read
              ? colors.surface
              : r.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.read
                ? colors.border
                : r.color.withValues(alpha: 0.35),
            width: notification.read ? 0.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: r.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(r.icon, color: r.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRelative(notification.createdAt),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 180.ms);
  }
}

String _formatRelative(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final delta = DateTime.now().toUtc().difference(dt.toUtc());
  if (delta.inMinutes < 1) return 'الآن';
  if (delta.inMinutes < 60) return 'قبل ${delta.inMinutes} د';
  if (delta.inHours < 24) return 'قبل ${delta.inHours} س';
  if (delta.inDays < 7) return 'قبل ${delta.inDays} يوم';
  return intl.DateFormat('d MMM', 'ar').format(dt.toLocal());
}
