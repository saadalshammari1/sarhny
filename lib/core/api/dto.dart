// نماذج بيانات Sarhny V2 — تطابق `web/src/lib/feed/types.ts`.
import 'dart:convert';

import 'package:flutter/foundation.dart';

// MariaDB JSON columns sometimes surface as raw strings from the driver
// rather than parsed structures. Decode defensively before casting so a
// stray string payload doesn't blow up the whole list.
List<dynamic>? _asListOrDecode(Object? value) {
  if (value == null) return null;
  if (value is List) return value;
  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null;
    }
  }
  return null;
}

Map<String, dynamic>? _asMapOrDecode(Object? value) {
  if (value == null) return null;
  if (value is Map) return value.cast<String, dynamic>();
  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } catch (_) {
      return null;
    }
  }
  return null;
}

int asInt(Object? value, {int fallback = 0}) {  // public so other DTO files can reuse
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

@immutable
class AuthorDto {
  const AuthorDto({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarPath,
    this.verified = false,
  });

  factory AuthorDto.fromJson(Map<String, dynamic> json) => AuthorDto(
        id: asInt(json['id']),
        username: '${json['username'] ?? ''}',
        displayName: json['display_name']?.toString(),
        avatarPath: json['avatar_path']?.toString(),
        verified: json['verified'] == true,
      );

  final int id;
  final String username;
  final String? displayName;
  final String? avatarPath;
  final bool verified;
}

@immutable
class OriginQuestionDto {
  const OriginQuestionDto({
    required this.questionText,
    this.senderHidden = true,
    this.senderUsername,
    this.senderDisplayName,
  });

  factory OriginQuestionDto.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return OriginQuestionDto(
      questionText: '${json['question_text'] ?? ''}',
      senderHidden: json['sender_hidden'] != false,
      senderUsername: sender is Map ? sender['username']?.toString() : null,
      senderDisplayName:
          sender is Map ? sender['display_name']?.toString() : null,
    );
  }

  final String questionText;
  final bool senderHidden;
  final String? senderUsername;
  final String? senderDisplayName;
}

enum PostSectionKind { moment, face, mind }

PostSectionKind sectionFromString(String? s) {
  switch (s) {
    case 'face':
      return PostSectionKind.face;
    case 'mind':
      return PostSectionKind.mind;
    default:
      return PostSectionKind.moment;
  }
}

