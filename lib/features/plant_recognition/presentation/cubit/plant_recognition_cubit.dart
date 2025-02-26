import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plant_recognition_repository.dart';

enum PlantRecognitionStatus { initial, loading, success, error }

class PlantRecognitionState {
  final PlantRecognitionStatus status;
  final String? result;
  final String? errorMessage;
  final File? selectedImage;

  PlantRecognitionState({
    this.status = PlantRecognitionStatus.initial,
    this.result,
    this.errorMessage,
    this.selectedImage,
  });

  factory PlantRecognitionState.initial() => PlantRecognitionState();

  factory PlantRecognitionState.loading(File selectedImage) =>
      PlantRecognitionState(
        status: PlantRecognitionStatus.loading,
        selectedImage: selectedImage,
      );

  factory PlantRecognitionState.success(String result, File selectedImage) =>
      PlantRecognitionState(
        status: PlantRecognitionStatus.success,
        result: result,
        selectedImage: selectedImage,
      );

  factory PlantRecognitionState.error(String message, File? selectedImage) =>
      PlantRecognitionState(
        status: PlantRecognitionStatus.error,
        errorMessage: message,
        selectedImage: selectedImage,
      );
}

class PlantRecognitionCubit extends Cubit<PlantRecognitionState> {
  final PlantRecognitionRepository _repository;

  PlantRecognitionCubit(this._repository)
      : super(PlantRecognitionState.initial());

  Future<void> recognizePlant(File imageFile) async {
    try {
      emit(PlantRecognitionState.loading(imageFile));
      final result = await _repository.recognizePlant(imageFile);
      emit(PlantRecognitionState.success(result, imageFile));
    } catch (e) {
      emit(PlantRecognitionState.error(e.toString(), imageFile));
    }
  }
}
