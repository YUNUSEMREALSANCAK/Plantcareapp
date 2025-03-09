import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/plant_recognition_cubit.dart';
import 'plant_recognition_result_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlantRecognitionLoadingScreen extends StatefulWidget {
  const PlantRecognitionLoadingScreen({super.key});

  @override
  State<PlantRecognitionLoadingScreen> createState() =>
      _PlantRecognitionLoadingScreenState();
}

class _PlantRecognitionLoadingScreenState
    extends State<PlantRecognitionLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _growController;
  late Animation<double> _growAnimation;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _setupAnimations();
  }

  void _setupAnimations() {
    _growController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _growAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _growController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _growController.dispose();
    super.dispose();
  }

  void _checkStatus() {
    // Cubit durumunu dinle ve başarı veya hata durumunda sonuç sayfasına git
    final state = context.read<PlantRecognitionCubit>().state;
    if (state.status == PlantRecognitionStatus.success ||
        state.status == PlantRecognitionStatus.error) {
      _navigateToResultPage();
    }
  }

  void _navigateToResultPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PlantRecognitionResultPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.analyzing,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PlantRecognitionCubit, PlantRecognitionState>(
        listener: (context, state) {
          if (state.status == PlantRecognitionStatus.success ||
              state.status == PlantRecognitionStatus.error) {
            _navigateToResultPage();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasyon
              AnimatedBuilder(
                animation: _growAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _growAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Yükleniyor göstergesi
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              // Yükleniyor metni
              Text(
                l10n.analyzing,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Bilgilendirme metni
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.analyzingInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
