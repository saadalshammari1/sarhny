import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioClientProvider)),
);

final publicProfileProvider =
    FutureProvider.family<PublicProfileDto, String>((ref, username) {
  return ref.watch(profileRepositoryProvider).get(username);
});

enum ProfileTab { active, moments, answers, crystals, likes }

final selectedProfileTabProvider =
    StateProvider.family<ProfileTab, String>((_, __) => ProfileTab.active);

class ProfilePostsKey {
  const ProfilePostsKey({required this.username, required this.tab});
  factory ProfilePostsKey.make(String username, ProfileTab tab) =>
      ProfilePostsKey(username: username, tab: tab);
  final String username;
  final ProfileTab tab;
  @override
  bool operator ==(Object other) =>
      other is ProfilePostsKey &&
      other.username == username &&
      other.tab == tab;
  @override
  int get hashCode => Object.hash(username, tab);
}

final profilePostsProvider =
    FutureProvider.family<ProfilePostsPage, ProfilePostsKey>((ref, key) {
  final repo = ref.watch(profileRepositoryProvider);
  switch (key.tab) {
    case ProfileTab.active:
      return repo.listActive(key.username);
    case ProfileTab.moments:
      return repo.listMoments(key.username);
    case ProfileTab.answers:
      return repo.listAnswers(key.username);
    case ProfileTab.crystals:
      return repo.listCrystals(key.username);
    case ProfileTab.likes:
      return repo.listLikes(key.username);
  }
});
