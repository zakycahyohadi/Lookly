import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookly/models/history_item.dart';
import 'package:lookly/screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file .env
  await dotenv.load();

  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());

  // Membuka box Hive
  var historyBox = await Hive.openBox<HistoryItem>('historyBox');

  // Verifikasi apakah box berhasil dibuka
  if (historyBox.isOpen) {
    print('History box opened successfully!');
  } else {
    print('Failed to open History box');
  }

  // Menjalankan aplikasi
  runApp(
    kIsWeb
        ? DevicePreview(
            enabled: true,
            builder: (context) => const MyApp(),
          )
        : const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: kIsWeb,
      debugShowCheckedModeBanner: false,
      title: 'Gemini Vision App',
      builder: kIsWeb ? DevicePreview.appBuilder : null,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurpleAccent,
      ),
      home: const HomePage(),
    );
  }
}
