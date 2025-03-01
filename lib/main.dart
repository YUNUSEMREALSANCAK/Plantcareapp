import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/app/app.dart';

void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Yalnızca dikey yönlendirmeyi etkinleştir
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Uygulamayı başlat
  runApp(const App());
}
