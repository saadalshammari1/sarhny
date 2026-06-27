import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/media/upload_repository.dart';
import '../../../../core/providers/api_providers.dart';

/// Media payload the composer hands back to its parent on Send.
class ComposedMedia {
  ComposedMedia({
    required this.mediaType, // 'text' | 'voice' | 'image'
    this.message,
    this.mediaRef,
    this.durationSeconds,
  });
  final String mediaType;
  final String? message;
  final String? mediaRef;
  final int? durationSeconds;
}

/// Unified media composer used by AnonReplies + Inbox + Public Ask Form.
/// Supports text + voice + image. Recording uses the `record` package with
/// a soft amplitude indicator; image flow runs through ImageCropper before
/// upload to keep files small.
class MediaComposer extends ConsumerStatefulWidget {
  const MediaComposer({
    super.key,
    required this.onSend,
    this.placeholder,
    this.maxLength = 600,
    this.allowVoice = true,
    this.allowImage = true,
    this.hiddenSwitch,
  });

  /// Sends a composed media bundle; returns true on success (clears composer).
  final Future<bool> Function(ComposedMedia) onSend;
  final String? placeholder;
  final int maxLength;
  final bool allowVoice;
  final bool allowImage;
  /// Optional sender-identity toggle rendered to the left of the send button.
  final Widget? hiddenSwitch;

  @override
  ConsumerState<MediaComposer> createState() => _MediaComposerState();
}

enum _Mode { idle, recording, voiceReady, imageReady }

