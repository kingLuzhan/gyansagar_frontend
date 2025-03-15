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
