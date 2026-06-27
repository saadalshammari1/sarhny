import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/profile_provider.dart';

class AnonAskForm extends ConsumerStatefulWidget {
  const AnonAskForm({super.key, required this.username});
  final String username;

  @override
  ConsumerState<AnonAskForm> createState() => _AnonAskFormState();
}

class _AnonAskFormState extends ConsumerState<AnonAskForm> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final txt = _ctrl.text.trim();
    if (txt.isEmpty || _sending) return;
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || auth.status != AuthStatus.authenticated) {
      setState(() => _error = l.profileAnonLoginRequired);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(profileRepositoryProvider).sendAnonymous(
            recipientUsername: widget.username,
            message: txt,
          );
      _ctrl.clear();
      if (mounted) {
        Fluttertoast.showToast(msg: l.profileAnonSent);
      }
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on RateLimitException {
      setState(() => _error = l.profileAnonRateLimited);
    } on ForbiddenException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l.profileAnonSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.moment.withValues(alpha: 0.06),
        border: Border.all(color: colors.moment.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.visibility_off_outlined,
                color: colors.moment, size: 18),
            const SizedBox(width: 6),
            Text(
              l.profileAnonTitle,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            l.profileAnonSubtitle,
            style:
                TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: l.profileAnonHint,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: colors.danger, fontSize: 12),
              ),
            ),
          AppButton(
            label: l.profileAnonSend,
            onPressed: _send,
            loading: _sending,
          ),
        ],
      ),
    );
  }
}
