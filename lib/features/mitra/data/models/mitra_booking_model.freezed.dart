// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mitra_booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MitraBookingModel {

 String get id; String get vehicleId; String get vehicleName; String get customerEmail; String get customerName; String get startDate; String get endDate; String get status; double get totalPrice; String? get notes;
/// Create a copy of MitraBookingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitraBookingModelCopyWith<MitraBookingModel> get copyWith => _$MitraBookingModelCopyWithImpl<MitraBookingModel>(this as MitraBookingModel, _$identity);

  /// Serializes this MitraBookingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitraBookingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vehicleId,vehicleName,customerEmail,customerName,startDate,endDate,status,totalPrice,notes);

@override
String toString() {
  return 'MitraBookingModel(id: $id, vehicleId: $vehicleId, vehicleName: $vehicleName, customerEmail: $customerEmail, customerName: $customerName, startDate: $startDate, endDate: $endDate, status: $status, totalPrice: $totalPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MitraBookingModelCopyWith<$Res>  {
  factory $MitraBookingModelCopyWith(MitraBookingModel value, $Res Function(MitraBookingModel) _then) = _$MitraBookingModelCopyWithImpl;
@useResult
$Res call({
 String id, String vehicleId, String vehicleName, String customerEmail, String customerName, String startDate, String endDate, String status, double totalPrice, String? notes
});




}
/// @nodoc
class _$MitraBookingModelCopyWithImpl<$Res>
    implements $MitraBookingModelCopyWith<$Res> {
  _$MitraBookingModelCopyWithImpl(this._self, this._then);

  final MitraBookingModel _self;
  final $Res Function(MitraBookingModel) _then;

/// Create a copy of MitraBookingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vehicleId = null,Object? vehicleName = null,Object? customerEmail = null,Object? customerName = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? totalPrice = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,vehicleName: null == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MitraBookingModel].
extension MitraBookingModelPatterns on MitraBookingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitraBookingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitraBookingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitraBookingModel value)  $default,){
final _that = this;
switch (_that) {
case _MitraBookingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitraBookingModel value)?  $default,){
final _that = this;
switch (_that) {
case _MitraBookingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vehicleId,  String vehicleName,  String customerEmail,  String customerName,  String startDate,  String endDate,  String status,  double totalPrice,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitraBookingModel() when $default != null:
return $default(_that.id,_that.vehicleId,_that.vehicleName,_that.customerEmail,_that.customerName,_that.startDate,_that.endDate,_that.status,_that.totalPrice,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vehicleId,  String vehicleName,  String customerEmail,  String customerName,  String startDate,  String endDate,  String status,  double totalPrice,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MitraBookingModel():
return $default(_that.id,_that.vehicleId,_that.vehicleName,_that.customerEmail,_that.customerName,_that.startDate,_that.endDate,_that.status,_that.totalPrice,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vehicleId,  String vehicleName,  String customerEmail,  String customerName,  String startDate,  String endDate,  String status,  double totalPrice,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MitraBookingModel() when $default != null:
return $default(_that.id,_that.vehicleId,_that.vehicleName,_that.customerEmail,_that.customerName,_that.startDate,_that.endDate,_that.status,_that.totalPrice,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitraBookingModel implements MitraBookingModel {
  const _MitraBookingModel({this.id = '', this.vehicleId = '', this.vehicleName = '', this.customerEmail = '', this.customerName = '', this.startDate = '', this.endDate = '', this.status = '', this.totalPrice = 0.0, this.notes});
  factory _MitraBookingModel.fromJson(Map<String, dynamic> json) => _$MitraBookingModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String vehicleId;
@override@JsonKey() final  String vehicleName;
@override@JsonKey() final  String customerEmail;
@override@JsonKey() final  String customerName;
@override@JsonKey() final  String startDate;
@override@JsonKey() final  String endDate;
@override@JsonKey() final  String status;
@override@JsonKey() final  double totalPrice;
@override final  String? notes;

/// Create a copy of MitraBookingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitraBookingModelCopyWith<_MitraBookingModel> get copyWith => __$MitraBookingModelCopyWithImpl<_MitraBookingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitraBookingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitraBookingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vehicleId,vehicleName,customerEmail,customerName,startDate,endDate,status,totalPrice,notes);

@override
String toString() {
  return 'MitraBookingModel(id: $id, vehicleId: $vehicleId, vehicleName: $vehicleName, customerEmail: $customerEmail, customerName: $customerName, startDate: $startDate, endDate: $endDate, status: $status, totalPrice: $totalPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MitraBookingModelCopyWith<$Res> implements $MitraBookingModelCopyWith<$Res> {
  factory _$MitraBookingModelCopyWith(_MitraBookingModel value, $Res Function(_MitraBookingModel) _then) = __$MitraBookingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String vehicleId, String vehicleName, String customerEmail, String customerName, String startDate, String endDate, String status, double totalPrice, String? notes
});




}
/// @nodoc
class __$MitraBookingModelCopyWithImpl<$Res>
    implements _$MitraBookingModelCopyWith<$Res> {
  __$MitraBookingModelCopyWithImpl(this._self, this._then);

  final _MitraBookingModel _self;
  final $Res Function(_MitraBookingModel) _then;

/// Create a copy of MitraBookingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vehicleId = null,Object? vehicleName = null,Object? customerEmail = null,Object? customerName = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? totalPrice = null,Object? notes = freezed,}) {
  return _then(_MitraBookingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,vehicleName: null == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
