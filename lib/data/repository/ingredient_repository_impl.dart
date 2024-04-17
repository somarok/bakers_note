import 'package:bakers_note/data/model/ingredient.dart';

import '../domain/repository/ingredient_repository.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  List<Ingredient> _ingredients = [];

  @override
  Future<void> addIngredient(Ingredient ingredient) async {
    _ingredients.add(ingredient);
  }

  @override
  Future<void> deleteIngredient(int id) async {
    _ingredients.removeWhere((element) => element.id == id);
  }

  @override
  Future<List<Ingredient>> getIngredients() async {
    return _ingredients;
  }

  @override
  Future<void> updateIngredient(int id, {String? name, num? weight}) async {
    final index = _ingredients.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _ingredients[index] = _ingredients[index].copyWith(
      name: name ?? _ingredients[index].name,
      weight: weight ?? _ingredients[index].weight,
    );
  }

  @override
  Future<void> save() {
    // TODO: implement save
    throw UnimplementedError();
  }
}
