import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/api_providers.dart';

/// Hidden diagnostics page reachable via a long-press on the "نسيت كلمة المرور؟"
/// link in [LoginPage]. Useful for support when a user reports "connection lost".
///
/// Shows:
///   • Detected base URL (from .env or compiled default)
///   • DotEnv load status
///   • A "Test connection" button that pings GET /api/v1/help/features
///   • Last failure type + headers
class DiagnosticsPage extends ConsumerStatefulWidget {
  const DiagnosticsPage({super.key});
  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> {
  String? _result;
  bool _running = false;

  Future<void> _runTest() async {
    setState(() {
      _running = true;
      _result = null;
    });
    final dio = ref.read(dioClientProvider).raw;
    final buf = StringBuffer();
    buf.writeln('Base URL: ${dio.options.baseUrl}');
    buf.writeln('User-Agent: ${dio.options.headers['User-Agent']}');
    buf.writeln('Connect timeout: ${dio.options.connectTimeout?.inSeconds}s');
    buf.writeln('');
    try {
      final stopwatch = Stopwatch()..start();
      final resp = await dio.get('/api/v1/help/features');
      stopwatch.stop();
      buf.writeln('✅ Reach OK');
      buf.writeln('Status: ${resp.statusCode}');
      buf.writeln('Latency: ${stopwatch.elapsedMilliseconds} ms');
      buf.writeln('Server: ${resp.headers.value('server') ?? 'n/a'}');
      buf.writeln(
        'Body bytes: ${resp.data is Map ? (resp.data.toString().length) : 0}',
      );
    } on DioException catch (e) {
      buf.writeln('❌ DioException');
      buf.writeln('Type: ${e.type}');
      buf.writeln('Message: ${e.message ?? "(none)"}');
      buf.writeln('Status: ${e.response?.statusCode ?? "(no response)"}');
      buf.writeln('Error: ${e.error?.toString() ?? "(none)"}');
    } catch (e, st) {
      buf.writeln('❌ Unknown error');
      buf.writeln('Type: ${e.runtimeType}');
      buf.writeln('Message: $e');
      buf.writeln(st.toString().split('\n').take(3).join('\n'));
    }
    if (mounted) {
      setState(() {
        _result = buf.toString();
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final envLoaded = dotenv.isInitialized;
    final envUrl = envLoaded ? dotenv.maybeGet('API_BASE_URL') : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l.diagnosticsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Card(
                title: l.diagnosticsEnvStatus,
                children: [
                  _Row('dotenv.isInitialized', '$envLoaded'),
                  _Row(
                    'API_BASE_URL (env)',
                    envUrl ?? '(not set — using default)',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Card(
                title: l.diagnosticsConnectionStatus,
                children: [
                  if (_result == null && !_running)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l.diagnosticsHint,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  if (_running)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_result != null)
                    SelectableText(
                      _result!,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _running ? null : _runTest,
                icon: const Icon(Icons.wifi_tethering),
                label: Text(l.diagnosticsTestButton),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.actionBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
