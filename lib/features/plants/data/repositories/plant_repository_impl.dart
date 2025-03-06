import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/plant_model.dart';
import '../../domain/repositories/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  PlantRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<PlantModel>> getPlants(String userId) async {
    if (userId.isEmpty) {
      throw Exception('Kullanıcı ID boş olamaz');
    }

    final snapshot = await _firestore
        .collection('plants')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => PlantModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<PlantModel>> getPlantsStream(String userId) {
    if (userId.isEmpty) {
      throw Exception('Kullanıcı ID boş olamaz');
    }

    return _firestore
        .collection('plants')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlantModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
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
        },
      );

      // Görseli yükle
      final uploadTask = await storageRef.putFile(imageFile, metadata);

      if (uploadTask.state == TaskState.success) {
        // URL al ve döndür
        return await storageRef.getDownloadURL();
      }

      return null;
    } catch (e) {
      print('Görsel yükleme hatası: $e');
      throw Exception('Görsel yüklenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> addPlant(PlantModel plant) async {
    await _firestore.collection('plants').add(plant.toJson());
  }

  @override
  Future<void> deletePlant(String plantId) async {
    // Önce bitki resmini silmeye çalış
    try {
      final plant = await _firestore.collection('plants').doc(plantId).get();
      final data = plant.data();
      if (data != null && data['image_url'] != null) {
        final ref = _storage.refFromURL(data['image_url']);
        await ref.delete();
      }
    } catch (e) {
      // Resim silme hatası olsa bile devam et
      print('Resim silinirken hata: $e');
    }

    // Bitki belgesini sil
    await _firestore.collection('plants').doc(plantId).delete();
  }
}
