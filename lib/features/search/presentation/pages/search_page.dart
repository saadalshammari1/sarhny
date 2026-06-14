import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';

/// Compact user-search page reached from the feed app bar. Debounces
/// keystrokes by 300ms so we don't hammer the backend while the user types.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<_UserHit> _results = const [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _runQuery(q.trim()));
  }

  Future<void> _runQuery(String q) async {
    if (q == _lastQuery) return;
    _lastQuery = q;
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioClientProvider).raw;
      final r = await dio.get<dynamic>(ApiEndpoints.userSearch(q));
      final data = r.data;
      if (data is Map && data['success'] == true) {
        final usersPage = (data['data'] as Map?)?['users'];
        final dataList = (usersPage is Map ? usersPage['data'] : null) as List?;
        final hits = (dataList ?? const [])
            .whereType<Map>()
            .map((e) => _UserHit.fromJson(e.cast<String, dynamic>()))
            .toList();
        if (q != _lastQuery) return; // a newer keystroke superseded us
        setState(() {
          _results = hits;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'ابحث عن مستخدم باسمه أو @username',
            border: InputBorder.none,
            isCollapsed: true,
          ),
          style: const TextStyle(fontSize: 15),
          onChanged: _onChanged,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                _runQuery('');
              },
            ),
        ],
      ),
      body: _BodyView(
        loading: _loading,
        results: _results,
        query: _ctrl.text.trim(),
        colors: colors,
      ),
    );
  }
}

class _BodyView extends StatelessWidget {
  const _BodyView({
    required this.loading,
    required this.results,
    required this.query,
    required this.colors,
  });
  final bool loading;
  final List<_UserHit> results;
  final String query;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (query.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'اكتب اسم مستخدم أو @username للبحث',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'لا توجد نتائج تطابق "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(color: colors.divider, height: 1),
      itemBuilder: (_, i) => _UserTile(hit: results[i], colors: colors),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.hit, required this.colors});
  final _UserHit hit;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final displayName = hit.displayName?.isNotEmpty == true ? hit.displayName! : hit.username;
    return InkWell(
      onTap: () => context.push('/u/${hit.username}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppAvatar(
              url: mediaUrl(hit.avatarPath),
              initials: displayName,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hit.verified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 14, color: colors.face),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${hit.username}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  if (hit.bio?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      hit.bio!,
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _UserHit {
  _UserHit({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarPath,
    this.bio,
    this.verified = false,
  });
  final int id;
  final String username;
  final String? displayName;
  final String? avatarPath;
  final String? bio;
  final bool verified;

  factory _UserHit.fromJson(Map<String, dynamic> j) {
    return _UserHit(
      id: (j['id'] as num?)?.toInt() ?? 0,
      username: '${j['username'] ?? ''}',
      displayName: j['name']?.toString() ?? j['display_name']?.toString(),
      avatarPath: j['avatar']?.toString() ?? j['avatar_path']?.toString(),
      bio: j['about']?.toString() ?? j['bio']?.toString(),
      verified: (j['verified'] == '1' || j['verified'] == 1 || j['verified'] == true),
    );
  }
}
