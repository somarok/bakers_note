import 'package:bakers_note/data/model/ingredient.dart';

class CalculatePercentUseCase {

  Future<List<Ingredient>> execute(List<Ingredient> ingredients) async {
    final num flourWeight = ingredients
        .where((ingredient) => ingredient.isFlour)
        .map((ingredient) => ingredient.weight)
        .fold(0, (prev, curr) => prev + curr);

    // 각 재료 객체의 percent 값을 계산하여 업데이트
    return ingredients.map((ingredient) {
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
  }
}