class _MediaComposerState extends ConsumerState<MediaComposer> {
  final _ctrl = TextEditingController();
  final _record = AudioRecorder();
  Timer? _tick;
  Duration _elapsed = Duration.zero;
  double _amp = 0;
  String? _recordedPath;
  String? _pickedImagePath;
  _Mode _mode = _Mode.idle;
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _tick?.cancel();
    _record.dispose();
    super.dispose();
  }

  Future<String> _newAudioPath() async {
    final dir = await getTemporaryDirectory();
    final fn = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${dir.path}/$fn';
  }

  Future<void> _startRecording() async {
    final l = AppLocalizations.of(context);
    try {
      if (!await _record.hasPermission()) {
        Fluttertoast.showToast(msg: l.postMicPermission);
        return;
      }
      final path = await _newAudioPath();
      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 22050,
        ),
        path: path,
      );
      setState(() {
        _mode = _Mode.recording;
        _elapsed = Duration.zero;
      });
      _tick = Timer.periodic(const Duration(milliseconds: 200), (t) async {
        if (!mounted) {
          t.cancel();
          return;
        }
        final amp = await _record.getAmplitude();
        setState(() {
          _elapsed = Duration(milliseconds: 200 * t.tick);
          // record returns dB (negative scale). Map -45..0 → 0..1.
          _amp = ((amp.current + 45) / 45).clamp(0.0, 1.0);
        });
        if (_elapsed.inSeconds >= 60) {
          await _stopRecording();
        }
      });
    } catch (_) {
      Fluttertoast.showToast(msg: l.postRecordStartFailed);
    }
  }

  Future<void> _stopRecording() async {
    _tick?.cancel();
    final path = await _record.stop();
    if (!mounted) return;
    setState(() {
      _recordedPath = path;
      _mode = _Mode.voiceReady;
    });
  }

  Future<void> _cancelRecording() async {
    _tick?.cancel();
    await _record.cancel();
    if (!mounted) return;
    setState(() {
      _recordedPath = null;
      _mode = _Mode.idle;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _pickImage() async {
    final l = AppLocalizations.of(context);
    try {
      final picked = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (picked == null) return;
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
      );
      if (cropped == null) return;
      setState(() {
        _pickedImagePath = cropped.path;
        _mode = _Mode.imageReady;
      });
    } catch (_) {
      Fluttertoast.showToast(msg: l.postImagePickFailed);
    }
  }

  void _clearMedia() {
    setState(() {
      _recordedPath = null;
      _pickedImagePath = null;
      _mode = _Mode.idle;
    });
  }

  Future<void> _send() async {
    if (_sending) return;
    final l = AppLocalizations.of(context);
    final text = _ctrl.text.trim();
    final hasMedia = _recordedPath != null || _pickedImagePath != null;
    if (text.isEmpty && !hasMedia) return;

    setState(() => _sending = true);
    try {
      final upload = UploadRepository(ref.read(dioClientProvider));
      String mediaType = 'text';
      String? mediaRef;
      int? duration;

      if (_recordedPath != null) {
        mediaType = 'voice';
        mediaRef = await upload.uploadVoice(
          File(_recordedPath!),
          durationSeconds: _elapsed.inSeconds,
        );
        duration = _elapsed.inSeconds;
      } else if (_pickedImagePath != null) {
        mediaType = 'image';
        mediaRef = await upload.uploadImage(File(_pickedImagePath!));
      }

      final ok = await widget.onSend(ComposedMedia(
        mediaType: mediaType,
        message: text.isNotEmpty ? text : null,
        mediaRef: mediaRef,
        durationSeconds: duration,
      ));
      if (ok && mounted) {
        _ctrl.clear();
        _clearMedia();
      }
    } on ValidationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } on RateLimitException {
      Fluttertoast.showToast(msg: l.postSlowDownRetry);
    } catch (_) {
      Fluttertoast.showToast(msg: l.postSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_mode == _Mode.imageReady && _pickedImagePath != null)
            _ImagePreview(
              path: _pickedImagePath!,
              onRemove: _clearMedia,
              colors: colors,
            )
          else if (_mode == _Mode.voiceReady && _recordedPath != null)
            _VoicePreview(
              duration: _elapsed,
              onRemove: _clearMedia,
              colors: colors,
            )
          else if (_mode == _Mode.recording)
            _RecordingBar(
              elapsed: _elapsed,
              amp: _amp,
              onStop: _stopRecording,
              onCancel: _cancelRecording,
              colors: colors,
            )
          else
            TextField(
              controller: _ctrl,
              maxLength: widget.maxLength,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.placeholder ?? l.postReplyHint,
                hintStyle: TextStyle(color: colors.textSecondary),
                isCollapsed: true,
                counterText: '',
              ),
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.allowImage && _mode == _Mode.idle)
                _ToolButton(
                  icon: Icons.image_outlined,
                  tooltip: l.postTooltipImage,
                  color: colors.face,
                  onTap: _pickImage,
                ),
              if (widget.allowVoice && _mode == _Mode.idle) ...[
                const SizedBox(width: 4),
                _ToolButton(
                  icon: Icons.mic_none_rounded,
                  tooltip: l.postTooltipVoice,
                  color: colors.moment,
                  onTap: _startRecording,
                ),
              ],
              if (widget.hiddenSwitch != null) ...[
                const SizedBox(width: 8),
                widget.hiddenSwitch!,
              ],
              const Spacer(),
              if (_mode != _Mode.recording)
                _SendButton(
                  loading: _sending,
                  enabled: _ctrl.text.trim().isNotEmpty ||
                      _recordedPath != null ||
                      _pickedImagePath != null,
                  onTap: _send,
                  colors: colors,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
    required this.colors,
  });
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = enabled ? colors.moment : colors.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled && !loading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: enabled ? c : c.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded,
                      color: enabled ? Colors.white : c, size: 16),
                  const SizedBox(width: 4),
                  Text(l.actionSend,
                      style: TextStyle(
                        color: enabled ? Colors.white : c,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )),
                ],
              ),
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.elapsed,
    required this.amp,
    required this.onStop,
    required this.onCancel,
    required this.colors,
  });
  final Duration elapsed;
  final double amp;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final SarhnyColors colors;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colors.danger,
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat()).fadeOut(
              duration: 600.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: 8),
        Text(
          _fmt(elapsed),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _Wave(amp: amp, color: colors.moment)),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.close, color: colors.danger),
          onPressed: onCancel,
        ),
        IconButton(
          icon: Icon(Icons.stop_circle, color: colors.moment, size: 28),
          onPressed: onStop,
        ),
      ],
    );
  }
}

class _Wave extends StatelessWidget {
  const _Wave({required this.amp, required this.color});
  final double amp;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(18, (i) {
          final base = 4.0;
          final offset = (i % 4) * 1.5;
          final h = (base + amp * 22 + offset).clamp(4.0, 28.0);
          return Container(
            width: 3,
            height: h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4 + 0.6 * amp),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _VoicePreview extends StatelessWidget {
  const _VoicePreview({
    required this.duration,
    required this.onRemove,
    required this.colors,
  });
  final Duration duration;
  final VoidCallback onRemove;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.moment.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.moment.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Icon(Icons.graphic_eq, color: colors.moment),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${l.postVoiceRecording} — ${duration.inSeconds} ${l.postSecondsShort}',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: colors.danger),
          onPressed: onRemove,
        ),
      ]),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.path,
    required this.onRemove,
    required this.colors,
  });
  final String path;
  final VoidCallback onRemove;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(path),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      PositionedDirectional(
        top: 8,
        end: 8,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ),
      ),
    ]);
  }
}
