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
    required int humidity,
    required String growthTime,
    File? imageFile,
    required String userId,
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
        humidity: humidity,
        growthTime: growthTime,
        imageUrl: imageUrl,
        userId: userId,
        createdAt: DateTime.now(),
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
}
