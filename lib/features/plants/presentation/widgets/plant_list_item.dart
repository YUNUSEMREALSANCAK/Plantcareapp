import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/plant_model.dart';
import '../pages/plant_detail_page.dart';

class PlantListItem extends StatelessWidget {
  final PlantModel plant;

  const PlantListItem({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'plant-${plant.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantDetailPage(plant: plant),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                      ? Image.network(
                          plant.imageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade800,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Resim yükleme hatası: $error');
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade800,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white70,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plant.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plant.wateringFrequency,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
