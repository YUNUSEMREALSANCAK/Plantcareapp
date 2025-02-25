// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantModel _$PlantModelFromJson(Map<String, dynamic> json) => PlantModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      wateringFrequency: json['watering_frequency'] as String,
      temperatureRange: json['temperature_range'] as String,
      ownershipDuration: json['ownership_duration'] as String,
      imageUrl: json['image_url'] as String?,
      userId: json['user_id'] as String,
      createdAt:
          PlantModel._dateTimeFromTimestamp(json['created_at'] as Timestamp),
    );

Map<String, dynamic> _$PlantModelToJson(PlantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'watering_frequency': instance.wateringFrequency,
      'temperature_range': instance.temperatureRange,
      'ownership_duration': instance.ownershipDuration,
      'image_url': instance.imageUrl,
      'user_id': instance.userId,
      'created_at': PlantModel._dateTimeToTimestamp(instance.createdAt),
    };
