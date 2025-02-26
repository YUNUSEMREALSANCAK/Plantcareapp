class WeatherModel {
  final String date;
  final String day;
  final String icon;
  final String description;
  final String status;
  final String degree;
  final String min;
  final String max;
  final String night;
  final String humidity;

  WeatherModel({
    required this.date,
    required this.day,
    required this.icon,
    required this.description,
    required this.status,
    required this.degree,
    required this.min,
    required this.max,
    required this.night,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      degree: json['degree'] ?? '',
      min: json['min'] ?? '',
      max: json['max'] ?? '',
      night: json['night'] ?? '',
      humidity: json['humidity'] ?? '',
    );
  }
}
