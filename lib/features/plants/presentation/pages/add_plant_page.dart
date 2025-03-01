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
  final _ownershipDurationController = TextEditingController();
  final _minTempController = TextEditingController();
  final _maxTempController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;

  // Sulama günleri için
  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  final List<bool> _selectedWateringDays = List.filled(7, false);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ownershipDurationController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
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
        throw Exception('Image upload failed: ${uploadTask.state}');
      }
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized') {
        throw Exception('Authorization error: Please login again');
      } else if (e.code == 'canceled') {
        throw Exception('Upload canceled');
      } else {
        throw Exception('Firebase error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during upload: $e');
      throw Exception('An error occurred while uploading the image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Seçili sulama günlerini string formatına dönüştür
  String _getWateringDaysString() {
    List<String> selectedDays = [];
    for (int i = 0; i < _selectedWateringDays.length; i++) {
      if (_selectedWateringDays[i]) {
        selectedDays.add(_weekDays[i]);
      }
    }
    return selectedDays.isEmpty ? 'Belirtilmedi' : selectedDays.join(', ');
  }

  // Sıcaklık aralığını string formatına dönüştür
  String _getTemperatureRangeString() {
    final minTemp = _minTempController.text.trim();
    final maxTemp = _maxTempController.text.trim();

    if (minTemp.isEmpty && maxTemp.isEmpty) {
      return 'Belirtilmedi';
    } else if (minTemp.isEmpty) {
      return 'En fazla ${maxTemp}°C';
    } else if (maxTemp.isEmpty) {
      return 'En az ${minTemp}°C';
    } else {
      return '${minTemp}°C - ${maxTemp}°C';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isUploading = true);

        // Kullanıcı kontrolü
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Kullanıcı oturumu bulunamadı');
        }

        // Görsel yükleme
        final imageUrl = await _uploadImage();

        // Sıcaklık aralığı oluştur
        final temperatureRange =
            '${_minTempController.text}-${_maxTempController.text}°C';

        // Sulama günlerini string'e çevir
        final wateringFrequency = _getWateringDaysString();

        // Bitki ekleme
        await context.read<PlantCubit>().addPlant(
              name: _nameController.text,
              description: _descriptionController.text,
              wateringFrequency: wateringFrequency,
              temperatureRange: temperatureRange,
              ownershipDuration: _ownershipDurationController.text,
              imageFile: _selectedImage,
              userId: currentUser.uid,
              wateringDays: _selectedWateringDays,
              minTemperature: _minTempController.text.isEmpty
                  ? null
                  : int.tryParse(_minTempController.text),
              maxTemperature: _maxTempController.text.isEmpty
                  ? null
                  : int.tryParse(_maxTempController.text),
            );

        // Başarılı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bitki başarıyla eklendi')),
          );
        }

        // Önceki sayfaya dön
        if (mounted) {
          Navigator.pop(context, true); // true değeri ile dön (başarılı işlem)
        }
      } catch (e) {
        print('Error in _submitForm: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
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
              content: Text('Plant added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.status == PlantStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Add Plant',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Görsel seçme alanı
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Plant Image',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bitki adı
                  const Text(
                    'Plant Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Color(0xFF5A7D3F),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter plant name',
                        hintStyle: TextStyle(
                            color: Color(0xFF5A7D3F).withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter plant name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Açıklama
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(
                        color: Color(0xFF5A7D3F),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter plant description',
                        hintStyle: TextStyle(
                            color: Color(0xFF5A7D3F).withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sulama günleri
                  const Text(
                    'Watering Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity, // Tam genişlik
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8, // Yatay boşluk
                          runSpacing: 8, // Dikey boşluk
                          children: List.generate(
                            _weekDays.length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedWateringDays[index] =
                                      !_selectedWateringDays[index];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedWateringDays[index]
                                      ? Colors.white
                                      : const Color(
                                          0xFF5A7D3F), // Seçiliyse beyaz, değilse daha koyu yeşil
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _weekDays[index],
                                  style: TextStyle(
                                    color: _selectedWateringDays[index]
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lütfen en az bir sulama günü seçin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sıcaklık aralığı
                  const Text(
                    'Temperature Range (°C)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _minTempController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Color(0xFF5A7D3F),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Min',
                              hintStyle: TextStyle(
                                  color: Color(0xFF5A7D3F).withOpacity(0.6)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final number = int.tryParse(value);
                                if (number == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _maxTempController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF5A7D3F)),
                            decoration: InputDecoration(
                              hintText: 'Max',
                              hintStyle: TextStyle(
                                  color: Color(0xFF5A7D3F).withOpacity(0.6)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final number = int.tryParse(value);
                                if (number == null) {
                                  return 'Geçerli bir sayı girin';
                                }

                                // Min sıcaklık kontrolü
                                if (_minTempController.text.isNotEmpty) {
                                  final minTemp =
                                      int.tryParse(_minTempController.text);
                                  if (minTemp != null && number < minTemp) {
                                    return 'Max, Min\'den büyük olmalı';
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sahiplik süresi
                  const Text(
                    'Ownership Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A8D4F), // Daha koyu yeşil
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _ownershipDurationController,
                      style: const TextStyle(color: Color(0xFF5A7D3F)),
                      decoration: InputDecoration(
                        hintText: 'E.g. 2 months',
                        hintStyle: TextStyle(
                            color: Color(0xFF5A7D3F).withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Kaydet butonu
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize:
                          const Size(double.infinity, 50), // Tam genişlik
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isUploading ? 'Saving...' : 'Save Plant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
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
            color: const Color(0xFF6A8D4F), // Daha koyu yeşil
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
