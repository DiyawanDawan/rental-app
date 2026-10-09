// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mitra_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MitraProfileModel {

 String get id; String get email; String get storeName; String get phoneNumber; bool get isVerified; String? get bannerUrl; String? get description; double? get latitude; double? get longitude; String? get address;
/// Create a copy of MitraProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitraProfileModelCopyWith<MitraProfileModel> get copyWith => _$MitraProfileModelCopyWithImpl<MitraProfileModel>(this as MitraProfileModel, _$identity);

  /// Serializes this MitraProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitraProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,storeName,phoneNumber,isVerified,bannerUrl,description,latitude,longitude,address);

@override
String toString() {
  return 'MitraProfileModel(id: $id, email: $email, storeName: $storeName, phoneNumber: $phoneNumber, isVerified: $isVerified, bannerUrl: $bannerUrl, description: $description, latitude: $latitude, longitude: $longitude, address: $address)';
}


}

/// @nodoc
abstract mixin class $MitraProfileModelCopyWith<$Res>  {
  factory $MitraProfileModelCopyWith(MitraProfileModel value, $Res Function(MitraProfileModel) _then) = _$MitraProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String storeName, String phoneNumber, bool isVerified, String? bannerUrl, String? description, double? latitude, double? longitude, String? address
});




}
/// @nodoc
class _$MitraProfileModelCopyWithImpl<$Res>
    implements $MitraProfileModelCopyWith<$Res> {
  _$MitraProfileModelCopyWithImpl(this._self, this._then);

  final MitraProfileModel _self;
  final $Res Function(MitraProfileModel) _then;

/// Create a copy of MitraProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? storeName = null,Object? phoneNumber = null,Object? isVerified = null,Object? bannerUrl = freezed,Object? description = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MitraProfileModel].
extension MitraProfileModelPatterns on MitraProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitraProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitraProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitraProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _MitraProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitraProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _MitraProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String storeName,  String phoneNumber,  bool isVerified,  String? bannerUrl,  String? description,  double? latitude,  double? longitude,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitraProfileModel() when $default != null:
return $default(_that.id,_that.email,_that.storeName,_that.phoneNumber,_that.isVerified,_that.bannerUrl,_that.description,_that.latitude,_that.longitude,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String storeName,  String phoneNumber,  bool isVerified,  String? bannerUrl,  String? description,  double? latitude,  double? longitude,  String? address)  $default,) {final _that = this;
switch (_that) {
case _MitraProfileModel():
return $default(_that.id,_that.email,_that.storeName,_that.phoneNumber,_that.isVerified,_that.bannerUrl,_that.description,_that.latitude,_that.longitude,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String storeName,  String phoneNumber,  bool isVerified,  String? bannerUrl,  String? description,  double? latitude,  double? longitude,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _MitraProfileModel() when $default != null:
return $default(_that.id,_that.email,_that.storeName,_that.phoneNumber,_that.isVerified,_that.bannerUrl,_that.description,_that.latitude,_that.longitude,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitraProfileModel implements MitraProfileModel {
  const _MitraProfileModel({this.id = '', this.email = '', this.storeName = '', this.phoneNumber = '', this.isVerified = false, this.bannerUrl, this.description, this.latitude, this.longitude, this.address});
  factory _MitraProfileModel.fromJson(Map<String, dynamic> json) => _$MitraProfileModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String email;
@override@JsonKey() final  String storeName;
@override@JsonKey() final  String phoneNumber;
@override@JsonKey() final  bool isVerified;
@override final  String? bannerUrl;
@override final  String? description;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? address;

/// Create a copy of MitraProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitraProfileModelCopyWith<_MitraProfileModel> get copyWith => __$MitraProfileModelCopyWithImpl<_MitraProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitraProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitraProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,storeName,phoneNumber,isVerified,bannerUrl,description,latitude,longitude,address);

@override
String toString() {
  return 'MitraProfileModel(id: $id, email: $email, storeName: $storeName, phoneNumber: $phoneNumber, isVerified: $isVerified, bannerUrl: $bannerUrl, description: $description, latitude: $latitude, longitude: $longitude, address: $address)';
}


}

/// @nodoc
abstract mixin class _$MitraProfileModelCopyWith<$Res> implements $MitraProfileModelCopyWith<$Res> {
  factory _$MitraProfileModelCopyWith(_MitraProfileModel value, $Res Function(_MitraProfileModel) _then) = __$MitraProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String storeName, String phoneNumber, bool isVerified, String? bannerUrl, String? description, double? latitude, double? longitude, String? address
});




}
/// @nodoc
class __$MitraProfileModelCopyWithImpl<$Res>
    implements _$MitraProfileModelCopyWith<$Res> {
  __$MitraProfileModelCopyWithImpl(this._self, this._then);

  final _MitraProfileModel _self;
  final $Res Function(_MitraProfileModel) _then;

/// Create a copy of MitraProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? storeName = null,Object? phoneNumber = null,Object? isVerified = null,Object? bannerUrl = freezed,Object? description = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,}) {
  return _then(_MitraProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
