import 'package:flutter/foundation.dart';

@immutable
class MirrorDto {
  const MirrorDto({
    required this.id,
    required this.questionText,
    required this.shareToken,
    required this.responseCount,
    this.createdAt,
    this.wordCloud = const [],
    this.recentResponses = const [],
  });

  factory MirrorDto.fromJson(Map<String, dynamic> json) => MirrorDto(
        id: (json['id'] as num).toInt(),
        questionText: '${json['question_text'] ?? ''}',
        shareToken: '${json['share_token'] ?? ''}',
        responseCount: (json['response_count'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at']?.toString(),
        wordCloud: (json['word_cloud'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => WordCloudEntry(
                  word: '${e['word']}',
                  count: (e['count'] as num?)?.toInt() ?? 0,
                ))
            .toList(),
        recentResponses: (json['recent_responses'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  final int id;
  final String questionText;
  final String shareToken;
  final int responseCount;
  final String? createdAt;
  final List<WordCloudEntry> wordCloud;
  final List<String> recentResponses;
}

@immutable
class WordCloudEntry {
  const WordCloudEntry({required this.word, required this.count});
  final String word;
  final int count;
}
