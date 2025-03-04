import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant_recognition_state.freezed.dart';

enum PlantRecognitionStatus { initial, loading, success, error }

@freezed
class PlantRecognitionState with _$PlantRecognitionState {
  const factory PlantRecognitionState({
    @Default(PlantRecognitionStatus.initial) PlantRecognitionStatus status,
    File? imageFile,
    String? recognitionResult,
    String? errorMessage,
  }) = _PlantRecognitionState;
}
