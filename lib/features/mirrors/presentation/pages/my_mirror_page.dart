import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/mirror_dto.dart';
import '../providers/mirrors_provider.dart';

class MyMirrorPage extends ConsumerWidget {
  const MyMirrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final mirrors = ref.watch(myMirrorsProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('المرايا')),
      bottomNavigationBar: const AppBottomNav(active: 3),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.mind,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('مرآة جديدة'),
        onPressed: () => _showCreateSheet(context, ref),
      ),
      body: RefreshIndicator(
        color: colors.mind,
        onRefresh: () async {
          ref.invalidate(myMirrorsProvider);
          await ref.read(myMirrorsProvider.future);
        },
        child: mirrors.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(myMirrorsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.auto_awesome_outlined,
                  title: 'لا توجد مرايا بعد',
                  subtitle: 'أنشئ سؤالاً ودَع الناس يجيبون بإخلاص',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: list.length,
              itemBuilder: (_, i) => _MirrorCard(mirror: list[i]),
            );
          },
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateMirrorSheet(ref: ref),
    );
  }
}

class _MirrorCard extends StatelessWidget {
  const _MirrorCard({required this.mirror});
  final MirrorDto mirror;

  String get _shareUrl => 'https://sarhny.com/mirror/${mirror.shareToken}';

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.mind.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '🪞 مرآة',
                  style: TextStyle(
                    color: colors.mind,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${mirror.responseCount} ردًا',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            mirror.questionText,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          if (mirror.wordCloud.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WordCloud(entries: mirror.wordCloud, colors: colors),
          ],
          if (mirror.recentResponses.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...mirror.recentResponses.take(3).map((r) => Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    border:
                        Border.all(color: colors.border, width: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('نسخ الرابط'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _shareUrl));
                  Fluttertoast.showToast(msg: 'تم النسخ');
                },
              ),
              const SizedBox(width: 8),
              Builder(builder: (btnCtx) {
                return FilledButton.icon(
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('مشاركة'),
                  style:
                      FilledButton.styleFrom(backgroundColor: colors.mind),
                  onPressed: () async {
                    // sharePositionOrigin is required on iPad (else the popover
                    // has nowhere to anchor). Passing it on every platform is a
                    // no-op everywhere else.
                    final box = btnCtx.findRenderObject() as RenderBox?;
                    try {
                      await Share.share(
                        'شارك معي إجابتك على هذه المرآة:\n$_shareUrl',
                        subject: 'صارحني — مرآة',
                        sharePositionOrigin: box == null
                            ? null
                            : box.localToGlobal(Offset.zero) & box.size,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'تعذّر فتح المشاركة');
                    }
                  },
                );
              }),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _WordCloud extends StatelessWidget {
  const _WordCloud({required this.entries, required this.colors});
  final List<WordCloudEntry> entries;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final maxC = entries.first.count.clamp(1, 9999);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.take(20).map((e) {
        final scale = (e.count / maxC).clamp(0.4, 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.mind.withValues(alpha: 0.08 + 0.10 * scale),
            border: Border.all(
              color: colors.mind.withValues(alpha: 0.25 + 0.40 * scale),
              width: 0.6,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            e.word,
            style: TextStyle(
              color: colors.mind,
              fontSize: 12 + 4 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CreateMirrorSheet extends ConsumerStatefulWidget {
  const _CreateMirrorSheet({required this.ref});
  final WidgetRef ref;
  @override
  ConsumerState<_CreateMirrorSheet> createState() =>
      _CreateMirrorSheetState();
}

class _CreateMirrorSheetState extends ConsumerState<_CreateMirrorSheet> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final txt = _ctrl.text.trim();
    if (txt.length < 5 || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(mirrorsRepositoryProvider).create(txt);
      ref.invalidate(myMirrorsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'تم إنشاء المرآة');
      }
    } on ValidationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الإنشاء');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              'سؤال المرآة',
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'سؤال موجَّه يقصد كشف الذات — الردود مجهولة وتبني سحابة كلمات.',
              style:
                  TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              minLines: 2,
              maxLines: 5,
              maxLength: 300,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'مثلاً: ما الذي يجعلك فخوراً بنفسك؟',
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'إنشاء المرآة',
              onPressed: _submit,
              loading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}
