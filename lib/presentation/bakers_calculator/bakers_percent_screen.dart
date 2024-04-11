import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'component/ingredient_form_row.dart';

class BakersPercentScreen extends StatefulWidget {
  const BakersPercentScreen({super.key});

  @override
  State<BakersPercentScreen> createState() => _BakersPercentScreenState();
}

class _BakersPercentScreenState extends State<BakersPercentScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BakersPercentViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: BorderDirectional(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 255, 204, 0),
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '재료',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '무게',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '백분율',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    '재료를 좌우로 스와이프하면 삭제할 수 있습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredients = viewModel.ingredients;
                      return Dismissible(
                        key: UniqueKey(),
                        child: IngredientFormRow(
                          onEditingComplete: viewModel.onFinishAddIngredient,
                          ingredient: Ingredient(
                            id: ingredients[index].id,
                            name: ingredients[index].name,
                            weight: ingredients[index].weight,
                            percent: ingredients[index].percent,
                          ),
                          onDismissed: () => viewModel
                              .onDismissedIngredient(ingredients[index].id),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => viewModel.onPressAddIngredientButton(),
                    child: const Text('재료 추가'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TODO. 백분율 계산 후 텍스트 표시
  // TODO. 백분율 기준점 선택해서 설정하는 함수
  // TODO. 입력한 백분율로 용량 조절해서 보여주기
}
