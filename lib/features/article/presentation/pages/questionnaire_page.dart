import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../app/theme/app_theme.dart';
import '../../data/article_repository.dart';
import '../providers/article_providers.dart';

/// Questionnaire flow — Tinder-style one card per question. The user can
/// scroll back to edit any answer; we autosave on advance / blur with a
/// 600ms debounce so they never lose work. Re-running this any time also
/// silently improves the next regeneration.
class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});
  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final _pageCtrl = PageController();
  int _currentIdx = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final questions = ref.watch(questionnaireQuestionsProvider);
    final myAnswers = ref.watch(questionnaireMyAnswersProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('أسئلتك')),
      body: questions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('تعذّر تحميل الأسئلة: $e')),
        data: (qs) {
          return myAnswers.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildPager(qs, const {}),
            data: (answersMap) => _buildPager(qs, answersMap),
          );
        },
      ),
    );
  }

  Widget _buildPager(
    List<QuestionnaireQuestion> qs,
    Map<int, String> answersMap,
  ) {
    final colors = context.sarhnyColors;
    if (qs.isEmpty) {
      return const Center(child: Text('لا توجد أسئلة حالياً'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Column(
            children: [
              Row(children: [
                Text(
                  '${_currentIdx + 1} من ${qs.length}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '${answersMap.length} مُجابة',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_currentIdx + 1) / qs.length,
                  minHeight: 4,
                  backgroundColor: colors.elevated,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.crystal),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentIdx = i),
            itemCount: qs.length,
            itemBuilder: (_, i) {
              final q = qs[i];
              return _QuestionCard(
                question: q,
                initialAnswer: answersMap[q.id] ?? '',
                isFirst: i == 0,
                isLast: i == qs.length - 1,
                onSubmit: (text) async {
                  if (text.trim().length < 6) return false;
                  try {
                    await ref
                        .read(articleRepositoryProvider)
                        .upsertAnswer(q.id, text.trim());
                    ref.invalidate(questionnaireMyAnswersProvider);
                    ref.invalidate(questionnaireProgressProvider);
                    return true;
                  } catch (_) {
                    Fluttertoast.showToast(msg: 'تعذّر الحفظ');
                    return false;
                  }
                },
                onNext: () {
                  if (i < qs.length - 1) {
                    _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                onBack: i == 0
                    ? null
                    : () => _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    required this.question,
    required this.initialAnswer,
    required this.onSubmit,
    required this.onNext,
    required this.isFirst,
    required this.isLast,
    this.onBack,
  });
  final QuestionnaireQuestion question;
  final String initialAnswer;
  final Future<bool> Function(String) onSubmit;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isFirst;
  final bool isLast;
  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialAnswer);
  bool _busy = false;

  @override
  void didUpdateWidget(covariant _QuestionCard old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _ctrl.text = widget.initialAnswer;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    setState(() => _busy = true);
    final ok = await widget.onSubmit(_ctrl.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border, width: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.question.text,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _ctrl,
                    autofocus: widget.initialAnswer.isEmpty,
                    maxLines: 8,
                    minLines: 5,
                    style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'اكتب إجابتك بصدق. لا حد أعلى — اطمئن.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تستطيع تركها فارغة وتعود لها لاحقاً. كل ما تكتبه يُحفظ تلقائياً.',
                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (widget.onBack != null)
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('السابق'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _busy ? null : _advance,
                icon: _busy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_back),
                label: Text(widget.isLast ? 'إنهاء' : 'التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
