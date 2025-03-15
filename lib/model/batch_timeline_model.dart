import 'package:gyansagar_frontend/helper/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'batch_timeline_model.g.dart';

class BatchTimeline {
  final RawType type;
  final DateTime createdAt;
  final dynamic datum;

  BatchTimeline({
    required this.type,
    required this.createdAt,
    required this.datum,
  });

  factory BatchTimeline.fromJson(Map<String, dynamic> json) {
    return BatchTimeline(
      type: typeValues.map[json['type']]!,
      createdAt: DateTime.parse(json['createdAt'] as String),
      datum: json['datum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': typeValues.reverse[type],
      'createdAt': createdAt.toIso8601String(),
      'datum': datum,
    };
  }
}

@JsonSerializable(includeIfNull: false)
class BatchTimelineResponse {
  final String message;
  final List<BatchTimeline> timeline;

  BatchTimelineResponse({
    required this.message,
    required this.timeline,
  });

  factory BatchTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BatchTimelineResponseToJson(this);
}