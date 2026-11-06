import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hunter_provider.dart';
import 'screens/main_screen.dart';
import 'theme/system_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoloLevellingApp());
}

class SoloLevellingApp extends StatelessWidget {
  const SoloLevellingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HunterProvider()),
      ],
      child: MaterialApp(
        title: 'Solo Leveling System',
        debugShowCheckedModeBanner: false,
        theme: SystemTheme.themeData,
        home: const MainScreen(),
      ),
    );
  }
}
