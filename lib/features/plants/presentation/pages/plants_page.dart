import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/plant_list_item.dart';
import 'add_plant_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/plant_cubit.dart';
import '../cubit/plant_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/utils/route_transitions.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  Future<void> _refreshPlants() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      print('Refreshing plants for user: $userId');
      try {
        await context.read<PlantCubit>().getPlants(userId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('No user found');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfaya her dönüşte bitkileri yeniden yükle
    _loadPlants();
  }

  void _loadPlants() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<PlantCubit>().getPlants(currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.myPlants,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<PlantCubit, PlantState>(
          builder: (context, state) {
            print('Current state: ${state.status}'); // Debug için
            print('Plants length: ${state.plants?.length}'); // Debug için

            if (state.status == PlantStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state.status == PlantStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? l10n.error,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final plants = state.plants;
            if (plants == null || plants.isEmpty) {
              return Center(
                child: Text(
                  l10n.noPlantsYet,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshPlants,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return PlantListItem(plant: plant);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: const Icon(Icons.add),
          onPressed: () async {
            // AddPlantPage'e git ve sonucu bekle
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPlantPage()),
            );

            // Eğer başarılı bir şekilde bitki eklendiyse (result == true), bitkileri yenile
            if (result == true) {
              _refreshPlants();
            }
          },
        ),
      ),
    );
  }
}
