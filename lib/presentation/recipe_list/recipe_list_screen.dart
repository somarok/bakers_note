import 'package:bakers_note/common/app_colors.dart';
import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/repository/recipe_repository.dart';
import 'package:bakers_note/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeRepository _repository = RecipeRepository();
  List<BakersRecipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _recipes = _repository.getAllRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 레시피 📝'),
        surfaceTintColor: AppColors.primaryColor90,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI로 레시피 추가',
            onPressed: () {
              context.push(AppRouter.aiRecipeAdd).then((result) {
                if (result == true) {
                  _loadRecipes();
                }
              });
            },
          ),
        ],
      ),
      body: _recipes.isEmpty
          ? const Center(
              child: Text(
                '저장된 레시피가 없습니다.\n레시피를 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      recipe.name ?? '이름 없는 레시피',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('재료 ${recipe.ingredients.length}개'),
                            Text(
                              DateFormat('yyyy.MM.dd HH:mm').format(recipe.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 122, 122, 122)),
                      onPressed: () => _deleteRecipe(index),
                    ),
                    onTap: () {
                      context.push(
                        AppRouter.recipeDetail,
                        extra: {
                          'recipe': recipe,
                          'index': index,
                        },
                      ).then((_) {
                        // 화면에서 돌아올 때 목록 새로고침
                        _loadRecipes();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  void _deleteRecipe(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('레시피 삭제'),
          content: const Text('이 레시피를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await _repository.deleteRecipe(index);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _loadRecipes();
                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('레시피가 삭제되었습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
