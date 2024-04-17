import 'package:bakers_note/domain/repository/ingredient_repository.dart';
import 'package:bakers_note/domain/use_case/calculate_percent_use_case.dart';
import 'package:flutter/cupertino.dart';

import '../../data/model/ingredient.dart';

class BakersPercentViewModel with ChangeNotifier {
  final IngredientRepository _ingredientRepository;
  final CalculatePercentUseCase _calculatePercentUseCase =
      CalculatePercentUseCase();

  BakersPercentViewModel({
    required IngredientRepository ingredientRepository,
  }) : _ingredientRepository = ingredientRepository;

  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  /// 재료 정보 입력
  void onEditingIngredient(int id, {String? name, num? weight}) {
    _ingredientRepository.updateIngredient(id, name: name, weight: weight);
  }

  void calculatePercent() async {
    _ingredients = await _calculatePercentUseCase.execute(ingredients);
    notifyListeners();
  }

  /// 기준 설정
  void onLongPressedRow(int id) {
    final index = ingredients.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _ingredients[index] = ingredients[index].copyWith(
      isFlour: !ingredients[index].isFlour,
    );

    calculatePercent();
  }

  /// 재료 추가 버튼 클릭
  void onPressAddIngredientButton() {
    addIngredientFormRow();
  }

  /// 재료 한 줄 입력 완료시 (무게 입력 완료) 다음 열 추가
  void onFinishedAddIngredient(int id) {
    if (ingredients.last.id == id) {
      addIngredientFormRow();
    }
    calculatePercent();
  }

  /// 재료 입력 필드 추가
  void addIngredientFormRow() async {
    await _ingredientRepository.addIngredient(Ingredient.empty(
      ingredients.isEmpty ? 1 : ingredients.last.id + 1,
    ));
    _ingredients = await _ingredientRepository.getIngredients();

    notifyListeners();
  }

  /// 재료 삭제
  void onDismissedIngredient(int id) async {
    await _ingredientRepository.deleteIngredient(id);
    _ingredients = await _ingredientRepository.getIngredients();

    notifyListeners();
  }

// TODO. 입력한 백분율로 용량 조절해서 보여주기
}
