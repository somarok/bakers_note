import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:bakers_note/presentation/recipe_list/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static const String home = '/';
  static const String bakersCalculator = '/bakers-calculator';
  static const String recipeList = '/recipe-list';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: bakersCalculator,
        pageBuilder: (context, state) => MaterialPage(
          child: ChangeNotifierProvider<BakersPercentViewModel>(
            create: (_) => BakersPercentViewModel(),
            child: const BakersPercentScreen(),
          ),
        ),
      ),
      GoRoute(
        path: recipeList,
        builder: (context, state) => const RecipeListScreen(),
      ),
    ],
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baker\'s Note 📝'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                context.push(AppRouter.bakersCalculator);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 10),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 255, 237, 202),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      '🥐 베이커스 퍼센트 계산하기 > ',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                context.push(AppRouter.recipeList);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 255, 237, 202),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      '📙 내가 저장한 레시피 > ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
