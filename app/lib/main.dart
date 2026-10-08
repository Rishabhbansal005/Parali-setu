import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
import 'repositories/farmer_repository.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = RepositoryProvider.getRepository();
  runApp(ParaliSetuApp(repository: repository));
}

class ParaliSetuApp extends StatefulWidget {
  final FarmerRepository repository;

  const ParaliSetuApp({super.key, required this.repository});

  @override
  State<ParaliSetuApp> createState() => _ParaliSetuAppState();
}

class _ParaliSetuAppState extends State<ParaliSetuApp> {
  // English is the DEFAULT language per SPEC.md §13 & prompt requirements
  AppLanguage _currentLanguage = AppLanguage.english;

  void _updateLanguage(AppLanguage newLang) {
    setState(() {
      _currentLanguage = newLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParaliSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: SplashScreen(
        repository: widget.repository,
        onLanguageChanged: _updateLanguage,
        currentLanguage: _currentLanguage,
      ),
    );
  }
}
