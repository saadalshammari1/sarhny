import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../data/article_repository.dart';
import '../providers/article_providers.dart';

/// Landing page for the "شخصيتي" feature. Branches on state:
///  - No article yet & questionnaire incomplete → show progress + CTA to answer
///  - No article yet & ready → show big "Generate" button
///  - Article generated → show it + edit/publish/delete actions
class MyArticlePage extends ConsumerWidget {
  const MyArticlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final article = ref.watch(myArticleProvider);
    final progress = ref.watch(questionnaireProgressProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('شخصيتي ✨'),
      ),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(myArticleProvider);
          ref.invalidate(questionnaireProgressProvider);
          ref.invalidate(questionnaireMyAnswersProvider);
        },
        child: article.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBox(
              message: e.toString(),
              onRetry: () => ref.invalidate(myArticleProvider)),
          data: (existing) {
            if (existing != null) {
              return _ArticleView(article: existing);
            }
            return progress.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBox(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(questionnaireProgressProvider)),
              data: (p) => _IntroAndProgress(progress: p),
            );
          },
        ),
      ),
    );
  }
}

class _IntroAndProgress extends ConsumerStatefulWidget {
  const _IntroAndProgress({required this.progress});
  final QuestionnaireProgress progress;
  @override
  ConsumerState<_IntroAndProgress> createState() => _IntroAndProgressState();
}

class _IntroAndProgressState extends ConsumerState<_IntroAndProgress> {
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await ref.read(articleRepositoryProvider).generate();
      ref.invalidate(myArticleProvider);
      Fluttertoast.showToast(msg: 'تم إنشاء مقالتك ✨');
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الإنشاء، حاول لاحقاً');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final p = widget.progress;
    final percent = p.total == 0 ? 0.0 : p.answered / p.total;
    final isComplete = p.canGenerate;
    final inCooldown = p.daysRemaining > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.crystal.withValues(alpha: 0.10),
                colors.mind.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(color: colors.crystal.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'مقالتك الشخصية',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                'أجب على ${p.minRequired} سؤالاً عميقاً عن نفسك، وسيكتب الذكاء الاصطناعي مقالة عربية تصفك بصدق — مبنية فقط على إجاباتك. تستطيع تعديلها، أو نشرها للعموم، أو إبقاءها خاصة.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Progress
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border, width: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'تقدّمك',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${p.answered}/${p.total}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: colors.elevated,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.crystal),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/me/questionnaire'),
                  icon: const Icon(Icons.edit_note),
                  label: Text(
                    p.answered == 0 ? 'ابدأ الإجابة' : 'متابعة الإجابات',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Generate state
        if (inCooldown)
          _Card(
            colors: colors,
            child: Row(children: [
              Icon(Icons.hourglass_bottom, color: colors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'يمكنك إعادة إنشاء مقالتك بعد ${p.daysRemaining} يوم.',
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                ),
              ),
            ]),
          )
        else if (isComplete)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.crystal,
              ),
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_generating ? 'يجري الإنشاء…' : 'اكتب مقالتي الآن ✨'),
            ),
          )
        else
          _Card(
            colors: colors,
            child: Text(
              'أكمل الإجابة على ${p.minRequired - p.answered} سؤالاً أخرى لفتح زرّ الإنشاء.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'تستطيع تعديل إجاباتك في أي وقت. كل إعادة إنشاء (مرة كل ${p.cooldownDays} يوم) تبني على آخر إجاباتك.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ArticleView extends ConsumerStatefulWidget {
  const _ArticleView({required this.article});
  final UserArticle article;
  @override
  ConsumerState<_ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends ConsumerState<_ArticleView> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.article.content);
  bool _editing = false;
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    setState(() => _busy = true);
    try {
      await ref.read(articleRepositoryProvider).edit(_ctrl.text.trim());
      Fluttertoast.showToast(msg: 'تم الحفظ');
      ref.invalidate(myArticleProvider);
      setState(() => _editing = false);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الحفظ');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نشر المقالة للعموم'),
        content: const Text(
          'بعد ٢٤ ساعة من النشر، ستصبح مقالتك متاحة على رابط عام: /p/username. أي شخص يستطيع رؤيتها ومشاركتها وفهرستها في محركات البحث. تستطيع حذفها متى شئت.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('انشر'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(articleRepositoryProvider).publish();
      Fluttertoast.showToast(msg: 'تم — ستظهر بعد ٢٤ ساعة');
      ref.invalidate(myArticleProvider);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر النشر');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المقالة'),
        content: const Text('ستُحذف مقالتك نهائياً. تستطيع إنشاء مقالة جديدة بعد ذلك (مع احترام مهلة ٣٠ يوم بين الإنشاءات).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(articleRepositoryProvider).deleteArticle();
      Fluttertoast.showToast(msg: 'تم الحذف');
      ref.invalidate(myArticleProvider);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الحذف');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final a = widget.article;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: a.isPublished
                ? colors.crystal.withValues(alpha: 0.10)
                : colors.elevated,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                a.isPublished ? Icons.public : Icons.lock_outline,
                size: 14,
                color: a.isPublished ? colors.crystal : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                a.isPublished ? 'منشورة للعموم' : 'خاصة بك فقط',
                style: TextStyle(
                  color: a.isPublished ? colors.crystal : colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_editing)
          TextField(
            controller: _ctrl,
            maxLines: null,
            minLines: 12,
            style: TextStyle(color: colors.textPrimary, height: 1.7, fontSize: 15),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        else
          SelectableText(
            a.content,
            style: TextStyle(color: colors.textPrimary, height: 1.8, fontSize: 16),
          ),
        const SizedBox(height: 20),
        if (_editing)
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => setState(() => _editing = false),
                child: const Text('إلغاء'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _saveEdit,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('حفظ التعديل'),
              ),
            ),
          ])
        else ...[
          if (!a.isPublished)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colors.crystal),
                onPressed: _busy ? null : _publish,
                icon: const Icon(Icons.public),
                label: const Text('نشرها للعموم'),
              ),
            ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('تعديل'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('حذف'),
              ),
            ),
          ]),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.colors, required this.child});
  final SarhnyColors colors;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
