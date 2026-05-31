import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/password_reset_repository.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = PasswordResetRepository(ref.read(dioClientProvider));
      await repo.requestReset(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } on NetworkException {
      setState(() => _error = 'تعذّر الاتصال بالخادم');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
        title: const Text('استعادة كلمة المرور'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _sent
                  ? _Success(email: _emailCtrl.text.trim())
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            margin: const EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  colors.moment.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.lock_reset_rounded,
                                size: 32, color: colors.moment),
                          ),
                          Text(
                            'نسيت كلمة المرور؟',
                            textAlign: TextAlign.center,
                            style: context.textStyles.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل بريدك المسجَّل، وسنرسل لك رابطاً لإعادة تعيين كلمة المرور خلال ساعة واحدة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'البريد الإلكتروني',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              final raw = (v ?? '').trim();
                              if (raw.isEmpty) return 'الحقل مطلوب';
                              if (!raw.contains('@') || !raw.contains('.')) {
                                return 'بريد غير صالح';
                              }
                              return null;
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    colors.danger.withValues(alpha: 0.10),
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
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'إرسال الرابط',
                            onPressed: _submit,
                            loading: _busy,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: Text(
                              'عودة لتسجيل الدخول',
                              style:
                                  TextStyle(color: colors.textSecondary),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          margin: const EdgeInsets.only(bottom: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.mark_email_read_outlined,
                  size: 38, color: colors.success)
              .animate()
              .scale(duration: 300.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(delay: 100.ms, duration: 800.ms),
        ),
        Text(
          'تحقّق من بريدك',
          textAlign: TextAlign.center,
          style: context.textStyles.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: colors.textSecondary, height: 1.6),
            children: [
              const TextSpan(text: 'لو هذا البريد مسجَّل، أرسلنا رابط الاستعادة إلى\n'),
              TextSpan(
                text: email,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\nتفقّد صندوق الرسائل (و"غير المرغوب فيه" أحياناً)'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'عودة لتسجيل الدخول',
          onPressed: () => context.go(AppRoutes.login),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}
