// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mitra_vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MitraVehicleModel {

 String get id; String get name; String get type; String get brand; String get model; String get licensePlate; String get color; double get pricePerDay; String get status; String? get rentalType; bool get isInstantBooking; String? get primaryPhotoUrl; List<Map<String, dynamic>> get amenities; int? get year; String? get transmission; int? get seatingCapacity; String? get description; List<String> get photos; double? get priceWithDriver; double? get priceFullPackage; double? get depositAmount; List<String>? get blockedDates;
/// Create a copy of MitraVehicleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitraVehicleModelCopyWith<MitraVehicleModel> get copyWith => _$MitraVehicleModelCopyWithImpl<MitraVehicleModel>(this as MitraVehicleModel, _$identity);

  /// Serializes this MitraVehicleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitraVehicleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.color, color) || other.color == color)&&(identical(other.pricePerDay, pricePerDay) || other.pricePerDay == pricePerDay)&&(identical(other.status, status) || other.status == status)&&(identical(other.rentalType, rentalType) || other.rentalType == rentalType)&&(identical(other.isInstantBooking, isInstantBooking) || other.isInstantBooking == isInstantBooking)&&(identical(other.primaryPhotoUrl, primaryPhotoUrl) || other.primaryPhotoUrl == primaryPhotoUrl)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&(identical(other.year, year) || other.year == year)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.seatingCapacity, seatingCapacity) || other.seatingCapacity == seatingCapacity)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.priceWithDriver, priceWithDriver) || other.priceWithDriver == priceWithDriver)&&(identical(other.priceFullPackage, priceFullPackage) || other.priceFullPackage == priceFullPackage)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&const DeepCollectionEquality().equals(other.blockedDates, blockedDates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,brand,model,licensePlate,color,pricePerDay,status,rentalType,isInstantBooking,primaryPhotoUrl,const DeepCollectionEquality().hash(amenities),year,transmission,seatingCapacity,description,const DeepCollectionEquality().hash(photos),priceWithDriver,priceFullPackage,depositAmount,const DeepCollectionEquality().hash(blockedDates)]);

@override
String toString() {
  return 'MitraVehicleModel(id: $id, name: $name, type: $type, brand: $brand, model: $model, licensePlate: $licensePlate, color: $color, pricePerDay: $pricePerDay, status: $status, rentalType: $rentalType, isInstantBooking: $isInstantBooking, primaryPhotoUrl: $primaryPhotoUrl, amenities: $amenities, year: $year, transmission: $transmission, seatingCapacity: $seatingCapacity, description: $description, photos: $photos, priceWithDriver: $priceWithDriver, priceFullPackage: $priceFullPackage, depositAmount: $depositAmount, blockedDates: $blockedDates)';
}


}

