import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'views/auth/auth_gate.dart';

// Yerelde Firebase Emulator ile çalıştırmak için:
// flutter run --dart-define=USE_EMULATOR=true
// Android emülatöründe host 10.0.2.2 olmalı: --dart-define=EMULATOR_HOST=10.0.2.2
const bool useEmulator = bool.fromEnvironment('USE_EMULATOR');
const String emulatorHost = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
const String demoProjectId = 'demo-farmer-market';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (useEmulator) {
    await Firebase.initializeApp(options: _emulatorOptions());
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8085);
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmer Market',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.currentMode,
      home: const AuthGate(),
    );
  }
}

// demo- ile başlayan proje kimliği sadece emülatörde var. Gerçek projenin API anahtarı
// ve authDomain bilerek verilmiyor: web'deki Auth SDK authDomain görünce gerçek
// projenin sayfasını iframe ile açıp oradan ayar çekiyordu.
FirebaseOptions _emulatorOptions() {
  final real = DefaultFirebaseOptions.currentPlatform;
  return FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: real.appId,
    messagingSenderId: real.messagingSenderId,
    projectId: demoProjectId,
    iosBundleId: real.iosBundleId,
  );
}
