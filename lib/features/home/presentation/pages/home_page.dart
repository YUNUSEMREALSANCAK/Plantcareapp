import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../plants/presentation/pages/plants_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/utils/route_transitions.dart';
import '../../../plants/presentation/pages/add_plant_page.dart';
import '../../../weather/presentation/cubit/weather_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../plant_recognition/presentation/cubit/plant_recognition_cubit.dart';
import '../../../plant_recognition/presentation/pages/plant_recognition_result_page.dart';
import '../../../plant_recognition/presentation/pages/loading_screen.dart';
import '../../../plants/presentation/cubit/plant_cubit.dart';
import '../../../plants/presentation/cubit/plant_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _city = 'Istanbul';
  final String _userName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Hava durumu verilerini yükle
    context.read<WeatherCubit>().getWeather(city: _city, lang: 'en');

    // Bitkileri yükle
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<PlantCubit>().getPlants(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.home,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcome(_userName),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Weather Cards
                  BlocBuilder<WeatherCubit, WeatherState>(
                    builder: (context, state) {
                      if (state.status == WeatherStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (state.status == WeatherStatus.error) {
                        return Row(
                          children: [
                            _WeatherCard(
                              icon: Icons.water_drop,
                              value: 'N/A',
                              label: l10n.rainfall,
                            ),
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.thermostat,
                              value: 'N/A',
                              label: l10n.temperature,
                            ),
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.opacity,
                              value: 'N/A',
                              label: l10n.humidity,
                            ),
                          ],
                        );
                      } else if (state.status == WeatherStatus.loaded &&
                          state.weatherData != null &&
                          state.weatherData!.isNotEmpty) {
                        final weather =
                            state.weatherData![0]; // Bugünün hava durumu
                        return Row(
                          children: [
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.thermostat,
                              value: '${weather.degree}°',
                              label: l10n.temperature,
                            ),
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.opacity,
                              value: '${weather.humidity}%',
                              label: l10n.humidity,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            _WeatherCard(
                              icon: Icons.water_drop,
                              value: 'N/A',
                              label: l10n.rainfall,
                            ),
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.thermostat,
                              value: 'N/A',
                              label: l10n.temperature,
                            ),
                            const SizedBox(width: 12),
                            _WeatherCard(
                              icon: Icons.opacity,
                              value: 'N/A',
                              label: l10n.humidity,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.yourPlants,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPlantPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.addNewPlant,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlantsPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.viewAllPlants,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Yeni "Bitkini Tanı" butonu
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );

                      if (image != null && mounted) {
                        final imageFile = File(image.path);

                        // Önce yükleme ekranına git
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlantRecognitionLoadingScreen(),
                            ),
                          );
                        }

                        // Bitki tanıma işlemini başlat
                        try {
                          await context
                              .read<PlantRecognitionCubit>()
                              .recognizePlant(imageFile);
                        } catch (e) {
                          // Hata durumunda yükleme ekranı zaten sonuç sayfasına yönlendirecek
                          print('Bitki tanıma hatası: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize:
                          const Size(double.infinity, 50), // Tam genişlik
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined),
                        const SizedBox(width: 8),
                        Text(
                          l10n.recognizePlant,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Bildirimler bölümü
                  Text(
                    l10n.notifications,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bildirimler listesi
                  BlocBuilder<PlantCubit, PlantState>(
                    builder: (context, plantState) {
                      if (plantState.status == PlantStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (plantState.plants == null ||
                          plantState.plants!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.noNotifications,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // Bugünün gününü al (0: Pazartesi, 6: Pazar)
                      final today = DateTime.now().weekday - 1;

                      // Sulama bildirimleri
                      final wateringNotifications = plantState.plants!
                          .where((plant) =>
                              plant.wateringDays.length > today &&
                              plant.wateringDays[today])
                          .map((plant) => _NotificationItem(
                                icon: Icons.water_drop,
                                title: l10n.wateringTime(plant.name),
                                message: l10n.wateringMessage(plant.name),
                                color: Colors.blue.shade700,
                              ))
                          .toList();

                      // Sıcaklık bildirimleri
                      final temperatureNotifications = <_NotificationItem>[];

                      // Hava durumu verilerini kontrol et
                      final weatherState = context.watch<WeatherCubit>().state;
                      if (weatherState.status == WeatherStatus.loaded &&
                          weatherState.weatherData != null) {
                        final currentTemp = double.tryParse(
                                weatherState.weatherData!.first.degree) ??
                            0;

                        // Her bitki için sıcaklık kontrolü yap
                        for (final plant in plantState.plants!) {
                          if (plant.minTemperature != null &&
                              plant.maxTemperature != null) {
                            if (currentTemp < plant.minTemperature!) {
                              temperatureNotifications.add(_NotificationItem(
                                icon: Icons.thermostat,
                                title: l10n.lowTemperature(plant.name),
                                message: l10n.lowTemperatureMessage(
                                  currentTemp.toStringAsFixed(1),
                                  plant.name,
                                  plant.minTemperature.toString(),
                                ),
                                color: Colors.blue.shade900,
                              ));
                            } else if (currentTemp > plant.maxTemperature!) {
                              temperatureNotifications.add(_NotificationItem(
                                icon: Icons.thermostat,
                                title: l10n.highTemperature(plant.name),
                                message: l10n.highTemperatureMessage(
                                  currentTemp.toStringAsFixed(1),
                                  plant.name,
                                  plant.maxTemperature.toString(),
                                ),
                                color: Colors.red.shade700,
                              ));
                            }
                          }
                        }
                      }

                      // Tüm bildirimleri birleştir
                      final allNotifications = [
                        ...wateringNotifications,
                        ...temperatureNotifications
                      ];

                      if (allNotifications.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.noNotificationsToday,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return Column(
                        children: allNotifications,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bildirim öğesi widget'ı
class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
