import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/banner_ad_slot.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/widgets/post_card_skeleton.dart';
import '../widgets/profile_share.dart';
import '../providers/profile_provider.dart';
import '../../../article/data/article_repository.dart';
import '../../../article/presentation/providers/article_providers.dart';

/// Authenticated user's own profile.
/// Mirrors PublicProfilePage but adds edit + avatar/cover upload + tab on
/// "active/crystals/likes" with full CRUD over the user's data.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final auth = ref.watch(authStateProvider).valueOrNull;
    final username = auth?.username;
    if (username == null || username.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(title: const Text('حسابي')),
        bottomNavigationBar: const AppBottomNav(active: 4),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 70,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'جلستك غير مكتملة',
                  textAlign: TextAlign.center,
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'سجّل دخولك من جديد ليعمل كل شيء بشكل صحيح.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'تسجيل خروج وإعادة دخول',
                  expand: false,
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    final profile = ref.watch(publicProfileProvider(username));
    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: const AppBottomNav(active: 4),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(publicProfileProvider(username)),
        ),
        data: (p) => _AuthedProfileBody(profile: p, username: username),
      ),
    );
  }
}

class _AuthedProfileBody extends ConsumerStatefulWidget {
  const _AuthedProfileBody(
      {required this.profile, required this.username});
  final PublicProfileDto profile;
  final String username;

  @override
  ConsumerState<_AuthedProfileBody> createState() => _AuthedProfileBodyState();
}

class _AuthedProfileBodyState extends ConsumerState<_AuthedProfileBody> {
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
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      final tab = ref.read(selectedProfileTabProvider(widget.username));
      ref
          .read(
            profilePostsProvider(ProfilePostsKey.make(widget.username, tab))
                .notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final tab = ref.watch(selectedProfileTabProvider(widget.username));
    final posts = ref.watch(
        profilePostsProvider(ProfilePostsKey.make(widget.username, tab)));
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(publicProfileProvider(widget.username));
        ref.invalidate(
            profilePostsProvider(ProfilePostsKey.make(widget.username, tab)));
      },
      color: colors.moment,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            title: Text('@${widget.profile.user.username}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'مشاركة بروفايلي',
                onPressed: () => shareProfile(
                  context,
                  username: widget.profile.user.username,
                  displayName: widget.profile.user.displayName,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _AuthedHeader(
                profile: widget.profile, username: widget.username),
          ),
          SliverToBoxAdapter(
            child: _BadgesRow(profile: widget.profile),
          ),
          SliverToBoxAdapter(
            child: _QuickLinks(username: widget.profile.user.username),
          ),
          SliverToBoxAdapter(
            child: _TabsBar(
              username: widget.username,
              current: tab,
              onPick: (t) => ref
                  .read(selectedProfileTabProvider(widget.username).notifier)
                  .state = t,
            ),
          ),
          if (tab == ProfileTab.article)
            const SliverToBoxAdapter(child: _ProfileArticleTab())
          else
            posts.when(
            loading: () => const SliverToBoxAdapter(
              child: Column(children: [
                PostCardSkeleton(),
                PostCardSkeleton(),
              ]),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorView(message: e.toString()),
            ),
            data: (state) {
              if (state.posts.isEmpty) {
                final (icon, title, subtitle) = switch (tab) {
                  ProfileTab.active => (
                      Icons.flash_on_outlined,
                      'لا يوجد منشور نشط',
                      'أنشئ منشوراً ⚡',
                    ),
                  ProfileTab.moments => (
                      Icons.bolt_outlined,
                      'لا توجد لحظات بعد',
                      'شارك لحظة من يومك ⚡',
                    ),
                  ProfileTab.answers => (
                      Icons.question_answer_outlined,
                      'لا توجد أجوبة بعد',
                      'ردودك على الرسائل المجهولة ستظهر هنا 🕶️',
                    ),
                  ProfileTab.crystals => (
                      Icons.diamond_outlined,
                      'لا توجد بلورات بعد',
                      null,
                    ),
                  ProfileTab.likes => (
                      Icons.favorite_outline,
                      'لم تعجبك أي بلورة بعد',
                      null,
                    ),
                  ProfileTab.article => (
                      Icons.auto_awesome,
                      '',
                      null,
                    ),
                };
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: EmptyState(
                        icon: icon,
                        title: title,
                        subtitle: subtitle,
                      ),
                    ),
                  ),
                );
              }
              // Ad slots: row 1 (after 1st post) + every 10 posts after that
              // → rows 1, 12, 23, … (stride = 11).
              final adsTotal =
                  state.posts.isEmpty ? 0 : 1 + ((state.posts.length - 1) ~/ 10);
              final loaderTail = state.reachedEnd ? 0 : 1;
              return SliverList.builder(
                itemCount: state.posts.length + adsTotal + loaderTail,
                itemBuilder: (_, i) {
                  final isAd = i >= 1 && (i - 1) % 11 == 0;
                  if (isAd) return const BannerAdSlot();
                  final postIdx =
                      i < 1 ? i : i - (((i - 1) ~/ 11) + 1);
                  if (postIdx >= state.posts.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.moment,
                          ),
                        ),
                      ),
                    );
                  }
                  final p = state.posts[postIdx];
                  return PostCard(key: ValueKey<int>(p.id), post: p);
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