@immutable
class PostDto {
  const PostDto({
    required this.id,
    required this.section,
    required this.body,
    required this.isCrystallized,
    required this.gravityScore,
    required this.author,
    this.lifecycleStatus = 'active',
    this.createdAt,
    this.decayDeadline,
    this.crystallizedAt,
    this.originInboxId,
    this.originQuestion,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.savesCount = 0,
    this.anonRepliesCount = 0,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => PostDto(
        id: asInt(json['id']),
        section: sectionFromString(json['section']?.toString()),
        body: '${json['body'] ?? ''}',
        isCrystallized: json['is_crystallized'] == true,
        gravityScore: ((json['gravity_score'] ?? 0) as num).toDouble(),
        author: AuthorDto.fromJson(
          (json['author'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        lifecycleStatus: '${json['lifecycle_status'] ?? 'active'}',
        createdAt: json['created_at']?.toString(),
        decayDeadline: json['decay_deadline']?.toString(),
        crystallizedAt: json['crystallized_at']?.toString(),
        originInboxId: (json['origin_inbox_id'] as num?)?.toInt(),
        originQuestion: json['origin_question'] is Map
            ? OriginQuestionDto.fromJson(
                (json['origin_question'] as Map).cast<String, dynamic>(),
              )
            : null,
        likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
        commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
        savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
        anonRepliesCount: (json['anon_replies_count'] as num?)?.toInt() ?? 0,
      );

  final int id;
  final PostSectionKind section;
  final String body;
  final bool isCrystallized;
  final double gravityScore;
  final AuthorDto author;
  final String lifecycleStatus;
  final String? createdAt;
  final String? decayDeadline;
  final String? crystallizedAt;
  final int? originInboxId;
  final OriginQuestionDto? originQuestion;
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final int anonRepliesCount;
}

@immutable
class FeedCursor {
  const FeedCursor({this.gravity, required this.id});
  factory FeedCursor.fromJson(Map<String, dynamic> json) => FeedCursor(
        gravity: (json['gravity'] as num?)?.toDouble(),
        id: asInt(json['id']),
      );
  final double? gravity;
  final int id;
}

@immutable
class FeedPageDto {
  const FeedPageDto({required this.posts, this.nextCursor, this.section});
  factory FeedPageDto.fromJson(Map<String, dynamic> json) => FeedPageDto(
        posts: (json['posts'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => PostDto.fromJson(e.cast<String, dynamic>()))
            .toList(),
        nextCursor: json['next_cursor'] is Map
            ? FeedCursor.fromJson(
                (json['next_cursor'] as Map).cast<String, dynamic>(),
              )
            : null,
        section: json['section']?.toString(),
      );

  final List<PostDto> posts;
  final FeedCursor? nextCursor;
  final String? section;
}

@immutable
class InboxItemDto {
  const InboxItemDto({
    required this.id,
    required this.message,
    required this.status,
    required this.mediaType,
    this.mediaRef,
    this.mediaMeta,
    this.linkRefs = const [],
    this.isSenderHidden = true,
    this.sender,
    this.createdAt,
  });

  factory InboxItemDto.fromJson(Map<String, dynamic> json) => InboxItemDto(
        id: asInt(json['id']),
        message: '${json['message'] ?? ''}',
        status: '${json['status'] ?? 'unread'}',
        mediaType: '${json['media_type'] ?? 'text'}',
        mediaRef: json['media_ref']?.toString(),
        mediaMeta: _asMapOrDecode(json['media_meta']),
        linkRefs: (_asListOrDecode(json['link_refs']) ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList(),
        isSenderHidden: json['is_sender_hidden'] != false,
        sender: json['sender'] is Map
            ? AuthorDto.fromJson((json['sender'] as Map).cast<String, dynamic>())
            : null,
        createdAt: json['created_at']?.toString(),
      );

  final int id;
  final String message;
  final String status;
  final String mediaType;
  final String? mediaRef;
  final Map<String, dynamic>? mediaMeta;
  final List<Map<String, dynamic>> linkRefs;
  final bool isSenderHidden;
  final AuthorDto? sender;
  final String? createdAt;
}

@immutable
class ProfileStatsDto {
  const ProfileStatsDto({
    this.followers = 0,
    this.following = 0,
    this.crystals = 0,
    this.answers = 0,
    this.active = 0,
    this.mirrors = 0,
  });
  factory ProfileStatsDto.fromJson(Map<String, dynamic> json) => ProfileStatsDto(
        followers: (json['followers'] as num?)?.toInt() ?? 0,
        following: (json['following'] as num?)?.toInt() ?? 0,
        crystals: (json['crystals'] as num?)?.toInt() ?? 0,
        answers: (json['answers'] as num?)?.toInt() ?? 0,
        active: (json['active'] as num?)?.toInt() ?? 0,
        mirrors: (json['mirrors'] as num?)?.toInt() ?? 0,
      );

  final int followers;
  final int following;
  final int crystals;
  final int answers;
  final int active;
  final int mirrors;
}

@immutable
class ProfileBadgeDto {
  const ProfileBadgeDto({this.count = 0, this.active = false});
  factory ProfileBadgeDto.fromJson(Map<String, dynamic> json) => ProfileBadgeDto(
        count: (json['count'] as num?)?.toInt() ?? 0,
        active: json['active'] == true,
      );
  final int count;
  final bool active;
}

@immutable
class PublicProfileDto {
  const PublicProfileDto({
    required this.user,
    required this.stats,
    required this.streak,
    required this.mirrors,
    this.verified = false,
    this.isFollowing = false,
    this.isSelf = false,
  });

  factory PublicProfileDto.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map? ?? const {}).cast<String, dynamic>();
    final stats =
        (json['stats'] as Map? ?? const {}).cast<String, dynamic>();
    final badges = (json['badges'] as Map? ?? const {}).cast<String, dynamic>();
    final viewer = (json['viewer'] as Map? ?? const {}).cast<String, dynamic>();
    return PublicProfileDto(
      user: PublicProfileUserDto.fromJson(user),
      stats: ProfileStatsDto.fromJson(stats),
      streak: ProfileBadgeDto.fromJson(
        (badges['streak'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
      mirrors: ProfileBadgeDto.fromJson(
        (badges['mirrors'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
      verified: (badges['verified'] as Map?)?['active'] == true,
      isFollowing: viewer['is_following'] == true,
      isSelf: viewer['is_self'] == true,
    );
  }

  final PublicProfileUserDto user;
  final ProfileStatsDto stats;
  final ProfileBadgeDto streak;
  final ProfileBadgeDto mirrors;
  final bool verified;
  final bool isFollowing;
  final bool isSelf;
}

@immutable
class PublicProfileUserDto {
  const PublicProfileUserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.location,
    this.website,
    this.avatarPath,
    this.coverPath,
    this.coverColor,
    this.joinedAt,
    this.subscriptionTier = 'free',
  });

  factory PublicProfileUserDto.fromJson(Map<String, dynamic> json) =>
      PublicProfileUserDto(
        id: asInt(json['id']),
        username: '${json['username'] ?? ''}',
        displayName: '${json['display_name'] ?? json['username'] ?? ''}',
        bio: json['bio']?.toString(),
        location: json['location']?.toString(),
        website: json['website']?.toString(),
        avatarPath: json['avatar_path']?.toString(),
        coverPath: json['cover_path']?.toString(),
        coverColor: json['cover_color']?.toString(),
        joinedAt: json['joined_at']?.toString(),
        subscriptionTier: '${json['subscription_tier'] ?? 'free'}',
      );

  final int id;
  final String username;
  final String displayName;
  final String? bio;
  final String? location;
  final String? website;
  final String? avatarPath;
  final String? coverPath;
  final String? coverColor;
  final String? joinedAt;
  final String subscriptionTier;
}

@immutable
class AnonReplyDto {
  const AnonReplyDto({
    required this.id,
    required this.mediaType,
    this.message,
    this.mediaRef,
    this.mediaMeta,
    this.isSenderHidden = true,
    this.sender,
    this.createdAt,
  });

  factory AnonReplyDto.fromJson(Map<String, dynamic> json) => AnonReplyDto(
        id: asInt(json['id']),
        mediaType: '${json['media_type'] ?? 'text'}',
        message: json['message']?.toString(),
        mediaRef: json['media_ref']?.toString(),
        mediaMeta: json['media_meta'] is Map
            ? (json['media_meta'] as Map).cast<String, dynamic>()
            : null,
        isSenderHidden: json['is_sender_hidden'] != false,
        sender: json['sender'] is Map
            ? AuthorDto.fromJson(
                (json['sender'] as Map).cast<String, dynamic>())
            : null,
        createdAt: json['created_at']?.toString(),
      );

  final int id;
  final String mediaType;
  final String? message;
  final String? mediaRef;
  final Map<String, dynamic>? mediaMeta;
  final bool isSenderHidden;
  final AuthorDto? sender;
  final String? createdAt;
}

@immutable
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.type,
    required this.payload,
    required this.read,
    this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
        id: asInt(json['id']),
        type: '${json['type'] ?? ''}',
        payload: (json['payload'] as Map? ?? const {}).cast<String, dynamic>(),
        read: json['read'] == true,
        createdAt: json['created_at']?.toString(),
      );

  final int id;
  final String type;
  final Map<String, dynamic> payload;
  final bool read;
  final String? createdAt;
}
