// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mitra_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MitraStatsModel {

 int get totalVehicles; int get totalBookings; double get revenue; double get ratingAverage;
/// Create a copy of MitraStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitraStatsModelCopyWith<MitraStatsModel> get copyWith => _$MitraStatsModelCopyWithImpl<MitraStatsModel>(this as MitraStatsModel, _$identity);

  /// Serializes this MitraStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitraStatsModel&&(identical(other.totalVehicles, totalVehicles) || other.totalVehicles == totalVehicles)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalVehicles,totalBookings,revenue,ratingAverage);

@override
String toString() {
  return 'MitraStatsModel(totalVehicles: $totalVehicles, totalBookings: $totalBookings, revenue: $revenue, ratingAverage: $ratingAverage)';
}


}

/// @nodoc
abstract mixin class $MitraStatsModelCopyWith<$Res>  {
  factory $MitraStatsModelCopyWith(MitraStatsModel value, $Res Function(MitraStatsModel) _then) = _$MitraStatsModelCopyWithImpl;
@useResult
$Res call({
 int totalVehicles, int totalBookings, double revenue, double ratingAverage
});




}
/// @nodoc
class _$MitraStatsModelCopyWithImpl<$Res>
    implements $MitraStatsModelCopyWith<$Res> {
  _$MitraStatsModelCopyWithImpl(this._self, this._then);

  final MitraStatsModel _self;
  final $Res Function(MitraStatsModel) _then;

/// Create a copy of MitraStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalVehicles = null,Object? totalBookings = null,Object? revenue = null,Object? ratingAverage = null,}) {
  return _then(_self.copyWith(
totalVehicles: null == totalVehicles ? _self.totalVehicles : totalVehicles // ignore: cast_nullable_to_non_nullable
as int,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MitraStatsModel].
extension MitraStatsModelPatterns on MitraStatsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitraStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitraStatsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitraStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _MitraStatsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitraStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _MitraStatsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalVehicles,  int totalBookings,  double revenue,  double ratingAverage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitraStatsModel() when $default != null:
return $default(_that.totalVehicles,_that.totalBookings,_that.revenue,_that.ratingAverage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalVehicles,  int totalBookings,  double revenue,  double ratingAverage)  $default,) {final _that = this;
switch (_that) {
case _MitraStatsModel():
return $default(_that.totalVehicles,_that.totalBookings,_that.revenue,_that.ratingAverage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalVehicles,  int totalBookings,  double revenue,  double ratingAverage)?  $default,) {final _that = this;
switch (_that) {
case _MitraStatsModel() when $default != null:
return $default(_that.totalVehicles,_that.totalBookings,_that.revenue,_that.ratingAverage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitraStatsModel implements MitraStatsModel {
  const _MitraStatsModel({this.totalVehicles = 0, this.totalBookings = 0, this.revenue = 0.0, this.ratingAverage = 0.0});
  factory _MitraStatsModel.fromJson(Map<String, dynamic> json) => _$MitraStatsModelFromJson(json);

@override@JsonKey() final  int totalVehicles;
@override@JsonKey() final  int totalBookings;
@override@JsonKey() final  double revenue;
@override@JsonKey() final  double ratingAverage;

/// Create a copy of MitraStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitraStatsModelCopyWith<_MitraStatsModel> get copyWith => __$MitraStatsModelCopyWithImpl<_MitraStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitraStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitraStatsModel&&(identical(other.totalVehicles, totalVehicles) || other.totalVehicles == totalVehicles)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalVehicles,totalBookings,revenue,ratingAverage);

@override
String toString() {
  return 'MitraStatsModel(totalVehicles: $totalVehicles, totalBookings: $totalBookings, revenue: $revenue, ratingAverage: $ratingAverage)';
}


}

/// @nodoc
abstract mixin class _$MitraStatsModelCopyWith<$Res> implements $MitraStatsModelCopyWith<$Res> {
  factory _$MitraStatsModelCopyWith(_MitraStatsModel value, $Res Function(_MitraStatsModel) _then) = __$MitraStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int totalVehicles, int totalBookings, double revenue, double ratingAverage
});




}
/// @nodoc
class __$MitraStatsModelCopyWithImpl<$Res>
    implements _$MitraStatsModelCopyWith<$Res> {
  __$MitraStatsModelCopyWithImpl(this._self, this._then);

  final _MitraStatsModel _self;
  final $Res Function(_MitraStatsModel) _then;

/// Create a copy of MitraStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalVehicles = null,Object? totalBookings = null,Object? revenue = null,Object? ratingAverage = null,}) {
  return _then(_MitraStatsModel(
totalVehicles: null == totalVehicles ? _self.totalVehicles : totalVehicles // ignore: cast_nullable_to_non_nullable
as int,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
