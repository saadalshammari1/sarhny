import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_theme.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Shimmer.fromColors(
        baseColor: colors.elevated,
        highlightColor: colors.divider,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const CircleAvatar(radius: 19, backgroundColor: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 120, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 8, width: 80, color: Colors.white),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Container(height: 10, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 10, width: 240, color: Colors.white),
            const SizedBox(height: 14),
            Row(children: [
              Container(height: 12, width: 40, color: Colors.white),
              const SizedBox(width: 18),
              Container(height: 12, width: 40, color: Colors.white),
            ]),
          ],
        ),
      ),
    );
  }
}
