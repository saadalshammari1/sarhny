import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/relative_time.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/banner_ad_slot.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/inbox_provider.dart';
import '../widgets/answer_sheet.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 400) {
      final f = ref.read(inboxFilterProvider);
      ref.read(inboxControllerProvider(f).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final filter = ref.watch(inboxFilterProvider);
    final state = ref.watch(inboxControllerProvider(filter));
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l.inboxAppBarTitle),
      ),
      bottomNavigationBar: const AppBottomNav(active: 1),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(inboxControllerProvider(filter));
          await ref.read(inboxControllerProvider(filter).future);
        },
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(inboxControllerProvider(filter)),
          ),
          data: (s) {
            if (s.items.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.mark_email_read_outlined,
                  title: l.inboxEmptyTitle,
                  subtitle: l.inboxEmptySubtitle,
                ),
              );
            }
            // Ad after the 2nd item only — inbox lists stay short per session.
            final hasAd = s.items.length >= 2;
            final loaderTail = s.reachedEnd ? 0 : 1;
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: s.items.length + (hasAd ? 1 : 0) + loaderTail,
              itemBuilder: (_, i) {
                if (hasAd && i == 2) return const BannerAdSlot();
                final itemIdx = hasAd && i > 2 ? i - 1 : i;
                if (itemIdx >= s.items.length) {
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
                return _InboxTile(
                  item: s.items[itemIdx],
                  onAnswer: () => _openAnswerSheet(s.items[itemIdx]),
                  onIgnore: () => _ignore(s.items[itemIdx]),
                  onReport: () => _report(s.items[itemIdx]),
                  onDelete: () => _delete(s.items[itemIdx]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openAnswerSheet(InboxItemDto item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnswerSheet(item: item),
    );
  }

  Future<void> _ignore(InboxItemDto item) async {
    if (item.status != 'unread') return;
    final l = AppLocalizations.of(context);
    final filter = ref.read(inboxFilterProvider);
    final notifier = ref.read(inboxControllerProvider(filter).notifier);
    // Optimistically clear the unread state so the dot/chips update at once
    // instead of lingering until a manual refresh.
    if (filter == InboxFilter.unread) {
      notifier.removeLocal(item.id);
    } else {
      notifier.updateLocal(item.id, item.copyWith(status: 'read'));
    }
    try {
      await ref.read(inboxRepositoryProvider).markRead(item.id);
      Fluttertoast.showToast(msg: l.inboxMarkedRead);
    } catch (_) {
      Fluttertoast.showToast(msg: l.inboxUpdateFailed);
      ref.invalidate(inboxControllerProvider(filter));
    }
  }

  Future<void> _delete(InboxItemDto item) async {
    final l = AppLocalizations.of(context);
    final filter = ref.read(inboxFilterProvider);
    ref.read(inboxControllerProvider(filter).notifier).removeLocal(item.id);
    try {
      await ref.read(inboxRepositoryProvider).delete(item.id);
      Fluttertoast.showToast(msg: l.inboxDeleted);
    } catch (_) {
      Fluttertoast.showToast(msg: l.inboxDeleteFailed);
      ref.invalidate(inboxControllerProvider(filter));
    }
  }

  Future<void> _report(InboxItemDto item) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(inboxRepositoryProvider).report(item.id);
      Fluttertoast.showToast(msg: l.inboxReported);
    } catch (_) {
      Fluttertoast.showToast(msg: l.inboxReportFailed);
    }
  }
}


class _InboxTile extends StatelessWidget {
  const _InboxTile({
    required this.item,
    required this.onAnswer,
    required this.onIgnore,
    required this.onReport,
    required this.onDelete,
  });
  final InboxItemDto item;
  final VoidCallback onAnswer;
  final VoidCallback onIgnore;
  final VoidCallback onReport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final unread = item.status == 'unread';
    final answered = item.status == 'answered';
    final revealed = !item.isSenderHidden && item.sender != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread
              ? colors.moment.withValues(alpha: 0.4)
              : colors.border,
          width: unread ? 1.2 : 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (revealed)
                GestureDetector(
                  onTap: () => context.push('/u/${item.sender!.username}'),
                  child: AppAvatar(
                    url: mediaUrl(item.sender!.avatarPath),
                    initials: item.sender!.displayName ??
                        item.sender!.username,
                    size: 30,
                  ),
                )
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.moment.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.visibility_off_outlined,
                      size: 16, color: colors.moment),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      revealed ? '@${item.sender!.username}' : l.inboxAnonymous,
                      style: TextStyle(
                        color: revealed
                            ? colors.textPrimary
                            : colors.moment,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRelative(context, item.createdAt),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.moment,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.message,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!answered) ...[
                _ActionChip(
                  icon: Icons.reply_outlined,
                  label: l.inboxReplyWithPost,
                  color: colors.moment,
                  primary: true,
                  onTap: onAnswer,
                ),
                const SizedBox(width: 6),
                _ActionChip(
                  icon: Icons.mark_email_read_outlined,
                  label: l.inboxIgnore,
                  color: colors.textSecondary,
                  onTap: onIgnore,
                ),
              ] else
                _ActionChip(
                  icon: Icons.check,
                  label: l.inboxAnswered,
                  color: colors.success,
                  onTap: () {},
                ),
              const Spacer(),
              IconButton(
                tooltip: l.inboxReportTooltip,
                onPressed: onReport,
                icon: Icon(Icons.flag_outlined,
                    size: 18, color: colors.textSecondary),
              ),
              IconButton(
                tooltip: l.commonDelete,
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 18, color: colors.danger),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.primary = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: primary ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: primary ? color : color.withValues(alpha: 0.45),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
