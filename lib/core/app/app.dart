import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/plants/domain/repositories/plant_repository.dart';
import '../../features/plants/presentation/cubit/plant_cubit.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/presentation/cubit/weather_cubit.dart';
import '../../features/plant_recognition/domain/repositories/plant_recognition_repository.dart';
import '../../features/plant_recognition/presentation/cubit/plant_recognition_cubit.dart';
import '../theme/app_colors.dart';
import 'main_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final plantRepository = PlantRepository();
    final weatherRepository = WeatherRepository();
    final plantRecognitionRepository = PlantRecognitionRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository),
        ),
        BlocProvider(
          create: (context) => PlantCubit(plantRepository),
        ),
        BlocProvider(
          create: (context) => WeatherCubit(weatherRepository),
        ),
        BlocProvider(
          create: (context) =>
              PlantRecognitionCubit(plantRecognitionRepository),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            return MaterialApp(
              title: 'MyPlant',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: AppColors.background,
                fontFamily: 'Poppins',
                useMaterial3: true,
              ),
              home: const MainApp(),
            );
          } else {
            return MaterialApp(
              title: 'MyPlant',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: AppColors.background,
                fontFamily: 'Poppins',
                useMaterial3: true,
              ),
              home: const LoginPage(),
            );
          }
        },
      ),
    );
  }
}
