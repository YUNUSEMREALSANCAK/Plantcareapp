import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/plant_recognition_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../features/plants/presentation/cubit/plant_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PlantRecognitionResultPage extends StatelessWidget {
  const PlantRecognitionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bitki Tanıma Sonucu',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PlantRecognitionCubit, PlantRecognitionState>(
        builder: (context, state) {
          if (state.status == PlantRecognitionStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Bitki analiz ediliyor...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (state.status == PlantRecognitionStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state.status == PlantRecognitionStatus.success) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Bitki görseli
                  if (state.selectedImage != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: FileImage(state.selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Tanıma sonucu
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bitki Analiz Sonucu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPlantInfoCard(state.result ?? 'Sonuç bulunamadı'),
                      ],
                    ),
                  ),

                  // Bitkiyi Kaydet butonu
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => _savePlant(context, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Bitkiyi Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Bir hata oluştu',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  void _savePlant(BuildContext context, PlantRecognitionState state) async {
    if (state.result == null || state.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitki bilgileri eksik, kaydedilemedi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Kullanıcı kontrolü
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // API sonucundan bilgileri çıkar
      final PlantInfo plantInfo = _extractPlantInfo(state.result!);

      // Debug için bilgileri yazdır
      print('API Yanıtı: ${state.result}');
      print('Bitki adı: ${plantInfo.name}');
      print('Bilimsel adı: ${plantInfo.scientificName}');
      print('Sıcaklık aralığı: ${plantInfo.temperatureRange}');
      print('Sulama sıklığı: ${plantInfo.wateringFrequency}');
      print('Işık ihtiyacı: ${plantInfo.lightRequirement}');
      print('Toprak tercihi: ${plantInfo.soilPreference}');

      // Sulama günlerini belirle
      final List<bool> wateringDays =
          _getWateringDaysFromFrequency(plantInfo.wateringFrequency);

      // Debug için sulama günlerini yazdır
      print('Sulama günleri: $wateringDays');

      // Sıcaklık aralığını işle
      final tempRange = _processTemperatureRange(plantInfo.temperatureRange);

      // Debug için sıcaklık aralığını yazdır
      print('Min sıcaklık: ${tempRange.min}, Max sıcaklık: ${tempRange.max}');

      // Bitkiyi kaydet
      await context.read<PlantCubit>().addPlant(
            name: plantInfo.name.isNotEmpty
                ? plantInfo.name
                : "Tanımlanamayan Bitki",
            description: _createDetailedDescription(plantInfo),
            wateringFrequency: plantInfo.wateringFrequency.isNotEmpty
                ? plantInfo.wateringFrequency
                : "Belirtilmedi",
            temperatureRange: plantInfo.temperatureRange.isNotEmpty
                ? plantInfo.temperatureRange
                : "Belirtilmedi",
            ownershipDuration: 'Yeni eklendi',
            imageFile: state.selectedImage,
            userId: currentUser.uid,
            wateringDays: wateringDays,
            minTemperature: tempRange.min,
            maxTemperature: tempRange.max,
          );

      // Başarılı mesajı göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitki başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );

        // Önceki sayfaya dön
        Navigator.pop(context);
        Navigator.pop(context); // İki kez pop yaparak ana sayfaya dön
      }
    } catch (e) {
      print('Bitki kaydetme hatası: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Daha detaylı bir açıklama oluştur
  String _createDetailedDescription(PlantInfo plantInfo) {
    return '''
Bitki Bilgileri

İsim: ${_cleanMarkdown(plantInfo.name)}

Bilimsel İsim: ${_cleanMarkdown(plantInfo.scientificName)}

Sıcaklık Aralığı: ${_cleanMarkdown(plantInfo.temperatureRange)}

Sulama Sıklığı: ${_cleanMarkdown(plantInfo.wateringFrequency)}

Işık İhtiyacı: ${_cleanMarkdown(plantInfo.lightRequirement)}

Toprak Tercihi: ${_cleanMarkdown(plantInfo.soilPreference)}

Genel Bilgiler:
${_cleanMarkdown(plantInfo.generalInfo)}

Bu bilgiler yapay zeka tarafından oluşturulmuştur ve genel bilgi amaçlıdır. Bitkinin özel ihtiyaçları için uzman görüşüne başvurunuz.
''';
  }

  // API sonucundan bitki bilgilerini çıkar
  PlantInfo _extractPlantInfo(String apiResult) {
    String name = 'Tanımlanamayan Bitki';
    String scientificName = 'Belirtilmedi';
    String temperatureRange = 'Belirtilmedi';
    String wateringFrequency = 'Belirtilmedi';
    String lightRequirement = 'Belirtilmedi';
    String soilPreference = 'Belirtilmedi';
    String generalInfo = 'Belirtilmedi';

    try {
      // Tüm köşeli parantezleri bul
      final allBrackets = RegExp(r'\[([^\]]+)\]').allMatches(apiResult);
      final List<String> bracketContents = [];

      for (final match in allBrackets) {
        if (match.group(1) != null) {
          bracketContents.add(match.group(1)!.trim());
        }
      }

      print('Bulunan köşeli parantez içerikleri: $bracketContents');

      // Sırayla içerikleri al (eğer varsa)
      if (bracketContents.length >= 1) name = bracketContents[0];
      if (bracketContents.length >= 2) scientificName = bracketContents[1];
      if (bracketContents.length >= 3) temperatureRange = bracketContents[2];
      if (bracketContents.length >= 4) wateringFrequency = bracketContents[3];
      if (bracketContents.length >= 5) lightRequirement = bracketContents[4];
      if (bracketContents.length >= 6) soilPreference = bracketContents[5];
      if (bracketContents.length >= 7) generalInfo = bracketContents[6];

      // Eğer köşeli parantez bulunamazsa, eski yöntemi dene
      if (bracketContents.isEmpty) {
        // Bitki adını çıkar
        final nameRegex =
            RegExp(r'1\)\s*Bitkinin halk arasındaki ismi:[\s\n]*([^\n]+)');
        final nameMatch = nameRegex.firstMatch(apiResult);
        if (nameMatch != null && nameMatch.groupCount >= 1) {
          name = _cleanMarkdown(nameMatch.group(1)?.trim() ?? name);
        }

        // Bilimsel adını çıkar
        final scientificNameRegex =
            RegExp(r'2\)\s*Bitkinin biyolojik ismi:[\s\n]*([^\n]+)');
        final scientificNameMatch = scientificNameRegex.firstMatch(apiResult);
        if (scientificNameMatch != null &&
            scientificNameMatch.groupCount >= 1) {
          scientificName = _cleanMarkdown(
              scientificNameMatch.group(1)?.trim() ?? scientificName);
        }

        // Sıcaklık aralığını çıkar
        final tempRegex = RegExp(
            r'3\)\s*Bitkinin yaşamak için ihtiyaç duyduğu sıcaklık aralığı:[\s\n]*([^\n]+)');
        final tempMatch = tempRegex.firstMatch(apiResult);
        if (tempMatch != null && tempMatch.groupCount >= 1) {
          temperatureRange =
              _cleanMarkdown(tempMatch.group(1)?.trim() ?? temperatureRange);
        }

        // Sulama sıklığını çıkar
        final wateringRegex =
            RegExp(r'4\)\s*Bitkinin sulama aralığı:[\s\n]*([^\n]+)');
        final wateringMatch = wateringRegex.firstMatch(apiResult);
        if (wateringMatch != null && wateringMatch.groupCount >= 1) {
          wateringFrequency = _cleanMarkdown(
              wateringMatch.group(1)?.trim() ?? wateringFrequency);
        }

        // Işık ihtiyacını çıkar
        final lightRegex = RegExp(r'5\)\s*Işık ihtiyacı:[\s\n]*([^\n]+)');
        final lightMatch = lightRegex.firstMatch(apiResult);
        if (lightMatch != null && lightMatch.groupCount >= 1) {
          lightRequirement =
              _cleanMarkdown(lightMatch.group(1)?.trim() ?? lightRequirement);
        }

        // Toprak tercihini çıkar
        final soilRegex = RegExp(r'6\)\s*Toprak tercihi:[\s\n]*([^\n]+)');
        final soilMatch = soilRegex.firstMatch(apiResult);
        if (soilMatch != null && soilMatch.groupCount >= 1) {
          soilPreference =
              _cleanMarkdown(soilMatch.group(1)?.trim() ?? soilPreference);
        }

        // Genel bilgileri çıkar
        final generalInfoRegex = RegExp(
            r'7\)\s*Bitki hakkında genel bilgiler:[\s\n]*([^\n]+(?:\n[^\n]+)*)');
        final generalInfoMatch = generalInfoRegex.firstMatch(apiResult);
        if (generalInfoMatch != null && generalInfoMatch.groupCount >= 1) {
          generalInfo =
              _cleanMarkdown(generalInfoMatch.group(1)?.trim() ?? generalInfo);
        }
      }
    } catch (e) {
      print('Bitki bilgilerini çıkarma hatası: $e');
    }

    return PlantInfo(
      name: name,
      scientificName: scientificName,
      description: apiResult,
      temperatureRange: temperatureRange,
      wateringFrequency: wateringFrequency,
      lightRequirement: lightRequirement,
      soilPreference: soilPreference,
      generalInfo: generalInfo,
    );
  }

  // Sulama sıklığından sulama günlerini belirle
  List<bool> _getWateringDaysFromFrequency(String frequency) {
    List<bool> days = List.filled(7, false);

    try {
      print('İşlenen sulama sıklığı: $frequency');

      // Direkt sayı formatı (örn: "2")
      final directNumberRegex = RegExp(r'^(\d+)$');
      final directNumberMatch = directNumberRegex.firstMatch(frequency);
      if (directNumberMatch != null && directNumberMatch.groupCount >= 1) {
        final wateringCount =
            int.tryParse(directNumberMatch.group(1) ?? '0') ?? 0;
        return _assignWateringDaysByCount(wateringCount);
      }

      // Sayısal değer varsa onu çıkar
      final numericRegex = RegExp(r'(\d+)');
      final numericMatches = numericRegex.allMatches(frequency);

      if (numericMatches.isNotEmpty) {
        // İlk sayıyı al
        final wateringCount =
            int.tryParse(numericMatches.first.group(1) ?? '0') ?? 0;
        if (wateringCount > 0) {
          return _assignWateringDaysByCount(wateringCount);
        }
      }

      // Metin tabanlı ifadelere göre sulama günlerini belirle
      if (frequency.toLowerCase().contains('haftada 1') ||
          frequency.toLowerCase().contains('haftada bir') ||
          frequency.toLowerCase().contains('hafta bir') ||
          frequency.toLowerCase().contains('haftada 1 kez')) {
        // Pazartesi günü sula
        days[0] = true;
      } else if (frequency.toLowerCase().contains('haftada 2') ||
          frequency.toLowerCase().contains('haftada iki') ||
          frequency.toLowerCase().contains('hafta iki') ||
          frequency.toLowerCase().contains('haftada 2 kez')) {
        // Pazartesi ve Perşembe günleri sula
        days[0] = true;
        days[3] = true;
      } else if (frequency.toLowerCase().contains('haftada 3') ||
          frequency.toLowerCase().contains('haftada üç') ||
          frequency.toLowerCase().contains('hafta üç') ||
          frequency.toLowerCase().contains('haftada 3 kez')) {
        // Pazartesi, Çarşamba ve Cuma günleri sula
        days[0] = true;
        days[2] = true;
        days[4] = true;
      } else if (frequency.toLowerCase().contains('her gün') ||
          frequency.toLowerCase().contains('günlük') ||
          frequency.toLowerCase().contains('her gece') ||
          frequency.toLowerCase().contains('günde bir') ||
          frequency.toLowerCase().contains('her gün bir kez')) {
        // Her gün sula
        for (int i = 0; i < 7; i++) {
          days[i] = true;
        }
      } else if (frequency.toLowerCase().contains('2 günde bir') ||
          frequency.toLowerCase().contains('iki günde bir') ||
          frequency.toLowerCase().contains('gün aşırı')) {
        // İki günde bir sula
        days[0] = true;
        days[2] = true;
        days[4] = true;
        days[6] = true;
      } else if (frequency.toLowerCase().contains('3 günde bir') ||
          frequency.toLowerCase().contains('üç günde bir')) {
        // Üç günde bir sula
        days[0] = true;
        days[3] = true;
        days[6] = true;
      } else {
        // Varsayılan olarak haftada bir (Pazartesi)
        days[0] = true;
      }
    } catch (e) {
      print('Sulama günlerini belirleme hatası: $e');
      // Hata durumunda varsayılan olarak Pazartesi
      days[0] = true;
    }

    return days;
  }

  // Sulama sayısına göre günleri belirle
  List<bool> _assignWateringDaysByCount(int count) {
    List<bool> days = List.filled(7, false);

    switch (count) {
      case 1:
        // Haftada 1 kez - Pazartesi
        days[0] = true;
        break;
      case 2:
        // Haftada 2 kez - Pazartesi ve Perşembe
        days[0] = true;
        days[3] = true;
        break;
      case 3:
        // Haftada 3 kez - Pazartesi, Çarşamba ve Cuma
        days[0] = true;
        days[2] = true;
        days[4] = true;
        break;
      case 4:
        // Haftada 4 kez - Pazartesi, Salı, Perşembe, Cumartesi
        days[0] = true;
        days[1] = true;
        days[3] = true;
        days[5] = true;
        break;
      case 5:
        // Haftada 5 kez - Her gün Çarşamba ve Pazar hariç
        days[0] = true;
        days[1] = true;
        days[3] = true;
        days[4] = true;
        days[5] = true;
        break;
      case 6:
        // Haftada 6 kez - Her gün Pazar hariç
        days[0] = true;
        days[1] = true;
        days[2] = true;
        days[3] = true;
        days[4] = true;
        days[5] = true;
        break;
      case 7:
      case 0: // 0 veya 7+ durumunda her gün
      default:
        // Her gün
        for (int i = 0; i < 7; i++) {
          days[i] = true;
        }
        break;
    }

    return days;
  }

  // Sıcaklık aralığını işle
  TempRange _processTemperatureRange(String temperatureRange) {
    int? min;
    int? max;

    // Aralık formatı (örn: 18-25°C)
    final rangeRegex = RegExp(r'(\d+)\s*[-–]\s*(\d+)');
    final rangeMatch = rangeRegex.firstMatch(temperatureRange);

    if (rangeMatch != null && rangeMatch.groupCount >= 2) {
      min = int.tryParse(rangeMatch.group(1) ?? '');
      max = int.tryParse(rangeMatch.group(2) ?? '');
      return TempRange(min: min, max: max);
    }

    // Tek değer formatı (örn: 20°C)
    final singleRegex = RegExp(r'(\d+)\s*°C');
    final singleMatch = singleRegex.firstMatch(temperatureRange);

    if (singleMatch != null && singleMatch.groupCount >= 1) {
      final temp = int.tryParse(singleMatch.group(1) ?? '');
      // Tek değer varsa, min ve max aynı olsun
      return TempRange(min: temp, max: temp);
    }

    // En az/en fazla formatı
    if (temperatureRange.toLowerCase().contains('en az')) {
      final minRegex = RegExp(r'en az\s*(\d+)');
      final minMatch = minRegex.firstMatch(temperatureRange.toLowerCase());
      if (minMatch != null && minMatch.groupCount >= 1) {
        min = int.tryParse(minMatch.group(1) ?? '');
      }
    }

    if (temperatureRange.toLowerCase().contains('en fazla')) {
      final maxRegex = RegExp(r'en fazla\s*(\d+)');
      final maxMatch = maxRegex.firstMatch(temperatureRange.toLowerCase());
      if (maxMatch != null && maxMatch.groupCount >= 1) {
        max = int.tryParse(maxMatch.group(1) ?? '');
      }
    }

    // Genel sayı arama (yukarıdaki formatlar eşleşmezse)
    if (min == null && max == null) {
      final numbers = RegExp(r'(\d+)').allMatches(temperatureRange);
      final List<int> temps = [];

      for (final match in numbers) {
        if (match.group(1) != null) {
          temps.add(int.parse(match.group(1)!));
        }
      }

      if (temps.isNotEmpty) {
        temps.sort();
        if (temps.length == 1) {
          // Tek sayı varsa, hem min hem max olarak kullan
          min = max = temps.first;
        } else {
          // Birden fazla sayı varsa, en küçük ve en büyük değerleri al
          min = temps.first;
          max = temps.last;
        }
      }
    }

    return TempRange(min: min, max: max);
  }

  // Bitki bilgilerini kartlar halinde göster
  Widget _buildPlantInfoCard(String apiResult) {
    // API sonucundan bilgileri çıkar
    final PlantInfo plantInfo = _extractPlantInfo(apiResult);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bitki adı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bitki Adı',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cleanMarkdown(plantInfo.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plantInfo.scientificName != 'Belirtilmedi') ...[
                const SizedBox(height: 4),
                Text(
                  _cleanMarkdown(plantInfo.scientificName),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bakım bilgileri
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                  'Sıcaklık', plantInfo.temperatureRange, Icons.thermostat),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                  'Sulama', plantInfo.wateringFrequency, Icons.water_drop),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                  'Işık', plantInfo.lightRequirement, Icons.wb_sunny),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                  'Toprak', plantInfo.soilPreference, Icons.landscape),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Genel bilgiler
        if (plantInfo.generalInfo != 'Belirtilmedi') ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Genel Bilgiler',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cleanMarkdown(plantInfo.generalInfo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Tam API yanıtını göster
        const SizedBox(height: 24),
        ExpansionTile(
          title: const Text(
            'Detaylı API Yanıtı',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          collapsedIconColor: Colors.white70,
          iconColor: Colors.white,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: MarkdownBody(
                data: apiResult,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  strong: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    // ** işaretlerini ve markdown formatını temizle
    String cleanValue = _cleanMarkdown(value);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cleanValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Markdown işaretlerini temizle
  String _cleanMarkdown(String text) {
    return text.replaceAll('**', '').replaceAll('*', '').trim();
  }
}

// Bitki bilgilerini tutmak için yardımcı sınıf
class PlantInfo {
  final String name;
  final String scientificName;
  final String description;
  final String temperatureRange;
  final String wateringFrequency;
  final String lightRequirement;
  final String soilPreference;
  final String generalInfo;

  PlantInfo({
    required this.name,
    required this.description,
    required this.temperatureRange,
    required this.wateringFrequency,
    this.scientificName = 'Belirtilmedi',
    this.lightRequirement = 'Belirtilmedi',
    this.soilPreference = 'Belirtilmedi',
    this.generalInfo = 'Belirtilmedi',
  });
}

// Sıcaklık aralığını tutmak için yardımcı sınıf
class TempRange {
  final int? min;
  final int? max;

  TempRange({this.min, this.max});
}
