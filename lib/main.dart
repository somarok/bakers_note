import 'dart:async';

import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/di/di_setup.dart';
import 'package:bakers_note/firebase_options.dart';
import 'package:bakers_note/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

var firebaseCrashlytics = FirebaseCrashlytics.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    firebaseCrashlytics.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    firebaseCrashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Hive 초기화
  await Hive.initFlutter();

  // TypeAdapter 등록
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(BakersRecipeAdapter());

  // Box 열기
  await Hive.openBox<BakersRecipe>('recipes');

  diSetup();

  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) => firebaseCrashlytics.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
