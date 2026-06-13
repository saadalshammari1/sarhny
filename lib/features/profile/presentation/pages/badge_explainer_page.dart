import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// What a single badge explainer screen displays. Driven by the badge kind
/// the user tapped on the profile so we can render one focused page instead
/// of three near-identical pages.
enum BadgeKind { crystals, streak, mirrors }

class BadgeExplainerPage extends StatelessWidget {
  const BadgeExplainerPage({super.key, required this.kind});

  factory BadgeExplainerPage.fromName(String name) {
    return BadgeExplainerPage(
      kind: switch (name) {
        'crystals' => BadgeKind.crystals,
        'streak' => BadgeKind.streak,
        'mirrors' => BadgeKind.mirrors,
        _ => BadgeKind.crystals,
      },
    );
  }

  final BadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final (icon, accent, title, lead, steps, tip) = _content(colors);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'كيف تحصل عليها',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          for (final step in steps) ...[
            _StepRow(text: step, accent: accent, colors: colors),
            const SizedBox(height: 8),
          ],
          if (tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  (IconData, Color, String, String, List<String>, String?) _content(
      SarhnyColors c) {
    switch (kind) {
      case BadgeKind.crystals:
        return (
          Icons.diamond_outlined,
          c.crystal,
          'البلورات ✦',
          'البلورات هي منشوراتك التي صمدت ٢٤ ساعة ونالت تفاعلاً صادقاً، فتحوّلت من لحظة عابرة إلى أثر دائم.',
          <String>[
            'انشر شيئاً يستحق النقاش — لحظة، صورة، أو فكرة.',
            'كل تفاعل (إعجاب، رد) يرفع جاذبية المنشور.',
            'عند الوصول لعتبة التبلور قبل انتهاء الـ ٢٤ ساعة → يصبح ✦ دائماً ويُحفظ في بلوراتك.',
            'منشورات بدون تفاعل تختفي بهدوء بعد ٢٤ ساعة (هذا ما يجعل البلورة قيّمة).',
          ],
          'البلورات تظهر للزائر في بروفايلك كدليل على بصمتك. اطرح ما يصمد، لا ما يكثر.',
        );
      case BadgeKind.streak:
        return (
          Icons.local_fire_department_outlined,
          c.moment,
          'الوهج 🔥',
          'الوهج هو سلسلة أيامك المتتالية في صارحني. كل يوم تنشر فيه يضيف لومة لشعلتك.',
          <String>[
            'افتح التطبيق وانشر منشوراً واحداً على الأقل كل ٢٤ ساعة.',
            'الوهج يحفظ تسلسلك حتى ٤٨ ساعة كحدّ أقصى للتنفّس.',
            'كلما طالت السلسلة كلما أصبح وهجك أنبل وأبرز في مرئيات بروفايلك.',
            'كسر السلسلة يصفّر العدّاد — لكن لا يمحو ما بنيته من بلورات.',
          ],
          'الوهج لا يقيس الجودة بل الإخلاص. اكتب قليلاً كل يوم خير من كثير في يوم.',
        );
      case BadgeKind.mirrors:
        return (
          Icons.auto_awesome_outlined,
          c.mind,
          'المرايا 🪞',
          'المرآة سؤال مفتوح تطرحه ودَع الناس يصفونك من خلاله بإخلاص. تتراكم الإجابات لتشكّل سحابة تعكس كيف يراك من حولك.',
          <String>[
            'اضغط على تبويب «المرايا» وأنشئ سؤالاً تأمّلياً (مثل: ما أكثر ما يميّزني؟).',
            'شارك رابط المرآة مع أصدقائك أو على حسابك في تطبيق آخر.',
            'تأتيك الإجابات مجهولة — لا تعرف من قال ماذا، فيقول الناس بصراحة.',
            'كل مرآة تكسبك بادج 🪞 يظهر في بروفايلك ويرفع ثقلك في صارحني.',
          ],
          'المرايا تعمل أحسن مع أسئلة محدّدة لا فضفاضة. اسأل عمّا تريد فعلاً أن تعرفه.',
        );
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.text,
    required this.accent,
    required this.colors,
  });
  final String text;
  final Color accent;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
