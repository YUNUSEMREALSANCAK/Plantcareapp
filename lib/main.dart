import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/plants/domain/repositories/plant_repository.dart';
import 'features/plants/presentation/cubit/plant_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';
import 'features/plant_recognition/domain/repositories/plant_recognition_repository.dart';
import 'features/plant_recognition/presentation/cubit/plant_recognition_cubit.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Debug için
    print('Env dosyası yükleniyor...');
    await dotenv.load(fileName: ".env");
    print('Env dosyası yüklendi');
    print('Firebase API KEY: ${dotenv.env['FIREBASE_API_KEY']}');
    print('OpenAI API KEY mevcut mu: ${dotenv.env['OPENAI_API_KEY'] != null}');

    print('Firebase başlatılıyor...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase başlatıldı');

    final authRepository = AuthRepository();
    final plantRepository = PlantRepository();
    final weatherRepository = WeatherRepository();
    final plantRecognitionRepository = PlantRecognitionRepository();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(authRepository)),
          BlocProvider(
            create: (context) => PlantCubit(plantRepository),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => WeatherCubit(weatherRepository),
            lazy: false,
          ),
          BlocProvider(
            create: (context) =>
                PlantRecognitionCubit(plantRecognitionRepository),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Başlatma hatası: $e');
    // Uygulama hata ekranı göster
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Uygulama başlatılırken hata oluştu: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPlant',
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
