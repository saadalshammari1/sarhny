import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../data/article_repository.dart';
import '../providers/article_providers.dart';

/// Backend returns dates as "YYYY-MM-DD HH:MM:SS"; defensively grab the
/// date portion without assuming length to avoid RangeError on edge cases
/// (empty/null/unexpectedly-short strings).
String _safeDate(String? s) {
  if (s == null || s.isEmpty) return '';
  return s.length >= 10 ? s.substring(0, 10) : s;
}

/// "شخصيتي" landing page — single source of truth for the article feature.
///
/// Flow at a glance:
///   - User has < 15 real answers → show progress + nudge to answer more
///   - User has ≥ 15 answers and no article yet → show big Generate CTA
///   - User has article + in cooldown → show countdown to next regeneration
///   - User has article + cooldown passed → enable Generate again
///   - History list lives under the live article (collapsible)
class MyArticlePage extends ConsumerWidget {
  const MyArticlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final eligibility = ref.watch(articleEligibilityProvider);
    final article = ref.watch(myArticleProvider);
    final history = ref.watch(articleHistoryProvider);

    // Wrap every state in a scrollable so RefreshIndicator always has a
    // valid child + the Scaffold/AppBar always renders. White screens were
    // happening when the body returned a non-scrollable Center on first
    // load, which sometimes left the body slot blank under release builds.
    Widget bodyChild;
    if (eligibility.isLoading || (eligibility.hasValue && article.isLoading)) {
      bodyChild = const _ScrollableCenter(child: CircularProgressIndicator());
    } else if (eligibility.hasError) {
      bodyChild = _ScrollableCenter(
        child: _ErrorBox(
          message: eligibility.error.toString(),
          onRetry: () => ref.invalidate(articleEligibilityProvider),
        ),
      );
    } else if (article.hasError) {
      bodyChild = _ScrollableCenter(
        child: _ErrorBox(
          message: article.error.toString(),
          onRetry: () => ref.invalidate(myArticleProvider),
        ),
      );
    } else {
      bodyChild = _Body(
        eligibility: eligibility.requireValue,
        article: article.valueOrNull,
        history: history.value ?? const [],
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('شخصيتي ✨')),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(articleEligibilityProvider);
          ref.invalidate(myArticleProvider);
          ref.invalidate(articleHistoryProvider);
        },
        child: bodyChild,
      ),
    );
  }
}

/// Tiny helper — RefreshIndicator needs a Scrollable child to actually
/// pull-to-refresh. Wrapping the spinner/error in a ListView keeps the
/// gesture working and prevents the "blank body" failure mode.
class _ScrollableCenter extends StatelessWidget {
  const _ScrollableCenter({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.eligibility, this.article, required this.history});
  final ArticleEligibility eligibility;
  final UserArticle? article;
  final List<ArticleHistoryItem> history;
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await ref.read(articleRepositoryProvider).generate();
      ref.invalidate(myArticleProvider);
      ref.invalidate(articleEligibilityProvider);
      ref.invalidate(articleHistoryProvider);
      Fluttertoast.showToast(msg: 'تم إنشاء مقالتك ✨');
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الإنشاء');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final e = widget.eligibility;
    final a = widget.article;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _HeaderCard(eligibility: e),
        const SizedBox(height: 14),
        _CtaCard(
          eligibility: e,
          hasArticle: a != null,
          busy: _generating,
          onGenerate: _generate,
        ),
        if (a != null) ...[
          const SizedBox(height: 22),
          Text(
            'مقالتي الحالية',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _ArticleCard(article: a),
        ],
        if (widget.history.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'الأرشيف · مقالات سابقة (${widget.history.length})',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          for (final h in widget.history) ...[
            _HistoryCard(item: h),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.eligibility});
  final ArticleEligibility eligibility;
  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          c.crystal.withValues(alpha: 0.10),
          c.mind.withValues(alpha: 0.10),
        ]),
        border: Border.all(color: c.crystal.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('✨', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'مقالتك الشخصية',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'تُكتب مقالتك من إجاباتك العامّة على الرسائل المجهولة. كلما أجبت أكثر بصدق، كلما عرفك الذكاء أكثر — وكتب عنك أصدق.',
            style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── CTA / countdown / progress ─────────────────────────────────────────────

class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.eligibility,
    required this.hasArticle,
    required this.busy,
    required this.onGenerate,
  });
  final ArticleEligibility eligibility;
  final bool hasArticle;
  final bool busy;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    final e = eligibility;

    // 1) Cooldown — already has article + within 30 days.
    if (e.daysRemaining > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border, width: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(Icons.hourglass_bottom_rounded, color: c.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'المقالة التالية',
                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
              ),
            ]),
            const SizedBox(height: 10),
            Text(
              'باقي ${e.daysRemaining} يوم على إنشاء مقالتك التالية.',
              style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                // Guard against backend returning cooldownDays=0 (would
                // produce NaN and silently break the indicator).
                value: e.cooldownDays > 0
                    ? ((e.cooldownDays - e.daysRemaining) / e.cooldownDays)
                        .clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 6,
                backgroundColor: c.elevated,
                valueColor: AlwaysStoppedAnimation<Color>(c.crystal),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'كل ${e.cooldownDays} يوم تستطيع إنشاء نسخة جديدة. النسخة الجديدة ستُبنى من إجاباتك الأحدث.',
              style: TextStyle(color: c.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // 2) Not enough real answers yet.
    if (e.realAnswersCount < e.minRequired) {
      final percent = e.realAnswersCount / e.minRequired;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border, width: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                'تقدّمك',
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${e.realAnswersCount}/${e.minRequired}',
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: c.elevated,
                valueColor: AlwaysStoppedAnimation<Color>(c.crystal),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تحتاج ${e.minRequired - e.realAnswersCount} إجابة عامّة إضافية على رسائل مجهولة لتفتح مقالتك. هذه الإجابات هي ما يجعل المقالة تشبهك حقاً.',
              style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      );
    }

    // 3) Eligible — show the big Generate button.
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: c.crystal,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: busy ? null : onGenerate,
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(busy
            ? 'يجري الإنشاء…'
            : hasArticle
                ? 'أنشئ نسخة جديدة من مقالتي'
                : 'اكتب مقالتي الآن ✨'),
      ),
    );
  }
}

