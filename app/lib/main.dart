import 'package:flutter/material.dart';
import 'screens/language_choice_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParaliSetuApp());
}

class ParaliSetuApp extends StatelessWidget {
  const ParaliSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParaliSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LanguageChoiceScreen(),
    );
  }
}
