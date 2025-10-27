import 'package:hive/hive.dart';
import '../model/bakers_recipe.dart';

class RecipeRepository {
  static const String _boxName = 'recipes';

  /// 레시피 저장
  Future<void> saveRecipe(BakersRecipe recipe) async {
    final box = Hive.box<BakersRecipe>(_boxName);
    await box.add(recipe);
  }

  /// 모든 레시피 가져오기
  List<BakersRecipe> getAllRecipes() {
    final box = Hive.box<BakersRecipe>(_boxName);
    return box.values.toList();
  }

  /// 특정 레시피 삭제
  Future<void> deleteRecipe(int index) async {
    final box = Hive.box<BakersRecipe>(_boxName);
    await box.deleteAt(index);
  }

  /// 특정 레시피 업데이트
  Future<void> updateRecipe(int index, BakersRecipe recipe) async {
    final box = Hive.box<BakersRecipe>(_boxName);
    await box.putAt(index, recipe);
  }

  /// 모든 레시피 삭제
  Future<void> deleteAllRecipes() async {
    final box = Hive.box<BakersRecipe>(_boxName);
    await box.clear();
  }
}
