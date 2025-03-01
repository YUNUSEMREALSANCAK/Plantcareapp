import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plant_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PlantModel {
  final String? id;
  final String name;
  final String description;
  final String wateringFrequency;
  final String temperatureRange;
  final String ownershipDuration;
  final String? imageUrl;
  final String userId;

  // Yeni alanlar
  final List<bool> wateringDays;
  final int? minTemperature;
  final int? maxTemperature;

  @JsonKey(
    fromJson: _dateTimeFromTimestamp,
    toJson: _dateTimeToTimestamp,
  )
  final DateTime createdAt;

  PlantModel({
    this.id,
    required this.name,
    required this.description,
    required this.wateringFrequency,
    required this.temperatureRange,
    required this.ownershipDuration,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
    this.wateringDays = const [false, false, false, false, false, false, false],
    this.minTemperature,
    this.maxTemperature,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json, [String? id]) {
    // wateringDays'i dönüştür
    List<bool> wateringDays = List.filled(7, false);
    if (json['watering_days'] != null) {
      final List<dynamic> days = json['watering_days'];
      for (int i = 0; i < days.length && i < 7; i++) {
        wateringDays[i] = days[i];
      }
    }

    return _$PlantModelFromJson({
      ...json,
      'id': id,
      'watering_days': wateringDays,
    });
  }

  Map<String, dynamic> toJson() => _$PlantModelToJson(this);

  // Timestamp dönüşümleri için yardımcı metodlar
  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) =>
      timestamp.toDate();
  static Timestamp _dateTimeToTimestamp(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
