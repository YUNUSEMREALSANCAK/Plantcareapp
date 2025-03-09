import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../plants/presentation/cubit/plant_cubit.dart';
import '../../../plants/presentation/cubit/plant_state.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../plants/presentation/pages/plants_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/route_transitions.dart';
import '../../../../core/language/language_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPlantData();
  }

  void _loadUserData() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  void _loadPlantData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<PlantCubit>().getPlants(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil Bilgileri
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Profil Resmi
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white24,
                      child: Text(
                        _user?.displayName?.isNotEmpty == true
                            ? _user!.displayName!.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kullanıcı Adı
                    Text(
                      _user?.displayName ?? l10n.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Bitki Sayısı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BlocBuilder<PlantCubit, PlantState>(
                  builder: (context, state) {
                    final plantCount = state.plants?.length ?? 0;
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_florist,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalPlants,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              l10n.plantsCount(plantCount.toString()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Dil Değiştirme Butonu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appLanguage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(child: _buildLanguageSwitch(context)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Çıkış Yap Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthCubit>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.logout,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Ekstra boşluk
            ],
          ),
        ),
      ),
    );
  }

  // Dil değiştirme butonu
  Widget _buildLanguageSwitch(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCubit = context.watch<LanguageCubit>();
    final currentLocale = languageCubit.state.languageCode;
    final _isTurkish = currentLocale == 'tr';

    return Container(
      height: 50,
      width:
          MediaQuery.of(context).size.width - 100, // Padding hesaba katılarak
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Stack(
        children: [
          // Kaydırılabilir seçici
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left:
                _isTurkish ? 0 : (MediaQuery.of(context).size.width - 100) / 2,
            child: Container(
              width: (MediaQuery.of(context).size.width - 100) / 2,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Dil seçenekleri
          Row(
            children: [
              // Türkçe seçeneği
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    languageCubit.changeLanguage('tr');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🇹🇷',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.turkish,
                          style: TextStyle(
                            color: _isTurkish ? Colors.white : Colors.white70,
                            fontWeight: _isTurkish
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // İngilizce seçeneği
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    languageCubit.changeLanguage('en');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🇬🇧',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.english,
                          style: TextStyle(
                            color: !_isTurkish ? Colors.white : Colors.white70,
                            fontWeight: !_isTurkish
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
