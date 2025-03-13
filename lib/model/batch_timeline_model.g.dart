// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchTimelineResponse _$BatchTimelineResponseFromJson(
  Map<String, dynamic> json,
) => BatchTimelineResponse(
  message: json['message'] as String,
  timeline:
      (json['timeline'] as List<dynamic>)
          .map((e) => BatchTimeline.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BatchTimelineResponseToJson(
  BatchTimelineResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'timeline': instance.timeline,
};

_BatchTimeline _$BatchTimelineFromJson(Map<String, dynamic> json) =>
    _BatchTimeline(
      type: $enumDecode(_$RawTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      datum: json['datum'],
    );

Map<String, dynamic> _$BatchTimelineToJson(_BatchTimeline instance) =>
    <String, dynamic>{
      'type': _$RawTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'datum': instance.datum,
    };

const _$RawTypeEnumMap = {
  RawType.VIDEO: 'VIDEO',
  RawType.MATERIAL: 'MATERIAL',
  RawType.ANNOUNCEMENT: 'ANNOUNCEMENT',
};
