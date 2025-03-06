import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/plant_model.dart';
import '../cubit/plant_cubit.dart';
import '../cubit/plant_state.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PlantDetailPage extends StatelessWidget {
  final PlantModel plant;

  const PlantDetailPage({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bitki Detayları',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: BlocListener<PlantCubit, PlantState>(
        listener: (context, state) {
          if (state.status == PlantStatus.success) {
            // Navigate back to home page after successful deletion
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state.status == PlantStatus.error) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Bir hata oluştu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      plant.imageUrl ??
                          'https://images.unsplash.com/photo-1615213612138-4d1195b1c0e9',
                    ),
                    fit: BoxFit.cover,
                    onError: (_, __) => const Icon(Icons.error),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.water_drop,
                            label: plant.wateringFrequency,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.thermostat,
                            label: plant.temperatureRange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Plant Details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bitki bilgilerini göster
                    _buildPlantInfoSection(plant.description),

                    const SizedBox(height: 24),

                    // Sulama Günleri
                    if (plant.wateringDays.contains(true)) ...[
                      const Text(
                        'Sulama Günleri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWateringDaysIndicator(plant.wateringDays),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantInfoSection(String description) {
    // Markdown formatındaki metni işle
    final Map<String, String> plantInfo =
        _extractPlantInfoFromMarkdown(description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bitki Bilgileri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plantInfo['bilimselIsim'] != null &&
                  plantInfo['bilimselIsim']!.isNotEmpty)
                _buildInfoRow('Bilimsel İsim:', plantInfo['bilimselIsim']!,
                    Icons.science),
              if (plantInfo['sicaklikAraligi'] != null &&
                  plantInfo['sicaklikAraligi']!.isNotEmpty)
                _buildInfoRow('Sıcaklık Aralığı:',
                    plantInfo['sicaklikAraligi']!, Icons.thermostat),
              if (plantInfo['sulamaSikligi'] != null &&
                  plantInfo['sulamaSikligi']!.isNotEmpty)
                _buildInfoRow('Sulama Sıklığı:', plantInfo['sulamaSikligi']!,
                    Icons.water_drop),
              if (plantInfo['isikIhtiyaci'] != null &&
                  plantInfo['isikIhtiyaci']!.isNotEmpty)
                _buildInfoRow('Işık İhtiyacı:', plantInfo['isikIhtiyaci']!,
                    Icons.wb_sunny),
              if (plantInfo['toprakTercihi'] != null &&
                  plantInfo['toprakTercihi']!.isNotEmpty)
                _buildInfoRow('Toprak Tercihi:', plantInfo['toprakTercihi']!,
                    Icons.landscape),
            ],
          ),
        ),
        if (plantInfo['genelBilgiler'] != null &&
            plantInfo['genelBilgiler']!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Genel Bilgiler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              plantInfo['genelBilgiler']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _extractPlantInfoFromMarkdown(String markdown) {
    final Map<String, String> info = {};

    // Markdown işaretlerini temizle
    String cleanMarkdown = _cleanMarkdownText(markdown);

    // Bilimsel isim - hem markdown hem düz metin için
    final scientificNameRegex = RegExp(
        r'Bilimsel İsim:?\s*(.+?)(?=\n\n|\n[A-ZÇĞİÖŞÜ]|\Z)',
        dotAll: true);
    final scientificNameMatch = scientificNameRegex.firstMatch(cleanMarkdown);
    if (scientificNameMatch != null) {
      info['bilimselIsim'] = scientificNameMatch.group(1)?.trim() ?? '';
    }

    // Sıcaklık aralığı - hem markdown hem düz metin için
    final tempRangeRegex = RegExp(
        r'Sıcaklık Aralığı:?\s*(.+?)(?=\n\n|\n[A-ZÇĞİÖŞÜ]|\Z)',
        dotAll: true);
    final tempRangeMatch = tempRangeRegex.firstMatch(cleanMarkdown);
    if (tempRangeMatch != null) {
      info['sicaklikAraligi'] = tempRangeMatch.group(1)?.trim() ?? '';
    }

    // Sulama sıklığı - hem markdown hem düz metin için
    final wateringRegex = RegExp(
        r'Sulama Sıklığı:?\s*(.+?)(?=\n\n|\n[A-ZÇĞİÖŞÜ]|\Z)',
        dotAll: true);
    final wateringMatch = wateringRegex.firstMatch(cleanMarkdown);
    if (wateringMatch != null) {
      info['sulamaSikligi'] = wateringMatch.group(1)?.trim() ?? '';
    }

    // Işık ihtiyacı - hem markdown hem düz metin için
    final lightRegex = RegExp(
        r'Işık İhtiyacı:?\s*(.+?)(?=\n\n|\n[A-ZÇĞİÖŞÜ]|\Z)',
        dotAll: true);
    final lightMatch = lightRegex.firstMatch(cleanMarkdown);
    if (lightMatch != null) {
      info['isikIhtiyaci'] = lightMatch.group(1)?.trim() ?? '';
    }

    // Toprak tercihi - hem markdown hem düz metin için
    final soilRegex = RegExp(
        r'Toprak Tercihi:?\s*(.+?)(?=\n\n|\n[A-ZÇĞİÖŞÜ]|\Z)',
        dotAll: true);
    final soilMatch = soilRegex.firstMatch(cleanMarkdown);
    if (soilMatch != null) {
      info['toprakTercihi'] = soilMatch.group(1)?.trim() ?? '';
    }

    // Genel bilgiler - hem markdown hem düz metin için
    final generalInfoRegex =
        RegExp(r'Genel Bilgiler:?\s*(.+?)(?=\Z)', dotAll: true);
    final generalInfoMatch = generalInfoRegex.firstMatch(cleanMarkdown);
    if (generalInfoMatch != null) {
      info['genelBilgiler'] = generalInfoMatch.group(1)?.trim() ?? '';
    }

    return info;
  }

  // Markdown işaretlerini temizle
  String _cleanMarkdownText(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('_', '')
        .replaceAll('`', '')
        .trim();
  }

  Widget _buildWateringDaysIndicator(List<bool> wateringDays) {
    final List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          7,
          (index) => _DayIndicator(
            day: days[index],
            isSelected:
                index < wateringDays.length ? wateringDays[index] : false,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Bitki Silinecek',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bu bitkiyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deletePlant(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlant(BuildContext context) async {
    try {
      // Silme işlemini başlat
      await context.read<PlantCubit>().deletePlant(plant.id!);

      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitki başarıyla silindi')),
      );

      // Bitkilerim sayfasına geri dön
      Navigator.pop(context);
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool isSelected;

  const _DayIndicator({
    required this.day,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              Icons.water_drop,
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
