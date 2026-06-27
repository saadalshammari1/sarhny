import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/password_reset_repository.dart';

/// Reached via deep link `sarhny.com/auth/reset/confirm?token=…` after
/// the user taps the email link. The token comes in via query param.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});
  final String token;
  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  bool _obs1 = true;
  bool _obs2 = true;
  bool _busy = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = PasswordResetRepository(ref.read(dioClientProvider));
      await repo.confirmReset(
        token: widget.token,
        newPassword: _pwdCtrl.text,
      );
      if (mounted) setState(() => _done = true);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on NetworkException {
      setState(() => _error = l.errorServerUnreachable);
    } on ApiException catch (e) {
      setState(() => _error = e.message.contains('expired') ||
              e.message.contains('invalid')
          ? l.resetLinkExpired
          : e.message);
    } catch (_) {
      setState(() => _error = l.errorUnexpected);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l.resetTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _done
                  ? _Done(colors: colors)
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
                            child: Icon(Icons.password_rounded,
                                size: 32, color: colors.moment),
                          ),
                          Text(
                            l.resetHeading,
                            textAlign: TextAlign.center,
                            style: context.textStyles.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.resetSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: colors.textSecondary, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _pwdCtrl,
                            label: l.settingsPasswordNew,
                            prefixIcon: Icons.lock_outline,
                            obscure: _obs1,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obs1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obs1 = !_obs1),
                            ),
                            validator: (v) {
                              if ((v ?? '').length < 8) return l.registerPasswordMin;
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _pwd2Ctrl,
                            label: l.registerPasswordConfirm,
                            prefixIcon: Icons.lock_outline,
                            obscure: _obs2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obs2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obs2 = !_obs2),
                            ),
                            validator: (v) {
                              if (v != _pwdCtrl.text) return l.resetPasswordMismatch;
                              return null;
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
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
                            label: l.actionConfirm,
                            onPressed: _submit,
                            loading: _busy,
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

class _Done extends StatelessWidget {
  const _Done({required this.colors});
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
          child: Icon(Icons.check_circle_outline,
                  size: 40, color: colors.success)
              .animate()
              .scale(duration: 320.ms, curve: Curves.easeOutBack),
        ),
        Text(
          l.resetDoneTitle,
          textAlign: TextAlign.center,
          style: context.textStyles.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l.resetDoneBody,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: l.resetGoToLogin,
          onPressed: () => context.go(AppRoutes.login),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}
