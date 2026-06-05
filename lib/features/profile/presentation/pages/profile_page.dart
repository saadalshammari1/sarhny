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
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/widgets/post_card_skeleton.dart';
import '../providers/profile_provider.dart';

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

class _AuthedProfileBody extends ConsumerWidget {
  const _AuthedProfileBody(
      {required this.profile, required this.username});
  final PublicProfileDto profile;
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final tab = ref.watch(selectedProfileTabProvider(username));
    final posts =
        ref.watch(profilePostsProvider(ProfilePostsKey.make(username, tab)));
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(publicProfileProvider(username));
        ref.invalidate(
            profilePostsProvider(ProfilePostsKey.make(username, tab)));
      },
      color: colors.moment,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            title: Text('@${profile.user.username}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _AuthedHeader(profile: profile, username: username),
          ),
          SliverToBoxAdapter(
            child: _BadgesRow(profile: profile),
          ),
          SliverToBoxAdapter(
            child: _QuickLinks(username: profile.user.username),
          ),
          SliverToBoxAdapter(
            child: _TabsBar(
              username: username,
              current: tab,
              onPick: (t) => ref
                  .read(selectedProfileTabProvider(username).notifier)
                  .state = t,
            ),
          ),
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
            data: (page) {
              if (page.posts.isEmpty) {
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
              return SliverList.builder(
                itemCount: page.posts.length,
                itemBuilder: (_, i) => PostCard(post: page.posts[i]),
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
  bool _coverBusy = false;

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

  Future<void> _changeCover() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 2048);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
    );
    if (cropped == null) return;
    setState(() => _coverBusy = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .uploadCover(File(cropped.path));
      ref.invalidate(publicProfileProvider(widget.username));
      Fluttertoast.showToast(msg: 'تم تحديث الغلاف');
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الرفع');
    } finally {
      if (mounted) setState(() => _coverBusy = false);
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
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _coverBusy ? null : _changeCover,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: p.user.coverColor != null
                      ? _parseHex(p.user.coverColor!) ?? colors.moment
                      : colors.moment.withValues(alpha: 0.18),
                  image: p.user.coverPath != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(mediaUrl(p.user.coverPath) ?? ''),
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 12,
              child: _CameraButton(
                busy: _coverBusy,
                onTap: _changeCover,
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -34),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      children: [
                        AppAvatar(
                          url: mediaUrl(p.user.avatarPath),
                          initials: p.user.displayName,
                          size: 76,
                          ringColor: colors.background,
                          ringWidth: 3,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _CameraButton(
                            busy: _avatarBusy,
                            onTap: _changeAvatar,
                            small: true,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'تعديل',
                      icon: Icons.edit_outlined,
                      variant: AppButtonVariant.secondary,
                      expand: false,
                      onPressed: _showEditSheet,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Flexible(
                    child: Text(
                      p.user.displayName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.verified) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified, size: 18, color: colors.face),
                  ],
                ]),
                Text(
                  '@${p.user.username}',
                  style:
                      TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                if ((p.user.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    p.user.bio!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
                if ((p.user.location ?? '').isNotEmpty ||
                    (p.user.website ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if ((p.user.location ?? '').isNotEmpty) ...[
                        Icon(Icons.place_outlined,
                            size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          p.user.location!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if ((p.user.website ?? '').isNotEmpty) ...[
                        Icon(Icons.link,
                            size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            p.user.website!,
                            style: TextStyle(
                              color: colors.face,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _Stats(stats: p.stats),
              ],
            ),
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

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});
  final ProfileStatsDto stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    Widget cell(String label, int value, [Color? color]) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color ?? colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(color: colors.textSecondary, fontSize: 11)),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell('متابعون', stats.followers),
        cell('متابَعون', stats.following),
        cell('متبلور', stats.crystals, colors.crystal),
        cell('نشط', stats.active, colors.moment),
        cell('مرايا', stats.mirrors, colors.mind),
      ],
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.profile});
  final PublicProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final badges = <(IconData icon, String label, int count, Color color)>[
      (Icons.diamond_outlined, 'بلورات', profile.stats.crystals,
          colors.crystal),
      (Icons.local_fire_department_outlined, 'وهج', profile.streak.count,
          colors.moment),
      (Icons.auto_awesome_outlined, 'مرايا', profile.mirrors.count,
          colors.mind),
    ];
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: badges
            .map((b) => Container(
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: b.$4.withValues(alpha: 0.08),
                    border:
                        Border.all(color: b.$4.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(b.$1, color: b.$4, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.$3}',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            b.$2,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: tabs.map((t) {
          final selected = t.$1 == current;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => onPick(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.moment.withValues(alpha: 0.12)
                                  : colors.elevated,
                  border: Border.all(
                    color: selected ? colors.moment : colors.border,
                    width: selected ? 1.2 : 0.6,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.$3,
                      size: 14,
                      color: selected ? colors.moment : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.$2,
                      style: TextStyle(
                        color: selected ? colors.moment : colors.textSecondary,
                        fontSize: 12,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        children: items
            .map(
              (item) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: item.$3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.moment.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(item.$1,
                            color: colors.moment, size: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

Color? _parseHex(String s) {
  final v = s.replaceFirst('#', '');
  if (v.length == 6) {
    final n = int.tryParse('FF$v', radix: 16);
    return n == null ? null : Color(n);
  }
  if (v.length == 8) {
    final n = int.tryParse(v, radix: 16);
    return n == null ? null : Color(n);
  }
  return null;
}
