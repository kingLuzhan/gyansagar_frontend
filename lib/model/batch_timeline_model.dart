import 'package:gyansagar_frontend/helper/enum.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'batch_timeline_model.g.dart';

class BatchTimeline {
  final String type;
  final DateTime createdAt;
  final dynamic datum;

  BatchTimeline({
    required this.type,
    required this.createdAt,
    required this.datum,
  });

  factory BatchTimeline.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    dynamic parsedDatum;
    
    // Parse datum based on type
    if (type == 'video') {
      parsedDatum = VideoModel.fromJson(json['datum']);
    } else if (type == 'announcement') {
      parsedDatum = AnnouncementModel.fromJson(json['datum']);
    } else if (type == 'material') {
      parsedDatum = BatchMaterialModel.fromJson(json['datum']);
    } else {
      parsedDatum = json['datum'];
    }
    
    return BatchTimeline(
      type: type,
      createdAt: DateTime.parse(json['createdAt'] as String),
      datum: parsedDatum,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
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