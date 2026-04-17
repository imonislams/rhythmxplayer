import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'features/home/home_shell.dart';

class RhythmXApp extends StatelessWidget {
  const RhythmXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RhythmX",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}
