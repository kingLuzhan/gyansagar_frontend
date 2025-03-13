// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_timeline_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatchTimeline implements DiagnosticableTreeMixin {

 RawType get type; DateTime get createdAt; dynamic get datum;
/// Create a copy of BatchTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchTimelineCopyWith<BatchTimeline> get copyWith => _$BatchTimelineCopyWithImpl<BatchTimeline>(this as BatchTimeline, _$identity);

  /// Serializes this BatchTimeline to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BatchTimeline'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('datum', datum));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchTimeline&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.datum, datum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,createdAt,const DeepCollectionEquality().hash(datum));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BatchTimeline(type: $type, createdAt: $createdAt, datum: $datum)';
}


}

/// @nodoc
abstract mixin class $BatchTimelineCopyWith<$Res>  {
  factory $BatchTimelineCopyWith(BatchTimeline value, $Res Function(BatchTimeline) _then) = _$BatchTimelineCopyWithImpl;
@useResult
$Res call({
 RawType type, DateTime createdAt, dynamic datum
});




}
/// @nodoc
class _$BatchTimelineCopyWithImpl<$Res>
    implements $BatchTimelineCopyWith<$Res> {
  _$BatchTimelineCopyWithImpl(this._self, this._then);

  final BatchTimeline _self;
  final $Res Function(BatchTimeline) _then;

/// Create a copy of BatchTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? createdAt = null,Object? datum = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RawType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,datum: freezed == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _BatchTimeline with DiagnosticableTreeMixin implements BatchTimeline {
  const _BatchTimeline({required this.type, required this.createdAt, required this.datum});
  factory _BatchTimeline.fromJson(Map<String, dynamic> json) => _$BatchTimelineFromJson(json);

@override final  RawType type;
@override final  DateTime createdAt;
@override final  dynamic datum;

/// Create a copy of BatchTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchTimelineCopyWith<_BatchTimeline> get copyWith => __$BatchTimelineCopyWithImpl<_BatchTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchTimelineToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BatchTimeline'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('datum', datum));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchTimeline&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.datum, datum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,createdAt,const DeepCollectionEquality().hash(datum));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BatchTimeline(type: $type, createdAt: $createdAt, datum: $datum)';
}


}

/// @nodoc
abstract mixin class _$BatchTimelineCopyWith<$Res> implements $BatchTimelineCopyWith<$Res> {
  factory _$BatchTimelineCopyWith(_BatchTimeline value, $Res Function(_BatchTimeline) _then) = __$BatchTimelineCopyWithImpl;
@override @useResult
$Res call({
 RawType type, DateTime createdAt, dynamic datum
});




}
/// @nodoc
class __$BatchTimelineCopyWithImpl<$Res>
    implements _$BatchTimelineCopyWith<$Res> {
  __$BatchTimelineCopyWithImpl(this._self, this._then);

  final _BatchTimeline _self;
  final $Res Function(_BatchTimeline) _then;

/// Create a copy of BatchTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? createdAt = null,Object? datum = freezed,}) {
  return _then(_BatchTimeline(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RawType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,datum: freezed == datum ? _self.datum : datum // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
