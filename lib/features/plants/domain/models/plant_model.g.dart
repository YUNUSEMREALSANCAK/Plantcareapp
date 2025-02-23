// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantModel _$PlantModelFromJson(Map<String, dynamic> json) => PlantModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      humidity: (json['humidity'] as num).toInt(),
      growthTime: json['growth_time'] as String,
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
      'humidity': instance.humidity,
      'growth_time': instance.growthTime,
      'image_url': instance.imageUrl,
      'user_id': instance.userId,
      'created_at': PlantModel._dateTimeToTimestamp(instance.createdAt),
    };
