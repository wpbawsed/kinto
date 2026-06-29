import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const ProviderScope(child: KintoApp()));
}

class KintoApp extends StatelessWidget {
  const KintoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '長者友善資源地圖',
      theme: buildAppTheme(),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