/// @nodoc
abstract mixin class $MitraVehicleModelCopyWith<$Res>  {
  factory $MitraVehicleModelCopyWith(MitraVehicleModel value, $Res Function(MitraVehicleModel) _then) = _$MitraVehicleModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String brand, String model, String licensePlate, String color, double pricePerDay, String status, String? rentalType, bool isInstantBooking, String? primaryPhotoUrl, List<Map<String, dynamic>> amenities, int? year, String? transmission, int? seatingCapacity, String? description, List<String> photos, double? priceWithDriver, double? priceFullPackage, double? depositAmount, List<String>? blockedDates
});




}
/// @nodoc
class _$MitraVehicleModelCopyWithImpl<$Res>
    implements $MitraVehicleModelCopyWith<$Res> {
  _$MitraVehicleModelCopyWithImpl(this._self, this._then);

  final MitraVehicleModel _self;
  final $Res Function(MitraVehicleModel) _then;

/// Create a copy of MitraVehicleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? brand = null,Object? model = null,Object? licensePlate = null,Object? color = null,Object? pricePerDay = null,Object? status = null,Object? rentalType = freezed,Object? isInstantBooking = null,Object? primaryPhotoUrl = freezed,Object? amenities = null,Object? year = freezed,Object? transmission = freezed,Object? seatingCapacity = freezed,Object? description = freezed,Object? photos = null,Object? priceWithDriver = freezed,Object? priceFullPackage = freezed,Object? depositAmount = freezed,Object? blockedDates = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,pricePerDay: null == pricePerDay ? _self.pricePerDay : pricePerDay // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rentalType: freezed == rentalType ? _self.rentalType : rentalType // ignore: cast_nullable_to_non_nullable
as String?,isInstantBooking: null == isInstantBooking ? _self.isInstantBooking : isInstantBooking // ignore: cast_nullable_to_non_nullable
as bool,primaryPhotoUrl: freezed == primaryPhotoUrl ? _self.primaryPhotoUrl : primaryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,seatingCapacity: freezed == seatingCapacity ? _self.seatingCapacity : seatingCapacity // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,priceWithDriver: freezed == priceWithDriver ? _self.priceWithDriver : priceWithDriver // ignore: cast_nullable_to_non_nullable
as double?,priceFullPackage: freezed == priceFullPackage ? _self.priceFullPackage : priceFullPackage // ignore: cast_nullable_to_non_nullable
as double?,depositAmount: freezed == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double?,blockedDates: freezed == blockedDates ? _self.blockedDates : blockedDates // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MitraVehicleModel].
extension MitraVehicleModelPatterns on MitraVehicleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitraVehicleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitraVehicleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitraVehicleModel value)  $default,){
final _that = this;
switch (_that) {
case _MitraVehicleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitraVehicleModel value)?  $default,){
final _that = this;
switch (_that) {
case _MitraVehicleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String brand,  String model,  String licensePlate,  String color,  double pricePerDay,  String status,  String? rentalType,  bool isInstantBooking,  String? primaryPhotoUrl,  List<Map<String, dynamic>> amenities,  int? year,  String? transmission,  int? seatingCapacity,  String? description,  List<String> photos,  double? priceWithDriver,  double? priceFullPackage,  double? depositAmount,  List<String>? blockedDates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitraVehicleModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.licensePlate,_that.color,_that.pricePerDay,_that.status,_that.rentalType,_that.isInstantBooking,_that.primaryPhotoUrl,_that.amenities,_that.year,_that.transmission,_that.seatingCapacity,_that.description,_that.photos,_that.priceWithDriver,_that.priceFullPackage,_that.depositAmount,_that.blockedDates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String brand,  String model,  String licensePlate,  String color,  double pricePerDay,  String status,  String? rentalType,  bool isInstantBooking,  String? primaryPhotoUrl,  List<Map<String, dynamic>> amenities,  int? year,  String? transmission,  int? seatingCapacity,  String? description,  List<String> photos,  double? priceWithDriver,  double? priceFullPackage,  double? depositAmount,  List<String>? blockedDates)  $default,) {final _that = this;
switch (_that) {
case _MitraVehicleModel():
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.licensePlate,_that.color,_that.pricePerDay,_that.status,_that.rentalType,_that.isInstantBooking,_that.primaryPhotoUrl,_that.amenities,_that.year,_that.transmission,_that.seatingCapacity,_that.description,_that.photos,_that.priceWithDriver,_that.priceFullPackage,_that.depositAmount,_that.blockedDates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  String brand,  String model,  String licensePlate,  String color,  double pricePerDay,  String status,  String? rentalType,  bool isInstantBooking,  String? primaryPhotoUrl,  List<Map<String, dynamic>> amenities,  int? year,  String? transmission,  int? seatingCapacity,  String? description,  List<String> photos,  double? priceWithDriver,  double? priceFullPackage,  double? depositAmount,  List<String>? blockedDates)?  $default,) {final _that = this;
switch (_that) {
case _MitraVehicleModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.licensePlate,_that.color,_that.pricePerDay,_that.status,_that.rentalType,_that.isInstantBooking,_that.primaryPhotoUrl,_that.amenities,_that.year,_that.transmission,_that.seatingCapacity,_that.description,_that.photos,_that.priceWithDriver,_that.priceFullPackage,_that.depositAmount,_that.blockedDates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitraVehicleModel implements MitraVehicleModel {
  const _MitraVehicleModel({this.id = '', this.name = '', this.type = '', this.brand = '', this.model = '', this.licensePlate = '', this.color = '', this.pricePerDay = 0.0, this.status = '', this.rentalType, this.isInstantBooking = false, this.primaryPhotoUrl, final  List<Map<String, dynamic>> amenities = const [], this.year, this.transmission, this.seatingCapacity, this.description, final  List<String> photos = const [], this.priceWithDriver, this.priceFullPackage, this.depositAmount, final  List<String>? blockedDates}): _amenities = amenities,_photos = photos,_blockedDates = blockedDates;
  factory _MitraVehicleModel.fromJson(Map<String, dynamic> json) => _$MitraVehicleModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String type;
@override@JsonKey() final  String brand;
@override@JsonKey() final  String model;
@override@JsonKey() final  String licensePlate;
@override@JsonKey() final  String color;
@override@JsonKey() final  double pricePerDay;
@override@JsonKey() final  String status;
@override final  String? rentalType;
@override@JsonKey() final  bool isInstantBooking;
@override final  String? primaryPhotoUrl;
 final  List<Map<String, dynamic>> _amenities;
@override@JsonKey() List<Map<String, dynamic>> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

@override final  int? year;
@override final  String? transmission;
@override final  int? seatingCapacity;
@override final  String? description;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  double? priceWithDriver;
@override final  double? priceFullPackage;
@override final  double? depositAmount;
 final  List<String>? _blockedDates;
@override List<String>? get blockedDates {
  final value = _blockedDates;
  if (value == null) return null;
  if (_blockedDates is EqualUnmodifiableListView) return _blockedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MitraVehicleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitraVehicleModelCopyWith<_MitraVehicleModel> get copyWith => __$MitraVehicleModelCopyWithImpl<_MitraVehicleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitraVehicleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitraVehicleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.color, color) || other.color == color)&&(identical(other.pricePerDay, pricePerDay) || other.pricePerDay == pricePerDay)&&(identical(other.status, status) || other.status == status)&&(identical(other.rentalType, rentalType) || other.rentalType == rentalType)&&(identical(other.isInstantBooking, isInstantBooking) || other.isInstantBooking == isInstantBooking)&&(identical(other.primaryPhotoUrl, primaryPhotoUrl) || other.primaryPhotoUrl == primaryPhotoUrl)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&(identical(other.year, year) || other.year == year)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.seatingCapacity, seatingCapacity) || other.seatingCapacity == seatingCapacity)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.priceWithDriver, priceWithDriver) || other.priceWithDriver == priceWithDriver)&&(identical(other.priceFullPackage, priceFullPackage) || other.priceFullPackage == priceFullPackage)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&const DeepCollectionEquality().equals(other._blockedDates, _blockedDates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,brand,model,licensePlate,color,pricePerDay,status,rentalType,isInstantBooking,primaryPhotoUrl,const DeepCollectionEquality().hash(_amenities),year,transmission,seatingCapacity,description,const DeepCollectionEquality().hash(_photos),priceWithDriver,priceFullPackage,depositAmount,const DeepCollectionEquality().hash(_blockedDates)]);

