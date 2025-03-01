import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class PlantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Dosya boyutunu kontrol et
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Dosya boyutu 5MB\'dan büyük olamaz');
      }

      // Benzersiz dosya adı oluştur
      final extension = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

      // Storage referansı oluştur
      final storageRef = _storage
          .ref()
          .child('plant_images')
          .child(currentUser.uid)
          .child(fileName);

      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': currentUser.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalFileName': path.basename(imageFile.path),
        },
      );

      // Görseli yükle
      final uploadTask = await storageRef.putFile(imageFile, metadata);

      if (uploadTask.state == TaskState.success) {
        // URL al ve döndür
        final downloadUrl = await storageRef.getDownloadURL();
        print('Görsel başarıyla yüklendi: $downloadUrl');
        return downloadUrl;
      }

      return null;
    } on FirebaseException catch (e) {
      print('Firebase Storage Hatası: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'unauthorized':
          throw Exception('Yetkilendirme hatası: Lütfen tekrar giriş yapın');
        case 'canceled':
          throw Exception('Yükleme iptal edildi');
        case 'storage/quota-exceeded':
          throw Exception('Depolama kotası aşıldı');
        default:
          throw Exception('Görsel yükleme hatası: ${e.message}');
      }
    } catch (e) {
      print('Beklenmeyen hata: $e');
      throw Exception('Görsel yüklenirken bir hata oluştu');
    }
  }

  Future<void> addPlant(PlantModel plant) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User session not found');
      }

      if (plant.userId != currentUser.uid) {
        throw Exception('Invalid user ID');
      }

      // Check and create collection
      final plantsCollection = _firestore.collection('plants');
      print('Plants collection reference: ${plantsCollection.path}');

      // Prepare plant data
      final plantData = {
        'name': plant.name,
        'description': plant.description,
        'watering_frequency': plant.wateringFrequency,
        'temperature_range': plant.temperatureRange,
        'ownership_duration': plant.ownershipDuration,
        'image_url': plant.imageUrl,
        'user_id': plant.userId,
        'created_at': Timestamp.fromDate(plant.createdAt),
        'watering_days': plant.wateringDays,
        'min_temperature': plant.minTemperature,
        'max_temperature': plant.maxTemperature,
      };
      print('Adding plant data: $plantData');

      // Add document
      final docRef = await plantsCollection.add(plantData);
      print('Document added with ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      print('Firebase Error Code: ${e.code}');
      print('Firebase Error Message: ${e.message}');
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An error occurred while adding the plant');
    }
  }

  Future<List<PlantModel>> getPlants(String userId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      print('Fetching plants for user: $userId');
      print('Current user ID: ${currentUser.uid}');

      // Basit sorgu ile deneyelim
      final snapshot = await _firestore
          .collection('plants')
          .where('user_id', isEqualTo: userId)
          .get();

      print('Query completed. Document count: ${snapshot.docs.length}');

      // Belgeleri kontrol et
      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
      }

      final plants = snapshot.docs
          .map((doc) => PlantModel.fromJson(doc.data(), doc.id))
          .toList();

      print('Plants parsed successfully. Count: ${plants.length}');
      return plants;
    } on FirebaseException catch (e) {
      print('Firebase Error Code: ${e.code}');
      print('Firebase Error Message: ${e.message}');
      if (e.code == 'permission-denied') {
        throw Exception(
            'Yetkilendirme hatası: Lütfen tekrar giriş yapın. (${e.message})');
      }
      throw Exception('Firebase hatası: ${e.message}');
    } catch (e) {
      print('Unexpected error in getPlants: $e');
      throw Exception('Bitkileri getirirken bir hata oluştu: $e');
    }
  }

  Stream<List<PlantModel>> getPlantsStream(String userId) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      print('Streaming plants for user: $userId');

      return _firestore
          .collection('plants')
          .where('user_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        print('Received ${snapshot.docs.length} plants in stream');
        return snapshot.docs
            .map((doc) => PlantModel.fromJson(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error in plants stream: $e');
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User session not found');
      }

      print('Deleting plant with ID: $plantId');

      // Get the plant to check ownership
      final plantDoc = await _firestore.collection('plants').doc(plantId).get();

      if (!plantDoc.exists) {
        throw Exception('Plant not found');
      }

      final plantData = plantDoc.data();
      if (plantData == null || plantData['user_id'] != currentUser.uid) {
        throw Exception('You do not have permission to delete this plant');
      }

      // Delete the plant document
      await _firestore.collection('plants').doc(plantId).delete();
      print('Plant deleted successfully');

      // If there's an image, delete it from storage too
      if (plantData['image_url'] != null) {
        try {
          // Extract the file path from the URL
          final uri = Uri.parse(plantData['image_url']);
          final pathSegments = uri.pathSegments;
          if (pathSegments.length > 1) {
            final storagePath = pathSegments.sublist(1).join('/');
            await _storage.ref(storagePath).delete();
            print('Plant image deleted from storage');
          }
        } catch (e) {
          print('Error deleting image: $e');
          // Continue even if image deletion fails
        }
      }
    } on FirebaseException catch (e) {
      print('Firebase Error Code: ${e.code}');
      print('Firebase Error Message: ${e.message}');
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      print('Unexpected error in deletePlant: $e');
      throw Exception('An error occurred while deleting the plant');
    }
  }
}
