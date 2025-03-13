import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gyansagar_frontend/helper/enum.dart';

part 'batch_timeline_model.freezed.dart';
part 'batch_timeline_model.g.dart';

@freezed
class BatchTimeline with _$BatchTimeline {
  const factory BatchTimeline({
    required RawType type,
    required DateTime createdAt,
    required dynamic datum,
  }) = _BatchTimeline;

  factory BatchTimeline.fromJson(Map<String, dynamic> json) =>
      _$BatchTimelineFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class BatchTimelineResponse {
  BatchTimelineResponse({
    required this.message,
    required this.timeline,
  });

  final String message;
  final List<BatchTimeline> timeline;

  factory BatchTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BatchTimelineResponseToJson(this);
}
