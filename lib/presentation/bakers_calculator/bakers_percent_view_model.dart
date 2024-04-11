import 'package:flutter/cupertino.dart';

import '../../data/model/ingredient.dart';

class BakersPercentViewModel with ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  // 재료 추가 버튼 클릭
  void onPressAddIngredientButton() async {
    addIngredientField();
  }

  // 재료 입력 완료시
  void onFinishAddIngredient() {
    
    addIngredientField();

    // TODO. 포커스 다음 필드로 넘기기

  }

  // 재료 입력 필드 추가
  void addIngredientField() async {
    _ingredients.add(Ingredient.empty(_ingredients.length + 1, '', 0, 0)); // TODO. id값 고민좀 더 해보기...
    notifyListeners();
  }

  void onDismissedIngredient(int id) {
    _ingredients.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  // TODO. 백분율 계산

}
