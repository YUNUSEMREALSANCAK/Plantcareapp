import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plant_recognition_repository.dart';
import 'plant_recognition_state.dart';

enum PlantRecognitionStatus { initial, loading, success, error }

class PlantRecognitionState {
  final PlantRecognitionStatus status;
  final String? result;
  final String? errorMessage;
  final File? selectedImage;

  const PlantRecognitionState({
    this.status = PlantRecognitionStatus.initial,
    this.result,
    this.errorMessage,
    this.selectedImage,
  });

  factory PlantRecognitionState.initial() => const PlantRecognitionState();

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

  PlantRecognitionState copyWith({
    PlantRecognitionStatus? status,
    String? result,
    String? errorMessage,
    File? selectedImage,
  }) {
    return PlantRecognitionState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class PlantRecognitionCubit extends Cubit<PlantRecognitionState> {
  final PlantRecognitionRepository _repository;

  PlantRecognitionCubit(this._repository)
      : super(const PlantRecognitionState());

  Future<String> recognizePlant(File imageFile) async {
    try {
      emit(state.copyWith(
        status: PlantRecognitionStatus.loading,
        selectedImage: imageFile,
      ));

      final result = await _repository.recognizePlant(imageFile);

      emit(state.copyWith(
        status: PlantRecognitionStatus.success,
        result: result,
      ));

      return result;
    } catch (e) {
      emit(state.copyWith(
        status: PlantRecognitionStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }
}
