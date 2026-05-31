import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_theme.dart';

enum LegalKind { terms, privacy, contentPolicy }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.kind});
  final LegalKind kind;

  String get _title => switch (kind) {
        LegalKind.terms => 'شروط الاستخدام',
        LegalKind.privacy => 'سياسة الخصوصية',
        LegalKind.contentPolicy => 'سياسة المحتوى',
      };

  String get _webUrl => switch (kind) {
        LegalKind.terms => 'https://sarhny.com/ar/terms',
        LegalKind.privacy => 'https://sarhny.com/ar/privacy',
        LegalKind.contentPolicy => 'https://sarhny.com/ar/content-policy',
      };

  String get _summary => switch (kind) {
        LegalKind.terms =>
          'بانضمامك إلى صارحني توافق على الالتزام بهذه الشروط:\n\n'
              '• العمر: التطبيق للبالغين (١٨ سنة فأكثر) فقط. أي حساب يتبين أنه لقاصر سيُحذف.\n\n'
              '• المحتوى: تلتزم بنشر محتوى لا يخالف القانون أو يحرّض على الإيذاء، ولا يحتوي على ابتزاز أو إباحية أو خطاب كراهية.\n\n'
              '• الرسائل المجهولة: تتفهم أن منصتنا تتيح إرسال رسائل مجهولة، وأنك مسؤول عن قراراتك في قبولها أو الإبلاغ عنها.\n\n'
              '• الحساب: مسؤوليتك حماية بريدك وكلمة مرورك. صارحني لن يطلب منك كلمة المرور أبداً.\n\n'
              '• التوقف عن الخدمة: نحتفظ بحق إيقاف أي حساب يخالف هذه الشروط دون إشعار مسبق.\n\n'
              '• القانون المعمول به: قوانين المملكة العربية السعودية تحكم استخدامك للتطبيق.\n\n'
              'لقراءة النسخة الكاملة والمحدّثة، افتح الرابط أدناه.',
        LegalKind.privacy =>
          'في صارحني، خصوصيتك جوهر تجربتنا:\n\n'
              '• ما نجمعه: البريد، اسم المستخدم، الصور والنصوص اللي تنشرها، عنوان IP عند الإرسال (لمكافحة الإساءة فقط).\n\n'
              '• ما لا نجمعه: لا نجمع جهات الاتصال، لا الموقع الدقيق، لا تاريخ التصفح خارج التطبيق.\n\n'
              '• الرسائل المجهولة: لا تظهر هوية المرسل لك أو لأي مستخدم آخر. نحتفظ بـ IP hash داخلياً لمدة ٣٠ يوماً لأغراض الإبلاغ القانوني فقط.\n\n'
              '• الإشعارات: لا نرسل إشعارات تسويقية. كل الإشعارات مرتبطة بنشاط داخل حسابك.\n\n'
              '• مشاركة البيانات: لا نبيع أي بيانات لأي طرف ثالث. نشارك فقط:\n'
              '  - عند طلب قضائي رسمي.\n'
              '  - مع مزودي البنية التحتية (السيرفر، التخزين السحابي) لتشغيل الخدمة.\n\n'
              '• حقوقك: تستطيع طلب نسخة من بياناتك أو حذف حسابك نهائياً من شاشة الإعدادات.\n\n'
              '• الأطفال: التطبيق ممنوع لمن دون ١٨ سنة. لو علمنا بحساب قاصر، نحذفه فوراً.\n\n'
              'للنسخة القانونية المفصّلة، افتح الرابط أدناه.',
        LegalKind.contentPolicy =>
          'كل المحتوى على صارحني يخضع لهذه السياسة:\n\n'
              '✓ مسموح: التعبير عن الرأي، الأسئلة الصادقة، الصور الشخصية المحتشمة، الفنّ، الأفكار التأملية.\n\n'
              '✗ ممنوع وفوراً يُحذف:\n'
              '• المحتوى الإباحي أو شبه الإباحي بأي شكل.\n'
              '• خطاب الكراهية ضد دين، عرق، أو جنس.\n'
              '• الابتزاز أو التهديد.\n'
              '• الترويج للعنف أو الإرهاب أو المخدرات.\n'
              '• كل ما يكشف هوية قاصر أو يستهدف القاصرين.\n'
              '• الإعلانات والروابط التسويقية المتطفلة.\n'
              '• انتحال شخصية الآخرين.\n\n'
              'نستخدم خوارزميات تعلّم آلي + مراجعة بشرية لرصد المخالفات. الإبلاغ متاح لكل المستخدمين من زر "إبلاغ" على أي منشور أو رسالة.',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.moment, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'آخر تحديث: نوفمبر 2025',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _summary,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('قراءة النسخة الكاملة على الموقع'),
            onPressed: () => launchUrl(
              Uri.parse(_webUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
