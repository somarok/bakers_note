import 'package:flutter/cupertino.dart';

import '../../data/model/ingredient.dart';

class BakersPercentViewModel with ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  /// 재료 정보 입력
  void onEditingIngredient(int id, {String? name, num? weight}) {
    final index = _ingredients.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _ingredients[index] = _ingredients[index].copyWith(
      name: name ?? _ingredients[index].name,
      weight: weight ?? _ingredients[index].weight,
    );
  }

  void calculatePercent() {
    num flourWeight = 0;

    final List<Ingredient> newIngredients = List.from(_ingredients);

    flourWeight = newIngredients
        .where((ingredient) => ingredient.isFlour)
        .map((ingredient) => ingredient.weight)
        .fold(0, (prev, curr) => prev + curr);

    // 각 재료 객체의 percent 값을 계산하여 업데이트
    _ingredients = newIngredients.map((ingredient) {
      // 밀가루의 무게가 0이 아닌 경우에만 percent 값을 계산하여 업데이트
      if (flourWeight != 0) {
        num percent =
            (((ingredient.weight / flourWeight) * 100 * 10).round()) / 10;
        if (percent % 1 == 0) {
          percent = percent.toInt();
        }

        return ingredient.copyWith(
          percent: percent,
        );
      } else {
        // 밀가루의 무게가 0이면 percent 값을 0으로 설정
        return ingredient.copyWith(percent: 0);
      }
    }).toList();

    notifyListeners();
  }

  /// 기준 설정
  void onLongPressedRow(int id) {
    final index = _ingredients.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _ingredients[index] = _ingredients[index].copyWith(
      isFlour: !_ingredients[index].isFlour,
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
  void addIngredientFormRow() {
    _ingredients.add(Ingredient.empty(
      _ingredients.isEmpty ? 1 : _ingredients.last.id + 1,
    ));

    notifyListeners();
  }

  /// 재료 삭제
  void onDismissedIngredient(int id) {
    _ingredients.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  // TODO. 입력한 백분율로 용량 조절해서 보여주기
}
