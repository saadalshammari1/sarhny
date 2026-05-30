import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.initials,
    this.size = 44,
    this.ringColor,
    this.ringWidth = 0,
  });

  final String? url;
  final String? initials;
  final double size;
  final Color? ringColor;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final inner = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: colors.elevated),
                errorWidget: (_, __, ___) => _initialsWidget(context),
              )
            : _initialsWidget(context),
      ),
    );
    if (ringColor != null && ringWidth > 0) {
      return Container(
        padding: EdgeInsets.all(ringWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor!, width: ringWidth),
        ),
        child: inner,
      );
    }
    return inner;
  }

  Widget _initialsWidget(BuildContext context) {
    final colors = context.sarhnyColors;
    final letters = (initials ?? '?').characters.take(2).toString().toUpperCase();
    return Container(
      color: colors.elevated,
      alignment: Alignment.center,
      child: Text(letters,
          style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.4)),
    );
  }
}
