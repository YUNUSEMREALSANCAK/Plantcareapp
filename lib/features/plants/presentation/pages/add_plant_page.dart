import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/plant_cubit.dart';
import '../cubit/plant_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _humidityController = TextEditingController();
  final _growthTimeController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _humidityController.dispose();
    _growthTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print('Image selected: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() => _isUploading = true);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User session not found');

      print('Uploading image for user: $userId');
      print('Image path: ${_selectedImage!.path}');

      // Görsel boyutunu kontrol et
      final fileSize = await _selectedImage!.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image size must be less than 5MB');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('plant_images')
          .child(userId)
          .child(fileName);

      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Görseli yükle
      final uploadTask = await storageRef.putFile(_selectedImage!, metadata);

      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        print('Image uploaded successfully. URL: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Görsel yükleme başarısız oldu: ${uploadTask.state}');
      }
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized') {
        throw Exception('Yetkilendirme hatası: Lütfen tekrar giriş yapın');
      } else if (e.code == 'canceled') {
        throw Exception('Yükleme iptal edildi');
      } else {
        throw Exception('Firebase hatası: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during upload: $e');
      throw Exception('Görsel yüklenirken bir hata oluştu: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User session not found');
        }

        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();
        final humidity = int.parse(_humidityController.text.trim());
        final growthTime = _growthTimeController.text.trim();

        await context.read<PlantCubit>().addPlant(
              name: name,
              description: description,
              humidity: humidity,
              growthTime: growthTime,
              imageFile: _selectedImage,
              userId: currentUser.uid,
            );

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantCubit, PlantState>(
      listener: (context, state) {
        if (state.status == PlantStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plant added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Bitki ekledikten sonra listeyi yenile
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            context.read<PlantCubit>().getPlants(userId);
          }
          Navigator.pop(context);
        } else if (state.status == PlantStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Add New Plant',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 48,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                _CustomTextField(
                  controller: _nameController,
                  label: 'Plant Name',
                  hintText: 'Enter plant name',
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                  controller: _descriptionController,
                  label: 'Açıklama',
                  hintText: 'Bitki hakkında detaylı bilgi',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                  controller: _humidityController,
                  label: 'Nem Oranı (%)',
                  hintText: 'Örn: 90',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                  controller: _growthTimeController,
                  label: 'Yetişme Süresi',
                  hintText: 'Örn: 4-5 Ay',
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isUploading ? 'Saving...' : 'Save Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int? maxLines;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
