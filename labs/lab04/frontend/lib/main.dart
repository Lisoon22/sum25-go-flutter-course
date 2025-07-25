import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize services
  try {
    await PreferencesService.init();
    // здесь можно инициализировать другие сервисы, если потребуется
    // например: await DatabaseService.database;
  } catch (e) {
    print('Ошибка инициализации сервисов: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 04 - Database & Persistence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
