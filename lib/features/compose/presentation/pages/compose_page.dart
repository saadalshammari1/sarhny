import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/compose_repository.dart';

final composeRepositoryProvider = Provider<ComposeRepository>(
  (ref) => ComposeRepository(ref.watch(dioClientProvider)),
);

class ComposePage extends ConsumerStatefulWidget {
  const ComposePage({super.key});

  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  PostSection? _section;
  final _layer1Ctrl = TextEditingController();
  final _layer3Ctrl = TextEditingController();
  bool _showLayer3 = false;
  final List<String> _images = [];
  bool _uploading = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _layer1Ctrl.dispose();
    _layer3Ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndCrop() async {
    if (_images.length >= 4) return;
    setState(() => _error = null);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null) return;
      final f = File(picked.path);
      final stat = await f.length();
      if (stat > 15 * 1024 * 1024) {
        setState(() => _error = 'حجم الصورة أكبر من ١٥ ميجا');
        return;
      }
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'اقتصاص الصورة',
            toolbarColor: const Color(0xFF1B1F2B),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'اقتصاص الصورة', aspectRatioLockEnabled: true),
        ],
      );
      if (cropped == null) return;
      setState(() => _uploading = true);
      final repo = ref.read(composeRepositoryProvider);
      final path = await repo.uploadImage(File(cropped.path));
      if (!mounted) return;
      setState(() => _images.add(path));
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'تعذّر رفع الصورة');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _publish() async {
    if (_section == null || _layer1Ctrl.text.trim().isEmpty || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(composeRepositoryProvider);
      final post = await repo.createPost(
        section: _section!.name,
        layer1: _layer1Ctrl.text.trim(),
        images: _images,
        layer3: _showLayer3 ? _layer3Ctrl.text.trim() : null,
      );
      Fluttertoast.showToast(msg: 'نُشِر بصدق ✨');
      if (!mounted) return;
      context.go('/post/${post.id}');
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'تعذّر النشر');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final remaining = 280 - _layer1Ctrl.text.length;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('منشور جديد'),
        actions: [
          TextButton(
            onPressed: _section != null &&
                    _layer1Ctrl.text.trim().isNotEmpty &&
                    !_submitting
                ? _publish
                : null,
            child: Text(
              _submitting ? '…' : 'نشر',
              style: TextStyle(
                color: _section != null &&
                        _layer1Ctrl.text.trim().isNotEmpty
                    ? colors.moment
                    : colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اكتب من قلبك',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'كل ما تنشره يدخل دورة جاذبية ٢٤ ساعة — التفاعل الصادق يبلوره ✦',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _SectionPicker(
              current: _section,
              onPick: (s) => setState(() => _section = s),
              colors: colors,
            ),
            if (_section != null) ...[
              const SizedBox(height: 20),
              _LayerCard(
                title: 'الطبقة ١ — الجوهر',
                subtitle: 'الفكرة الأساسية في سطور قليلة',
                trailing: Text(
                  '$remaining',
                  style:
                      TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                colors: colors,
                child: TextField(
                  controller: _layer1Ctrl,
                  maxLines: 6,
                  maxLength: 280,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'ما الذي يدور في خاطرك؟',
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms),
              const SizedBox(height: 14),
              _LayerCard(
                title: 'الطبقة ٢ — الصور',
                subtitle: 'حتى ٤ صور (مربعة)',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                        label: Text(_uploading ? 'جارٍ الرفع…' : 'إضافة صورة'),
                        onPressed:
                            _uploading || _images.length >= 4 ? null : _pickAndCrop,
                      ),
                      const SizedBox(width: 8),
                      Text('${_images.length}/4',
                          style: TextStyle(
                              color: colors.textSecondary, fontSize: 11)),
                    ]),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _images
                            .map((p) => _ImageThumb(
                                  path: p,
                                  onRemove: () =>
                                      setState(() => _images.remove(p)),
                                  colors: colors,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _showLayer3 = !_showLayer3),
                child: Row(
                  children: [
                    Icon(
                      _showLayer3
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showLayer3 ? 'إخفاء الطبقة ٣' : 'إضافة طبقة ٣ — تأمّل',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (_showLayer3) ...[
                const SizedBox(height: 12),
                _LayerCard(
                  title: 'الطبقة ٣ — التأمل',
                  subtitle: 'نص طويل (حتى ٤٠٠٠ حرف)',
                  colors: colors,
                  child: TextField(
                    controller: _layer3Ctrl,
                    maxLines: 10,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      hintText: 'فكّر معنا… (اختياري)',
                    ),
                  ),
                ).animate().fadeIn(duration: 250.ms),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      child: Text(_error!,
                          style: TextStyle(
                              color: colors.danger, fontSize: 13)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                label: 'نشر',
                onPressed: _publish,
                loading: _submitting,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({
    required this.current,
    required this.onPick,
    required this.colors,
  });
  final PostSection? current;
  final ValueChanged<PostSection> onPick;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر القسم',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: PostSection.values
              .map(
                (s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _SectionCard(
                      section: s,
                      selected: current == s,
                      onTap: () => onPick(s),
                      colors: colors,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final PostSection section;
  final bool selected;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final c = section.resolve(brightness);
    final desc = switch (section) {
      PostSection.moment => 'لحظة خاطفة، يومك يتنفّس',
      PostSection.face => 'صورة تحكي بصمتك',
      PostSection.mind => 'فكرة تأمّلية',
    };
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : colors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? c : colors.border,
            width: selected ? 1.4 : 0.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.glyph, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              section.arabicLabel,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerCard extends StatelessWidget {
  const _LayerCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.colors,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.path,
    required this.onRemove,
    required this.colors,
  });
  final String path;
  final VoidCallback onRemove;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final url = mediaUrl(path);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: url == null
                ? Container(color: colors.elevated)
                : Image.network(url, fit: BoxFit.cover, errorBuilder:
                    (_, __, ___) {
                    return Container(color: colors.elevated);
                  }),
          ),
        ),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
