import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

/// Shared bottom navigation used by the five primary tabs.
///
/// `active` is the index of the currently-displayed tab so it gets the
/// highlighted state without re-navigating when tapped.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.active});
  final int active;

  static const List<_Item> _items = [
    _Item(Icons.home_outlined, Icons.home, AppRoutes.feed),
    _Item(Icons.mail_outline, Icons.mail, AppRoutes.inbox),
    // Center slot = Games ("Play"). Posting lives on Home (the floating pen +
    // the top "+"), so the center is freed for a lively games entry point.
    _Item(
      Icons.sports_esports_outlined,
      Icons.sports_esports,
      AppRoutes.gamesHub,
    ),
    _Item(
      Icons.auto_awesome_outlined,
      Icons.auto_awesome,
      AppRoutes.mirrors,
    ),
    _Item(Icons.person_outline, Icons.person, AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final labels = <String, String>{
      AppRoutes.feed: l.navHome,
      AppRoutes.inbox: l.navInbox,
      AppRoutes.gamesHub: l.navGames,
      AppRoutes.mirrors: l.navMirrors,
      AppRoutes.profile: l.navProfile,
    };
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
        boxShadow: colors.cardShadow
            .map((s) => BoxShadow(
                  color: s.color,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                  spreadRadius: -3,
                ))
            .toList(),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) {
            final isActive = i == active;
            final it = _items[i];
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (i == active) return;
                  // Games is a *destination* (not a tab) — push so the user can
                  // tap back to wherever they were. The four real tabs use go()
                  // to replace the stack so it stays flat.
                  if (it.route == AppRoutes.gamesHub) {
                    GoRouter.of(context).push(it.route);
                  } else {
                    GoRouter.of(context).go(it.route);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors.moment.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Icon(
                          isActive ? it.fill : it.outline,
                          size: 22,
                          color: isActive
                              ? colors.moment
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[it.route] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Item {
  const _Item(this.outline, this.fill, this.route);
  final IconData outline;
  final IconData fill;
  final String route;
}
