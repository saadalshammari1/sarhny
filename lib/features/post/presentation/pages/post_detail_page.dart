import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../providers/post_provider.dart';
import '../widgets/anon_replies_section.dart';
import '../widgets/comments_section.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final post = ref.watch(postProvider(postId));
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('منشور'),
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
            ref.invalidate(commentsControllerProvider(postId));
            ref.invalidate(anonRepliesControllerProvider(postId));
          },
          color: colors.moment,
          child: ListView(
            children: [
              PostCard(post: p),
              AnonRepliesSection(postId: postId),
              CommentsSection(postId: postId),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
