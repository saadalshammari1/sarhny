import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../providers/post_provider.dart';
import '../widgets/anon_replies_section.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final post = ref.watch(postProvider(postId));
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l.postTitle),
      ),
      body: post.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(postProvider(postId)),
        ),
        data: (p) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(postProvider(postId));
            ref.invalidate(anonRepliesControllerProvider(postId));
          },
          color: colors.moment,
          child: ListView(
            children: [
              // tappable: false — we ARE on /post/X already, tapping the card
              // would push the same id onto the stack again (forever).
              PostCard(post: p, tappable: false),
              AnonRepliesSection(postId: postId),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
