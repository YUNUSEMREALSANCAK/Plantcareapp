// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant_recognition_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlantRecognitionState {
  PlantRecognitionStatus get status => throw _privateConstructorUsedError;
  File? get imageFile => throw _privateConstructorUsedError;
  String? get recognitionResult => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PlantRecognitionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantRecognitionStateCopyWith<PlantRecognitionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantRecognitionStateCopyWith<$Res> {
  factory $PlantRecognitionStateCopyWith(PlantRecognitionState value,
          $Res Function(PlantRecognitionState) then) =
      _$PlantRecognitionStateCopyWithImpl<$Res, PlantRecognitionState>;
  @useResult
  $Res call(
      {PlantRecognitionStatus status,
      File? imageFile,
      String? recognitionResult,
      String? errorMessage});
}

/// @nodoc
class _$PlantRecognitionStateCopyWithImpl<$Res,
        $Val extends PlantRecognitionState>
    implements $PlantRecognitionStateCopyWith<$Res> {
  _$PlantRecognitionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantRecognitionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? imageFile = freezed,
    Object? recognitionResult = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PlantRecognitionStatus,
      imageFile: freezed == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File?,
      recognitionResult: freezed == recognitionResult
          ? _value.recognitionResult
          : recognitionResult // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantRecognitionStateImplCopyWith<$Res>
    implements $PlantRecognitionStateCopyWith<$Res> {
  factory _$$PlantRecognitionStateImplCopyWith(
          _$PlantRecognitionStateImpl value,
          $Res Function(_$PlantRecognitionStateImpl) then) =
      __$$PlantRecognitionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlantRecognitionStatus status,
      File? imageFile,
      String? recognitionResult,
      String? errorMessage});
}

/// @nodoc
class __$$PlantRecognitionStateImplCopyWithImpl<$Res>
    extends _$PlantRecognitionStateCopyWithImpl<$Res,
        _$PlantRecognitionStateImpl>
    implements _$$PlantRecognitionStateImplCopyWith<$Res> {
  __$$PlantRecognitionStateImplCopyWithImpl(_$PlantRecognitionStateImpl _value,
      $Res Function(_$PlantRecognitionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantRecognitionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? imageFile = freezed,
    Object? recognitionResult = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PlantRecognitionStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PlantRecognitionStatus,
      imageFile: freezed == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File?,
      recognitionResult: freezed == recognitionResult
          ? _value.recognitionResult
          : recognitionResult // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PlantRecognitionStateImpl implements _PlantRecognitionState {
  const _$PlantRecognitionStateImpl(
      {this.status = PlantRecognitionStatus.initial,
      this.imageFile,
      this.recognitionResult,
      this.errorMessage});

  @override
  @JsonKey()
  final PlantRecognitionStatus status;
  @override
  final File? imageFile;
  @override
  final String? recognitionResult;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PlantRecognitionState(status: $status, imageFile: $imageFile, recognitionResult: $recognitionResult, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantRecognitionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.imageFile, imageFile) ||
                other.imageFile == imageFile) &&
            (identical(other.recognitionResult, recognitionResult) ||
                other.recognitionResult == recognitionResult) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, imageFile, recognitionResult, errorMessage);

  /// Create a copy of PlantRecognitionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantRecognitionStateImplCopyWith<_$PlantRecognitionStateImpl>
      get copyWith => __$$PlantRecognitionStateImplCopyWithImpl<
          _$PlantRecognitionStateImpl>(this, _$identity);
}

abstract class _PlantRecognitionState implements PlantRecognitionState {
  const factory _PlantRecognitionState(
      {final PlantRecognitionStatus status,
      final File? imageFile,
      final String? recognitionResult,
      final String? errorMessage}) = _$PlantRecognitionStateImpl;

  @override
  PlantRecognitionStatus get status;
  @override
  File? get imageFile;
  @override
  String? get recognitionResult;
  @override
  String? get errorMessage;

  /// Create a copy of PlantRecognitionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantRecognitionStateImplCopyWith<_$PlantRecognitionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
