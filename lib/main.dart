// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_iot_app/presentation/widgets/dashboard_card.dart';

/// ---------- MAIN APP ----------
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Demo',
      theme: ThemeData.dark(
        useMaterial3: false,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF0B0B0D), cardColor: const Color(0xFF1B1B1D)),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
