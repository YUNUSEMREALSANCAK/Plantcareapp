import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import '../language/language_cubit.dart';
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
        BlocProvider(
          create: (context) => LanguageCubit(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return MaterialApp(
                title: 'MyPlant',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: AppColors.primary,
                  scaffoldBackgroundColor: AppColors.background,
                  fontFamily: 'Poppins',
                  useMaterial3: true,
                ),
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('tr'),
                ],
                home: _buildHomeScreen(state),
                routes: {
                  '/home': (context) {
                    // Route argümanlarını kontrol et
                    final args = ModalRoute.of(context)?.settings.arguments;
                    int initialIndex = 0;

                    // Eğer argüman varsa ve int tipindeyse, initialIndex olarak kullan
                    if (args != null && args is int) {
                      initialIndex = args;
                    }

                    return MainApp(initialIndex: initialIndex);
                  },
                  '/login': (context) => const LoginPage(),
                },
              );
            },
          );
        },
      ),
    );
  }

  // Kullanıcı durumuna göre ana ekranı belirle
  Widget _buildHomeScreen(AuthState state) {
    // Kullanıcı kimliği doğrulanmışsa ana uygulamayı göster
    if (state.status == AuthStatus.authenticated && state.user != null) {
      return const MainApp(initialIndex: 0);
    }

    // Diğer tüm durumlarda giriş sayfasını göster
    return const LoginPage();
  }
}
