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
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      if (plant.userId != currentUser.uid) {
        throw Exception('Geçersiz kullanıcı ID');
      }

      // Koleksiyonu kontrol et ve oluştur
      final plantsCollection = _firestore.collection('plants');
      print('Plants collection reference: ${plantsCollection.path}');

      // Plant verilerini hazırla
      final plantData = {
        'name': plant.name,
        'description': plant.description,
        'humidity': plant.humidity,
        'growth_time': plant.growthTime,
        'image_url': plant.imageUrl,
        'user_id': plant.userId,
        'created_at': Timestamp.fromDate(plant.createdAt),
      };
      print('Adding plant data: $plantData');

      // Dokümanı ekle
      final docRef = await plantsCollection.add(plantData);
      print('Document added with ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      print('Firebase Error Code: ${e.code}');
      print('Firebase Error Message: ${e.message}');
      throw Exception('Firebase hatası: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Bitki eklenirken bir hata oluştu');
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
}
