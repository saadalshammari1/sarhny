import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/mirror_dto.dart';
import '../../data/mirrors_repository.dart';

final mirrorsRepositoryProvider = Provider<MirrorsRepository>(
  (ref) => MirrorsRepository(ref.watch(dioClientProvider)),
);

final myMirrorsProvider = FutureProvider<List<MirrorDto>>((ref) {
  return ref.watch(mirrorsRepositoryProvider).listMine();
});
