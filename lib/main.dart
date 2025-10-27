import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // TypeAdapter 등록
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(BakersRecipeAdapter());

  // Box 열기
  await Hive.openBox<BakersRecipe>('recipes');

  runApp(const MyApp());
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