// ── Live article card (with edit/publish/delete) ───────────────────────────

class _ArticleCard extends ConsumerStatefulWidget {
  const _ArticleCard({required this.article});
  final UserArticle article;
  @override
  ConsumerState<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<_ArticleCard> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.article.content);
  bool _editing = false;
  bool _busy = false;
  bool _expanded = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(articleRepositoryProvider).edit(_ctrl.text.trim());
      ref.invalidate(myArticleProvider);
      setState(() => _editing = false);
      Fluttertoast.showToast(msg: 'تم الحفظ');
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
          'بعد 24 ساعة من النشر تصبح المقالة متاحة لأي شخص على رابط عام في المدوّنة. تستطيع حذفها متى شئت.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('انشر')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(articleRepositoryProvider).publish();
      ref.invalidate(myArticleProvider);
      Fluttertoast.showToast(msg: 'سَتظهر بعد 24 ساعة 🌙');
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
        content: const Text('سيتم حذف المقالة الحالية. ستظل النسخ السابقة محفوظة في الأرشيف.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
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
      ref.invalidate(myArticleProvider);
      Fluttertoast.showToast(msg: 'تم الحذف');
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الحذف');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    final a = widget.article;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: a.isPublished
                        ? c.crystal.withValues(alpha: 0.15)
                        : c.elevated,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      a.isPublished ? Icons.public : Icons.lock_outline,
                      size: 12,
                      color: a.isPublished ? c.crystal : c.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      a.isPublished ? 'منشورة' : 'خاصة',
                      style: TextStyle(
                        color: a.isPublished ? c.crystal : c.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ]),
                ),
                if (a.generatedAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _safeDate(a.generatedAt),
                    style: TextStyle(color: c.textSecondary, fontSize: 11),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: _editing
                  ? TextField(
                      controller: _ctrl,
                      maxLines: null,
                      minLines: 8,
                      style: TextStyle(color: c.textPrimary, height: 1.7, fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  : SelectableText(
                      a.content,
                      style: TextStyle(color: c.textPrimary, height: 1.8, fontSize: 15),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _editing
                    ? [
                        OutlinedButton(
                          onPressed: _busy ? null : () => setState(() => _editing = false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton.icon(
                          onPressed: _busy ? null : _save,
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: const Text('حفظ'),
                        ),
                      ]
                    : [
                        if (!a.isPublished)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: c.crystal),
                            onPressed: _busy ? null : _publish,
                            icon: const Icon(Icons.public, size: 16),
                            label: const Text('نشرها'),
                          ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : () => setState(() => _editing = true),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('تعديل'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _delete,
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('حذف'),
                        ),
                      ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── History card ───────────────────────────────────────────────────────────

class _HistoryCard extends ConsumerStatefulWidget {
  const _HistoryCard({required this.item});
  final ArticleHistoryItem item;
  @override
  ConsumerState<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends ConsumerState<_HistoryCard> {
  bool _expanded = false;

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف من الأرشيف'),
        content: const Text('سيُحذف هذا الإصدار نهائياً من أرشيفك.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(articleRepositoryProvider).deleteHistory(widget.item.id);
      ref.invalidate(articleHistoryProvider);
      Fluttertoast.showToast(msg: 'تم الحذف');
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الحذف');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sarhnyColors;
    final h = widget.item;
    final preview = h.content.length > 120 ? '${h.content.substring(0, 120)}…' : h.content;
    return Container(
      decoration: BoxDecoration(
        color: c.elevated,
        border: Border.all(color: c.border, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: c.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (h.generatedAt != null)
                          Text(
                            _safeDate(h.generatedAt),
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (!_expanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            preview,
                            style: TextStyle(color: c.textPrimary, fontSize: 13, height: 1.6),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (h.wasPublished)
                    Icon(Icons.public, size: 14, color: c.crystal),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: SelectableText(
                h.content,
                style: TextStyle(color: c.textPrimary, fontSize: 13.5, height: 1.7),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('حذف من الأرشيف'),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

// ── Error fallback ─────────────────────────────────────────────────────────

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
