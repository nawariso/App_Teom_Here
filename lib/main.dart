import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/config/app_environment.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/monitor/data/monitor_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final bootstrapResult = await bootstrapApp(
    config: AppEnvironmentConfig.fromCompileTime(),
    resolveOptions: DefaultFirebaseOptions.forEnvironment,
    initializeFirebase: (options) async {
      await Firebase.initializeApp(options: options);
    },
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  final AuthRepository authRepository;
  final MonitorRepository monitorRepository;

  if (bootstrapResult.usesFirebase) {
    final firebaseApp = Firebase.app();
    authRepository = FirebaseAuthRepository(
      auth: FirebaseAuth.instanceFor(app: firebaseApp),
      firestore: FirebaseFirestore.instanceFor(app: firebaseApp),
    );
    monitorRepository = MonitorRepository(
      firestore: FirebaseFirestore.instanceFor(app: firebaseApp),
      storage: FirebaseStorage.instanceFor(app: firebaseApp),
    );
  } else {
    authRepository = DemoAuthRepository();
    monitorRepository = MonitorRepository.demo(assetBundle: rootBundle);
  }

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        monitorRepositoryProvider.overrideWithValue(monitorRepository),
      ],
      child: const ToemHereApp(),
    ),
  );
}
