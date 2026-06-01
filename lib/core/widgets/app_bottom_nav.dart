import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    _Item(Icons.home_outlined, Icons.home, 'الرئيسية', AppRoutes.feed),
    _Item(Icons.mail_outline, Icons.mail, 'صندوق', AppRoutes.inbox),
    _Item(
      Icons.add_circle_outline,
      Icons.add_circle,
      'نشر',
      AppRoutes.compose,
    ),
    _Item(
      Icons.auto_awesome_outlined,
      Icons.auto_awesome,
      'مرآتي',
      AppRoutes.mirrors,
    ),
    _Item(Icons.person_outline, Icons.person, 'حسابي', AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
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
                  GoRouter.of(context).go(it.route);
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
                        it.label,
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
  const _Item(this.outline, this.fill, this.label, this.route);
  final IconData outline;
  final IconData fill;
  final String label;
  final String route;
}
