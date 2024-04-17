import 'package:bakers_note/data/model/ingredient.dart';

abstract interface class IngredientRepository {
  Future<List<Ingredient>> getIngredients();

  Future<void> addIngredient(Ingredient ingredient);

  Future<void> deleteIngredient(int id);

  Future<void> updateIngredient(int id, {String? name, num? weight});

  Future<void> save();
}
