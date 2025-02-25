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
  });

  factory PlantModel.fromJson(Map<String, dynamic> json, [String? id]) =>
      _$PlantModelFromJson({...json, 'id': id});

  Map<String, dynamic> toJson() => _$PlantModelToJson(this);

  // Timestamp dönüşümleri için yardımcı metodlar
  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) =>
      timestamp.toDate();
  static Timestamp _dateTimeToTimestamp(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
