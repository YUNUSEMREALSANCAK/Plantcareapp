import '../../domain/models/plant_model.dart';

enum PlantStatus { initial, loading, success, error, loaded }

class PlantState {
  final PlantStatus status;
  final List<PlantModel>? plants;
  final String? errorMessage;

  const PlantState({
    this.status = PlantStatus.initial,
    this.plants,
    this.errorMessage,
  });

  factory PlantState.initial() => const PlantState();

  factory PlantState.loading() => const PlantState(
        status: PlantStatus.loading,
      );

  factory PlantState.success() => const PlantState(
        status: PlantStatus.success,
      );

  factory PlantState.error(String message) => PlantState(
        status: PlantStatus.error,
        errorMessage: message,
      );

  factory PlantState.loaded(List<PlantModel> plants) => PlantState(
        status: PlantStatus.loaded,
        plants: plants,
      );
}
