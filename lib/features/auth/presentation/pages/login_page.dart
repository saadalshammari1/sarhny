import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(
        usernameOrEmail: _userCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await ref.read(authStateProvider.notifier).markAuthenticated(
            userId: result.userId,
            username: result.username,
          );
      if (mounted) context.go(AppRoutes.feed);
    } on UnauthorizedException {
      setState(() => _serverError = 'بيانات الدخول غير صحيحة');
    } on ValidationException catch (e) {
      setState(() => _serverError = e.message);
    } on NetworkException {
      setState(() => _serverError = 'تعذّر الاتصال بالخادم');
    } on TimeoutException {
      setState(() => _serverError = 'انقطع الاتصال');
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(() => _serverError = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(colors: colors),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _userCtrl,
                      label: 'اسم المستخدم أو البريد',
                      hint: 'مثلاً: ssarhny',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passCtrl,
                      label: 'كلمة المرور',
                      prefixIcon: Icons.lock_outline,
                      obscure: _obscure,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'الحقل مطلوب' : null,
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                    ),
                    if (_serverError != null) ...[
                      const SizedBox(height: 8),
                      _ErrorBanner(message: _serverError!, colors: colors),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'دخول',
                      onPressed: _submit,
                      loading: _submitting,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            'أنشئ حساباً',
                            style: TextStyle(
                              color: colors.moment,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colors.moment.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text('صـ', style: TextStyle(
            color: colors.moment,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          )),
        ),
        const SizedBox(height: 16),
        Text(
          'أهلاً بعودتك',
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'سجّل دخولك للمتابعة في صارحني',
          style: TextStyle(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.colors});
  final String message;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.10),
        border: Border.all(color: colors.danger.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
