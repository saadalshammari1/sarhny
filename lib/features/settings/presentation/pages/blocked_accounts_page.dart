import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/blocked_accounts_repository.dart';

final _repoProvider = Provider<BlockedAccountsRepository>(
  (ref) => BlockedAccountsRepository(ref.watch(dioClientProvider)),
);

final _blocksProvider = FutureProvider<List<BlockedAccount>>(
  (ref) => ref.watch(_repoProvider).list(),
);

class BlockedAccountsPage extends ConsumerWidget {
  const BlockedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final blocks = ref.watch(_blocksProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l.settingsBlockedAccounts)),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(_blocksProvider);
          await ref.read(_blocksProvider.future);
        },
        child: blocks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(_blocksProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.block_outlined,
                    title: l.settingsBlockedEmptyTitle,
                    subtitle: l.settingsBlockedEmptySubtitle,
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.divider,
                indent: 78,
              ),
              itemBuilder: (_, i) => _BlockedTile(account: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _BlockedTile extends ConsumerStatefulWidget {
  const _BlockedTile({required this.account});
  final BlockedAccount account;

  @override
  ConsumerState<_BlockedTile> createState() => _BlockedTileState();
}

class _BlockedTileState extends ConsumerState<_BlockedTile> {
  bool _busy = false;

  Future<void> _unblock() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(_repoProvider).unblock(widget.account.id);
      Fluttertoast.showToast(msg: l.settingsUnblocked);
      ref.invalidate(_blocksProvider);
    } catch (_) {
      Fluttertoast.showToast(msg: l.settingsUnblockFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final a = widget.account;
    return InkWell(
      onTap: () => context.push('/u/${a.username}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppAvatar(
              url: mediaUrl(a.avatarPath),
              initials: a.displayName,
              size: 46,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          a.displayName,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (a.verified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 14, color: colors.face),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${a.username}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _busy ? null : _unblock,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.moment,
                side: BorderSide(color: colors.moment.withValues(alpha: 0.45)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.6),
                    )
                  : Text(l.settingsUnblock),
            ),
          ],
        ),
      ),
    );
  }
}
