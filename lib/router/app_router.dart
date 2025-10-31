import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/presentation/ai_recipe_add/ai_recipe_add_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:bakers_note/presentation/home/home_screen.dart';
import 'package:bakers_note/presentation/recipe_detail/recipe_detail_screen.dart';
import 'package:bakers_note/presentation/recipe_list/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static const String home = '/';
  static const String bakersCalculator = '/bakers-calculator';
  static const String recipeList = '/recipe-list';
  static const String recipeDetail = '/recipe-detail';
  static const String aiRecipeAdd = '/ai-recipe-add';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: bakersCalculator,
        pageBuilder: (context, state) => MaterialPage(
          child: ChangeNotifierProvider(
            create: (_) => BakersPercentViewModel()..addIngredientFormRow(),
            child: const BakersPercentScreen(),
          ),
        ),
      ),
      GoRoute(
        path: recipeList,
        builder: (context, state) => const RecipeListScreen(),
      ),
      GoRoute(
        path: recipeDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RecipeDetailScreen(
            recipe: extra['recipe'] as BakersRecipe,
            recipeIndex: extra['index'] as int,
          );
        },
      ),
      GoRoute(
        path: aiRecipeAdd,
        builder: (context, state) => const AiRecipeAddScreen(),
      ),
    ],
  );
}