class _AuthedHeader extends ConsumerStatefulWidget {
  const _AuthedHeader({required this.profile, required this.username});
  final PublicProfileDto profile;
  final String username;

  @override
  ConsumerState<_AuthedHeader> createState() => _AuthedHeaderState();
}

class _AuthedHeaderState extends ConsumerState<_AuthedHeader> {
  bool _avatarBusy = false;

  Future<void> _changeAvatar() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,
    );
    if (cropped == null) return;
    setState(() => _avatarBusy = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(File(cropped.path));
      ref.invalidate(publicProfileProvider(widget.username));
      Fluttertoast.showToast(msg: 'تم تحديث الصورة');
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الرفع');
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _showEditSheet() async {
    final name = TextEditingController(text: widget.profile.user.displayName);
    final bio = TextEditingController(text: widget.profile.user.bio ?? '');
    final loc =
        TextEditingController(text: widget.profile.user.location ?? '');
    final web =
        TextEditingController(text: widget.profile.user.website ?? '');
    bool saving = false;
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        return StatefulBuilder(builder: (c, set) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(c).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: context.sarhnyColors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: context.sarhnyColors.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'تعديل البروفايل',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: name, label: 'الاسم المعروض'),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: bio,
                    label: 'نبذة',
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(controller: loc, label: 'الموقع'),
                  const SizedBox(height: 10),
                  AppTextField(controller: web, label: 'الموقع الإلكتروني'),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'حفظ',
                    loading: saving,
                    onPressed: () async {
                      set(() => saving = true);
                      try {
                        await ref
                            .read(profileRepositoryProvider)
                            .editProfile(
                              displayName: name.text.trim(),
                              bio: bio.text.trim(),
                              location: loc.text.trim(),
                              website: web.text.trim(),
                            );
                        ref.invalidate(
                            publicProfileProvider(widget.username));
                        if (c.mounted) Navigator.of(c).pop();
                        Fluttertoast.showToast(msg: 'تم الحفظ');
                      } on ValidationException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                      } catch (_) {
                        Fluttertoast.showToast(msg: 'تعذّر الحفظ');
                      } finally {
                        set(() => saving = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final p = widget.profile;
    // New layout: a compact, centered identity card — no large cover image
    // (saves bandwidth + storage and stays clean across themes). A soft
    // section-accent gradient backs the avatar to keep some visual warmth.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.moment.withValues(alpha: 0.18),
                  colors.moment.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.border, width: 0.6),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AppAvatar(
                      url: mediaUrl(p.user.avatarPath),
                      initials: p.user.displayName,
                      size: 96,
                      ringColor: colors.background,
                      ringWidth: 3,
                    ),
                    _CameraButton(
                      busy: _avatarBusy,
                      onTap: _changeAvatar,
                      small: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        p.user.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.verified) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 18, color: colors.face),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${p.user.username}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                if ((p.user.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    p.user.bio!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ],
                if ((p.user.location ?? '').isNotEmpty ||
                    (p.user.website ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if ((p.user.location ?? '').isNotEmpty)
                        _MetaChip(
                          icon: Icons.place_outlined,
                          label: p.user.location!,
                          colors: colors,
                        ),
                      if ((p.user.website ?? '').isNotEmpty)
                        _MetaChip(
                          icon: Icons.link,
                          label: p.user.website!,
                          colors: colors,
                          highlight: true,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _Stats(stats: p.stats, username: p.user.username),
                const SizedBox(height: 14),
                // Compact pill row — these used to be 4 big AppButtons that
                // dominated the card. Now they match the visual weight of
                // the بلورات/وهج badge row right below.
                _ProfileActionsRow(
                  onEdit: _showEditSheet,
                  onShare: () => shareProfile(
                    context,
                    username: p.user.username,
                    displayName: p.user.displayName,
                  ),
                  onArticle: () => context.push('/me/article'),
                  onGame: () => context.push('/game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders inside the profile tabs (own profile). Shows the user's current
/// article + history. Reuses eligibility/myArticle providers so it stays in
/// sync with the dedicated /me/article page.
class _ProfileArticleTab extends ConsumerWidget {
  const _ProfileArticleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final eligibility = ref.watch(articleEligibilityProvider);
    final article = ref.watch(myArticleProvider);
    final history = ref.watch(articleHistoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: eligibility.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(articleEligibilityProvider),
          ),
        ),
        data: (e) {
          final a = article.valueOrNull;
          final h = history.valueOrNull ?? const <ArticleHistoryItem>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ArticleTabHeader(eligibility: e, hasArticle: a != null),
              const SizedBox(height: 12),
              if (a != null) ...[
                _ArticleTabCurrent(article: a),
                const SizedBox(height: 10),
              ],
              if (h.isNotEmpty) ...[
                Text(
                  'الأرشيف · ${h.length} نسخة سابقة',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                for (final item in h.take(3)) ...[
                  _ArticleTabHistoryRow(item: item),
                  const SizedBox(height: 6),
                ],
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/me/article'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('فتح صفحة شخصيتي للتفاصيل والتحكم'),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _ArticleTabHeader extends StatelessWidget {
  const _ArticleTabHeader({required this.eligibility, required this.hasArticle});
  final ArticleEligibility eligibility;
  final bool hasArticle;
  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    final e = eligibility;

    // Cooldown — has article + within 30 days.
    if (e.daysRemaining > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.crystal.withValues(alpha: 0.08),
          border: Border.all(color: c.crystal.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_bottom_rounded, color: c.crystal, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'النسخة الجاية بعد ${e.daysRemaining} يوم',
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Not enough real answers.
    if (e.realAnswersCount < e.minRequired) {
      final percent = e.realAnswersCount / e.minRequired;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border, width: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_awesome, size: 14, color: c.crystal),
              const SizedBox(width: 6),
              Text(
                'افتح مقالتك بعد ${e.minRequired - e.realAnswersCount} إجابة',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${e.realAnswersCount}/${e.minRequired}',
                style: TextStyle(color: c.textSecondary, fontSize: 11),
              ),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: c.elevated,
                valueColor: AlwaysStoppedAnimation<Color>(c.crystal),
              ),
            ),
          ],
        ),
      );
    }

    // Eligible — show CTA encouraging the generation.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.crystal.withValues(alpha: 0.10),
        border: Border.all(color: c.crystal),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: c.crystal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasArticle
                  ? 'تقدر تنشئ نسخة جديدة الآن'
                  : 'أنت جاهز — افتح صفحة شخصيتي لتوليد مقالتك',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTabCurrent extends StatelessWidget {
  const _ArticleTabCurrent({required this.article});
  final UserArticle article;
  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border, width: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: article.isPublished
                    ? c.crystal.withValues(alpha: 0.15)
                    : c.elevated,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  article.isPublished ? Icons.public : Icons.lock_outline,
                  size: 11,
                  color: article.isPublished ? c.crystal : c.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  article.isPublished ? 'منشورة' : 'خاصة',
                  style: TextStyle(
                    color: article.isPublished ? c.crystal : c.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ]),
            ),
            if (article.generatedAt != null) ...[
              const SizedBox(width: 8),
              Text(
                article.generatedAt!.substring(0, 10),
                style: TextStyle(color: c.textSecondary, fontSize: 11),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Text(
            article.content,
            style: TextStyle(color: c.textPrimary, height: 1.8, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ArticleTabHistoryRow extends StatelessWidget {
  const _ArticleTabHistoryRow({required this.item});
  final ArticleHistoryItem item;
  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    final preview = item.content.length > 80
        ? '${item.content.substring(0, 80)}…'
        : item.content;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.elevated,
        border: Border.all(color: c.border, width: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.generatedAt != null)
            Text(
              item.generatedAt!.substring(0, 10),
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 3),
          Text(
            preview,
            style: TextStyle(color: c.textPrimary, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionsRow extends StatelessWidget {
  const _ProfileActionsRow({
    required this.onEdit,
    required this.onShare,
    required this.onArticle,
    required this.onGame,
  });
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onArticle;
  final VoidCallback onGame;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final items = <({
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      bool filled,
    })>[
      (
        icon: Icons.edit_outlined,
        label: 'تعديل',
        color: colors.textPrimary,
        onTap: onEdit,
        filled: false,
      ),
      (
        icon: Icons.ios_share_rounded,
        label: 'انشر حسابك',
        color: colors.moment,
        onTap: onShare,
        filled: true,
      ),
      (
        icon: Icons.auto_awesome,
        label: 'شخصيتي',
        color: colors.crystal,
        onTap: onArticle,
        filled: false,
      ),
      (
        icon: Icons.sports_esports_outlined,
        label: 'تحدّى',
        color: colors.face,
        onTap: onGame,
        filled: false,
      ),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final b = items[i];
          final bg = b.filled
              ? b.color.withValues(alpha: 0.18)
              : b.color.withValues(alpha: 0.08);
          final border = b.color.withValues(alpha: b.filled ? 0.5 : 0.3);
          return InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: b.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(b.icon, color: b.color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    b.label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.colors,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final SarhnyColors colors;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? colors.face : colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label,
            style: TextStyle(color: fg, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.busy,
    required this.onTap,
    this.small = false,
  });
  final bool busy;
  final VoidCallback onTap;
  final bool small;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: small ? 26 : 32,
        height: small ? 26 : 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 1.6, color: Colors.white),
              )
            : Icon(Icons.photo_camera_outlined,
                size: small ? 14 : 16, color: Colors.white),
      ),
    );
  }
}

/// Centered 3-up identity counters for the new profile card.
///
/// We surface the three numbers a user actually cares about:
///   - متابعون  (followers)
///   - أتابع    (following)
///   - أجوبة    (answers — previously hidden behind tabs)
///
/// Large bilingual-friendly digits with a `K` / `M` collapse so seven-digit
/// follower counts don't blow up the layout. The "أجوبة" cell taps over to
/// the answers tab on the parent profile page.
class _Stats extends ConsumerWidget {
  const _Stats({required this.stats, required this.username});
  final ProfileStatsDto stats;
  final String username;

  static String _format(int n) {
    // Custom compact format — intl's NumberFormat.compactCurrency turned
    // 12.3K into "١٢٫٣ ألف" in Arabic locale, which is too long for the
    // pill. Keep digits western, suffix Arabic.
    if (n < 1000) return '$n';
    if (n < 1000000) {
      final v = n / 1000;
      return v >= 100 ? '${v.toStringAsFixed(0)}K' : '${v.toStringAsFixed(1)}K';
    }
    final v = n / 1000000;
    return v >= 100 ? '${v.toStringAsFixed(0)}M' : '${v.toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;

    Widget cell(String label, int value, {VoidCallback? onTap, Color? accent}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _format(value),
                  style: TextStyle(
                    color: accent ?? colors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cell('متابعون', stats.followers),
            VerticalDivider(color: colors.divider, thickness: 0.6, width: 1),
            cell('أتابع', stats.following),
            VerticalDivider(color: colors.divider, thickness: 0.6, width: 1),
            cell(
              'أجوبة',
              stats.answers,
              accent: colors.moment,
              onTap: () => ref
                  .read(selectedProfileTabProvider(username).notifier)
                  .state = ProfileTab.answers,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.profile});
  final PublicProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final badges = <({
      IconData icon,
      String label,
      int count,
      Color color,
      String kind,
    })>[
      (
        icon: Icons.diamond_outlined,
        label: 'بلورات',
        count: profile.stats.crystals,
        color: colors.crystal,
        kind: 'crystals',
      ),
      (
        icon: Icons.local_fire_department_outlined,
        label: 'وهج',
        count: profile.streak.count,
        color: colors.moment,
        kind: 'streak',
      ),
      (
        icon: Icons.auto_awesome_outlined,
        label: 'مرايا',
        count: profile.mirrors.count,
        color: colors.mind,
        kind: 'mirrors',
      ),
    ];
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: badges
            .map((b) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () =>
                        context.push(AppRoutes.badgeExplainer(b.kind)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: b.color.withValues(alpha: 0.08),
                        border: Border.all(
                            color: b.color.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(b.icon, color: b.color, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${b.count}',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                b.label,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.info_outline,
                              size: 12,
                              color: b.color.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.username,
    required this.current,
    required this.onPick,
  });
  final String username;
  final ProfileTab current;
  final ValueChanged<ProfileTab> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    // 5 tabs is too many for an Expanded row on small phones — switch to a
    // horizontally scrollable pill row so labels never get clipped.
    final tabs = [
      (ProfileTab.active, 'نشط', Icons.flash_on_outlined),
      (ProfileTab.moments, 'لحظات', Icons.bolt_outlined),
      (ProfileTab.answers, 'أجوبة', Icons.question_answer_outlined),
      (ProfileTab.crystals, 'متبلور', Icons.diamond_outlined),
      (ProfileTab.likes, 'إعجابات', Icons.favorite_border),
      (ProfileTab.article, 'شخصيتي', Icons.auto_awesome),
    ];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: tabs.map((t) {
          final selected = t.$1 == current;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: GestureDetector(
              onTap: () => onPick(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? colors.moment.withValues(alpha: 0.12)
                                  : colors.elevated,
                  border: Border.all(
                    color: selected ? colors.moment : colors.border,
                    width: selected ? 1.0 : 0.5,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.$3,
                      size: 12,
                      color: selected ? colors.moment : colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.$2,
                      style: TextStyle(
                        color: selected ? colors.moment : colors.textSecondary,
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.notifications_outlined,
        'إشعاراتي',
        () => context.push(AppRoutes.notifications),
      ),
      (
        Icons.bookmark_outline,
        'محفوظاتي',
        () => context.push(AppRoutes.saved),
      ),
      (
        Icons.mail_outline,
        'صندوقي',
        () => context.push(AppRoutes.inbox),
      ),
      (
        Icons.help_outline,
        'المساعدة',
        () => context.push(AppRoutes.help),
      ),
      (
        Icons.settings_outlined,
        'الإعدادات',
        () => context.push(AppRoutes.settings),
      ),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map(
              (item) => Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: item.$3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.moment.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$1,
                              color: colors.moment, size: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

