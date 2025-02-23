import 'package:flutter/material.dart';
import '../../domain/models/plant_model.dart';

class PlantListItem extends StatelessWidget {
  final PlantModel plant;

  const PlantListItem({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(
                plant.imageUrl ??
                    'https://images.unsplash.com/photo-1615213612138-4d1195b1c0e9',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.opacity, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${plant.humidity}%',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  plant.growthTime,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
      ),
    );
  }
}
