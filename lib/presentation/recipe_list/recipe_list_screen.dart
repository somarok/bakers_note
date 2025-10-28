import 'package:bakers_note/data/model/bakers_recipe.dart';
import 'package:bakers_note/data/repository/recipe_repository.dart';
import 'package:flutter/material.dart';
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
        title: const Text('내 레시피'),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Text('재료: ${recipe.ingredients.length}개'),
                        Text(
                          '생성일: ${DateFormat('yyyy-MM-dd HH:mm').format(recipe.createdAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecipe(index),
                    ),
                    onTap: () => _showRecipeDetails(recipe),
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

  void _showRecipeDetails(BakersRecipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                AppBar(
                  title: Text(recipe.name ?? '레시피 상세'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '생성일: ${DateFormat('yyyy-MM-dd HH:mm').format(recipe.createdAt)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '재료 목록:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${ingredient.name}${ingredient.isFlour ? ' 🌾' : ''}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${ingredient.weight}g',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${ingredient.percent}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
