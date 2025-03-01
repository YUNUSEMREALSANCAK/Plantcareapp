import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../domain/models/plant_model.dart';
import 'plant_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PlantCubit extends Cubit<PlantState> {
  final PlantRepository _repository;

  PlantCubit(this._repository) : super(PlantState.initial());

  Future<void> addPlant({
    required String name,
    required String description,
    required String wateringFrequency,
    required String temperatureRange,
    required String ownershipDuration,
    File? imageFile,
    required String userId,
    List<bool> wateringDays = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    int? minTemperature,
    int? maxTemperature,
  }) async {
    emit(PlantState.loading());
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _repository.uploadImage(imageFile);
      }

      final plant = PlantModel(
        name: name,
        description: description,
        wateringFrequency: wateringFrequency,
        temperatureRange: temperatureRange,
        ownershipDuration: ownershipDuration,
        imageUrl: imageUrl,
        userId: userId,
        createdAt: DateTime.now(),
        wateringDays: wateringDays,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
      );

      await _repository.addPlant(plant);
      emit(PlantState.success());
    } catch (e) {
      print('Error in PlantCubit.addPlant: $e');
      emit(PlantState.error(e.toString()));
    }
  }

  Future<void> getPlants(String userId) async {
    if (userId.isEmpty) {
      emit(PlantState.error('Geçersiz kullanıcı ID'));
      return;
    }

    try {
      emit(PlantState.loading());

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Oturum hatası');
      }

      final plants = await _repository.getPlants(userId);
      emit(PlantState.loaded(plants));
    } catch (e) {
      print('Error in getPlants: $e');
      emit(PlantState.error(e.toString()));
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      emit(PlantState.loading());

      await _repository.deletePlant(plantId);

      // Refresh the plants list after deletion
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final plants = await _repository.getPlants(currentUser.uid);
        emit(PlantState.loaded(plants));
      } else {
        emit(PlantState.success());
      }
    } catch (e) {
      print('Error in deletePlant: $e');
      emit(PlantState.error(e.toString()));
    }
  }
}
