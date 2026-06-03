import 'package:flutter/foundation.dart';

import '../../../core/api/dto.dart';

@immutable
class CommentDto {
  const CommentDto({
    required this.id,
    required this.body,
    required this.isAnonymous,
    this.author,
    this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: asInt(json['id']),
        body: '${json['body'] ?? ''}',
        isAnonymous: json['is_anonymous'] == true,
        author: json['author'] is Map
            ? AuthorDto.fromJson(
                (json['author'] as Map).cast<String, dynamic>(),
              )
            : null,
        createdAt: json['created_at']?.toString(),
      );

  final int id;
  final String body;
  final bool isAnonymous;
  final AuthorDto? author;
  final String? createdAt;
}

@immutable
class CommentsPageDto {
  const CommentsPageDto({required this.comments, this.nextCursor});
  factory CommentsPageDto.fromJson(Map<String, dynamic> json) => CommentsPageDto(
        comments: (json['comments'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => CommentDto.fromJson(e.cast<String, dynamic>()))
            .toList(),
        nextCursor: (json['next_cursor'] as num?)?.toInt(),
      );
  final List<CommentDto> comments;
  final int? nextCursor;
}

@immutable
class AnonRepliesPageDto {
  const AnonRepliesPageDto({required this.replies, this.nextCursor});
  factory AnonRepliesPageDto.fromJson(Map<String, dynamic> json) =>
      AnonRepliesPageDto(
        replies: (json['replies'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => AnonReplyDto.fromJson(e.cast<String, dynamic>()))
            .toList(),
        nextCursor: (json['next_cursor'] as num?)?.toInt(),
      );
  final List<AnonReplyDto> replies;
  final int? nextCursor;
}
