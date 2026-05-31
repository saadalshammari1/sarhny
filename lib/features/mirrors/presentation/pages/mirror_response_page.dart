import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/mirror_dto.dart';
import '../providers/mirrors_provider.dart';

final _publicMirrorProvider =
    FutureProvider.family<PublicMirrorDto, String>((ref, token) {
  return ref.watch(mirrorsRepositoryProvider).getPublic(token);
});

class MirrorResponsePage extends ConsumerStatefulWidget {
  const MirrorResponsePage({super.key, required this.token});
  final String token;

  @override
  ConsumerState<MirrorResponsePage> createState() =>
      _MirrorResponsePageState();
}

class _MirrorResponsePageState extends ConsumerState<MirrorResponsePage> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final txt = _ctrl.text.trim();
    if (txt.length < 2 || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(mirrorsRepositoryProvider)
          .respondAuthed(widget.token, txt);
      if (mounted) setState(() => _done = true);
    } on UnauthorizedException {
      setState(() => _error = 'سجّل دخولك للرد على المرآة');
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on RateLimitException {
      setState(() => _error = 'لقد رددت كثيراً مؤخراً — انتظر قليلاً');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'تعذّر الإرسال');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final authed = ref.watch(authStateProvider).valueOrNull?.status ==
        AuthStatus.authenticated;
    final mirror = ref.watch(_publicMirrorProvider(widget.token));
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('مرآة')),
      body: mirror.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_publicMirrorProvider(widget.token)),
        ),
        data: (m) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _done
                  ? _Sent(colors: colors)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OwnerCard(mirror: m, colors: colors),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: colors.border, width: 0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        colors.mind.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '🪞',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'السؤال',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Text(
                                m.questionText,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _ctrl,
                          minLines: 3,
                          maxLines: 6,
                          maxLength: 300,
                          autofocus: authed,
                          enabled: authed,
                          decoration: const InputDecoration(
                            hintText: 'اكتب ردك بصدق — هويتك لن تظهر',
                          ),
                        ),
                        if (!authed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.moment.withValues(alpha: 0.08),
                              border: Border.all(
                                  color: colors.moment
                                      .withValues(alpha: 0.25)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              Icon(Icons.lock_outline,
                                  size: 16, color: colors.moment),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'سجّل دخولك للرد على هذه المرآة',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.login),
                                child: const Text('دخول'),
                              ),
                            ]),
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.danger.withValues(alpha: 0.10),
                              border: Border.all(
                                  color: colors.danger
                                      .withValues(alpha: 0.30)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              Icon(Icons.error_outline,
                                  color: colors.danger, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_error!,
                                    style: TextStyle(
                                        color: colors.danger,
                                        fontSize: 13)),
                              ),
                            ]),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'أرسل ردي',
                          icon: Icons.send_rounded,
                          loading: _sending,
                          onPressed: authed ? _send : null,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.mirror, required this.colors});
  final PublicMirrorDto mirror;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Row(
        children: [
          AppAvatar(
            url: mediaUrl(mirror.ownerAvatarPath),
            initials: mirror.ownerDisplayName ?? mirror.ownerUsername,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرآة من',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mirror.ownerDisplayName ?? '@${mirror.ownerUsername}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sent extends StatelessWidget {
  const _Sent({required this.colors});
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 24, top: 60),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(Icons.check_circle_outline,
                  size: 42, color: colors.success)
              .animate()
              .scale(duration: 320.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(delay: 100.ms, duration: 900.ms),
        ),
        Text(
          'تم إرسال ردك',
          textAlign: TextAlign.center,
          style: context.textStyles.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'كلماتك ستضيف لسحابة الكلمات التي يراها صاحب المرآة. شكراً لصدقك 🌙',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'عودة للرئيسية',
          onPressed: () => GoRouter.of(context).go(AppRoutes.feed),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}
