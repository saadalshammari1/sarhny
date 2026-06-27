import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

const _kReserved = {
  'login', 'logout', 'register', 'reset', 'password', 'dashboard', 'auth',
  'home', 'answers', 'comments', 'likes', 'notifications', 'questions',
  'settings', 'search', 'pages', 'contact', 'followers', 'users', 'stream',
  'feed', 'inbox', 'compose', 'mirrors', 'subscription', 'profile', 'shahed',
};

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  String _sex = 'male';
  bool _agreeAge18 = false;
  bool _agreeTerms = false;
  bool _obscure = true;
  bool _obscure2 = true;
  bool _submitting = false;
  String? _serverError;
  final Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeAge18) {
      setState(() =>
          _fieldErrors['agree_age_18'] = l.registerAgeConfirmError);
      return;
    }
    if (!_agreeTerms) {
      setState(() => _fieldErrors['agree'] = l.registerTermsError);
      return;
    }
    setState(() {
      _fieldErrors.clear();
      _submitting = true;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.register(
        name: _nameCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        passwordConfirmation: _pass2Ctrl.text,
        sex: _sex,
        agreeAge18: _agreeAge18,
      );
      await ref.read(authStateProvider.notifier).markAuthenticated(
            userId: result.userId,
            username: result.username,
          );
      if (mounted) context.go(AppRoutes.feed);
    } on ValidationException catch (e) {
      final mapped = <String, String>{};
      e.errors?.forEach((field, msgs) {
        mapped[field] = _humanize(field, msgs.first);
      });
      setState(() {
        _fieldErrors
          ..clear()
          ..addAll(mapped);
        if (mapped.isEmpty) _serverError = e.message;
      });
      _formKey.currentState!.validate();
    } on NetworkException {
      setState(() => _serverError = l.errorServerUnreachable);
    } on TimeoutException {
      setState(() => _serverError = l.errorConnectionLost);
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(() => _serverError = l.errorUnexpected);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _humanize(String field, String raw) {
    final l = AppLocalizations.of(context);
    final r = raw.toLowerCase();
    switch (field) {
      case 'username':
        if (r.contains('taken')) return l.registerUsernameTaken;
        if (r.contains('invalid') || r.contains('format')) {
          return l.registerUsernameFormat;
        }
        return l.registerUsernameInvalid;
      case 'email':
        if (r.contains('taken') || r.contains('already')) {
          return l.registerEmailTaken;
        }
        return l.registerEmailInvalid;
      case 'password':
        return l.registerPasswordWeak;
      case 'sex':
        return l.registerSexRequired;
      case 'agree_age_18':
        return l.registerAgeConfirmError;
      default:
        return raw;
    }
  }

  String? _validateUsername(String? v) {
    final l = AppLocalizations.of(context);
    final raw = (v ?? '').trim();
    if (raw.length < 3) return l.registerUsernameMin;
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(raw)) {
      return l.registerUsernameFormat;
    }
    if (_kReserved.contains(raw.toLowerCase())) return l.registerUsernameReserved;
    return _fieldErrors['username'];
  }

  String? _validateEmail(String? v) {
    final l = AppLocalizations.of(context);
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return l.fieldRequired;
    if (!raw.contains('@') || !raw.contains('.')) return l.registerEmailInvalidShort;
    return _fieldErrors['email'];
  }

  String? _validatePassword(String? v) {
    final l = AppLocalizations.of(context);
    if ((v ?? '').length < 8) return l.registerPasswordMin;
    return _fieldErrors['password'];
  }

  String? _validatePassword2(String? v) {
    final l = AppLocalizations.of(context);
    if (v != _passCtrl.text) return l.registerPasswordMismatch;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l.registerButton),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              colors.moment,
                              colors.moment.withValues(alpha: 0.72),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colors.moment.withValues(alpha: 0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '✨',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.registerJoinTitle,
                      textAlign: TextAlign.center,
                      style: context.textStyles.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.registerJoinSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _nameCtrl,
                      label: l.registerDisplayName,
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if ((v ?? '').trim().length < 2) {
                          return l.registerNameMin;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _userCtrl,
                      label: l.registerUsername,
                      hint: l.registerUsernameHint,
                      prefixIcon: Icons.alternate_email,
                      textInputAction: TextInputAction.next,
                      validator: _validateUsername,
                      onChanged: (_) {
                        if (_fieldErrors.containsKey('username')) {
                          setState(() => _fieldErrors.remove('username'));
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _emailCtrl,
                      label: l.registerEmail,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      onChanged: (_) {
                        if (_fieldErrors.containsKey('email')) {
                          setState(() => _fieldErrors.remove('email'));
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passCtrl,
                      label: l.registerPassword,
                      prefixIcon: Icons.lock_outline,
                      obscure: _obscure,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _pass2Ctrl,
                      label: l.registerPasswordConfirm,
                      prefixIcon: Icons.lock_outline,
                      obscure: _obscure2,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure2 = !_obscure2),
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                      validator: _validatePassword2,
                    ),
                    const SizedBox(height: 18),
                    _SexSelector(
                      value: _sex,
                      onChanged: (v) => setState(() => _sex = v),
                      colors: colors,
                    ),
                    const SizedBox(height: 18),
                    _CheckRow(
                      checked: _agreeAge18,
                      onChanged: (v) {
                        setState(() {
                          _agreeAge18 = v ?? false;
                          if (_agreeAge18) {
                            _fieldErrors.remove('agree_age_18');
                          }
                        });
                      },
                      label: l.registerAgeConfirm,
                      sub: l.registerAdultsOnly,
                      error: _fieldErrors['agree_age_18'],
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    _CheckRow(
                      checked: _agreeTerms,
                      onChanged: (v) {
                        setState(() {
                          _agreeTerms = v ?? false;
                          if (_agreeTerms) _fieldErrors.remove('agree');
                        });
                      },
                      label: l.registerAgreeTerms,
                      error: _fieldErrors['agree'],
                      colors: colors,
                    ),
                    if (_serverError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.1),
                          border: Border.all(
                              color: colors.danger.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline,
                              color: colors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_serverError!,
                                  style: TextStyle(
                                      color: colors.danger, fontSize: 13))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 18),
                    AppButton(
                      label: l.registerButton,
                      onPressed: _submit,
                      loading: _submitting,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l.registerHaveAccount} ',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            l.registerSignInCta,
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
              ).animate().fadeIn(duration: 350.ms),
            ),
          ),
        ),
      ),
    );
  }
}

class _SexSelector extends StatelessWidget {
  const _SexSelector({
    required this.value,
    required this.onChanged,
    required this.colors,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Text(
            l.registerGender,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _SexChip(
                label: l.registerGenderMale,
                icon: Icons.male,
                selected: value == 'male',
                onTap: () => onChanged('male'),
                colors: colors,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SexChip(
                label: l.registerGenderFemale,
                icon: Icons.female,
                selected: value == 'female',
                onTap: () => onChanged('female'),
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SexChip extends StatelessWidget {
  const _SexChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? colors.moment.withValues(alpha: 0.12)
              : colors.elevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.moment : colors.border,
            width: selected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? colors.moment : colors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.checked,
    required this.onChanged,
    required this.label,
    required this.colors,
    this.sub,
    this.error,
  });
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String? sub;
  final String? error;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(!checked),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: checked,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      if (sub != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            sub!,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 36, top: 2),
            child: Text(
              error!,
              style: TextStyle(color: colors.danger, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