@override
String toString() {
  return 'MitraVehicleModel(id: $id, name: $name, type: $type, brand: $brand, model: $model, licensePlate: $licensePlate, color: $color, pricePerDay: $pricePerDay, status: $status, rentalType: $rentalType, isInstantBooking: $isInstantBooking, primaryPhotoUrl: $primaryPhotoUrl, amenities: $amenities, year: $year, transmission: $transmission, seatingCapacity: $seatingCapacity, description: $description, photos: $photos, priceWithDriver: $priceWithDriver, priceFullPackage: $priceFullPackage, depositAmount: $depositAmount, blockedDates: $blockedDates)';
}


}

/// @nodoc
abstract mixin class _$MitraVehicleModelCopyWith<$Res> implements $MitraVehicleModelCopyWith<$Res> {
  factory _$MitraVehicleModelCopyWith(_MitraVehicleModel value, $Res Function(_MitraVehicleModel) _then) = __$MitraVehicleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String brand, String model, String licensePlate, String color, double pricePerDay, String status, String? rentalType, bool isInstantBooking, String? primaryPhotoUrl, List<Map<String, dynamic>> amenities, int? year, String? transmission, int? seatingCapacity, String? description, List<String> photos, double? priceWithDriver, double? priceFullPackage, double? depositAmount, List<String>? blockedDates
});




}
/// @nodoc
class __$MitraVehicleModelCopyWithImpl<$Res>
    implements _$MitraVehicleModelCopyWith<$Res> {
  __$MitraVehicleModelCopyWithImpl(this._self, this._then);

  final _MitraVehicleModel _self;
  final $Res Function(_MitraVehicleModel) _then;

/// Create a copy of MitraVehicleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? brand = null,Object? model = null,Object? licensePlate = null,Object? color = null,Object? pricePerDay = null,Object? status = null,Object? rentalType = freezed,Object? isInstantBooking = null,Object? primaryPhotoUrl = freezed,Object? amenities = null,Object? year = freezed,Object? transmission = freezed,Object? seatingCapacity = freezed,Object? description = freezed,Object? photos = null,Object? priceWithDriver = freezed,Object? priceFullPackage = freezed,Object? depositAmount = freezed,Object? blockedDates = freezed,}) {
  return _then(_MitraVehicleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,pricePerDay: null == pricePerDay ? _self.pricePerDay : pricePerDay // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rentalType: freezed == rentalType ? _self.rentalType : rentalType // ignore: cast_nullable_to_non_nullable
as String?,isInstantBooking: null == isInstantBooking ? _self.isInstantBooking : isInstantBooking // ignore: cast_nullable_to_non_nullable
as bool,primaryPhotoUrl: freezed == primaryPhotoUrl ? _self.primaryPhotoUrl : primaryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,seatingCapacity: freezed == seatingCapacity ? _self.seatingCapacity : seatingCapacity // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,priceWithDriver: freezed == priceWithDriver ? _self.priceWithDriver : priceWithDriver // ignore: cast_nullable_to_non_nullable
as double?,priceFullPackage: freezed == priceFullPackage ? _self.priceFullPackage : priceFullPackage // ignore: cast_nullable_to_non_nullable
as double?,depositAmount: freezed == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double?,blockedDates: freezed == blockedDates ? _self._blockedDates : blockedDates // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
