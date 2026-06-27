import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/help_repository.dart';

final _helpRepoProvider = Provider<HelpRepository>(
  (ref) => HelpRepository(ref.watch(dioClientProvider)),
);

final _featuresProvider = FutureProvider<List<HelpFeature>>((ref) {
  return ref.watch(_helpRepoProvider).features();
});

final _faqProvider = FutureProvider<List<FaqItem>>((ref) {
  return ref.watch(_helpRepoProvider).faq();
});

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(l.settingsHelpCenter),
          bottom: TabBar(
            indicatorColor: colors.moment,
            labelColor: colors.textPrimary,
            unselectedLabelColor: colors.textSecondary,
            tabs: [
              Tab(text: l.helpTabFeatures, icon: const Icon(Icons.auto_awesome_outlined)),
              Tab(text: l.helpTabFaq, icon: const Icon(Icons.help_outline)),
            ],
          ),
        ),
        body: TabBarView(children: [
          _FeaturesTab(),
          _FaqTab(),
        ]),
      ),
    );
  }
}

class _FeaturesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final state = ref.watch(_featuresProvider);
    return RefreshIndicator(
      color: colors.moment,
      onRefresh: () async => ref.invalidate(_featuresProvider),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_featuresProvider),
        ),
        data: (list) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: list.length,
          itemBuilder: (_, i) => _FeatureTile(feature: list[i], index: i),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.index});
  final HelpFeature feature;
  final int index;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.moment.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Text(feature.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  feature.body,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (60 * index).ms).fadeIn(duration: 250.ms).slideY(begin: 0.05);
  }
}

class _FaqTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final state = ref.watch(_faqProvider);
    return RefreshIndicator(
      color: colors.moment,
      onRefresh: () async => ref.invalidate(_faqProvider),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_faqProvider),
        ),
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: list
              .map((f) => Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border, width: 0.5),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      title: Text(
                        f.q,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      iconColor: colors.moment,
                      collapsedIconColor: colors.textSecondary,
                      children: [
                        Text(
                          f.a,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
