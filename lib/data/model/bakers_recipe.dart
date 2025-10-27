import 'package:hive/hive.dart';
import 'ingredient.dart';

part 'bakers_recipe.g.dart';

@HiveType(typeId: 1)
class BakersRecipe {
  @HiveField(0)
  final String? name;

  @HiveField(1)
  final List<Ingredient> ingredients;

  @HiveField(2)
  final DateTime createdAt;

  const BakersRecipe({
    this.name,
    required this.ingredients,
    required this.createdAt,
  });

  BakersRecipe copyWith({
    String? name,
    List<Ingredient>? ingredients,
    DateTime? createdAt,
  }) {
    return BakersRecipe(
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BakersRecipe.fromJson(Map<String, dynamic> json) {
    return BakersRecipe(
      name: json['name'] as String?,
      ingredients: (json['ingredients'] as List)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'BakersRecipe{name: $name, ingredients: $ingredients, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BakersRecipe &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          createdAt == other.createdAt);

  @override
  int get hashCode => name.hashCode ^ createdAt.hashCode;
}
