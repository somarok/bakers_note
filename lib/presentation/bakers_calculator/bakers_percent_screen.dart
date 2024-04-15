import 'package:bakers_note/common/app_colors.dart';
import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'component/ingredient_form_row.dart';
import '../common/component/tooltip.dart';

class BakersPercentScreen extends StatefulWidget {
  const BakersPercentScreen({super.key});

  @override
  State<BakersPercentScreen> createState() => _BakersPercentScreenState();
}

class _BakersPercentScreenState extends State<BakersPercentScreen> {
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => {
        context.read<BakersPercentViewModel>().addIngredientFormRow(),
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BakersPercentViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('베이커스 퍼센트'),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            viewModel.calculatePercent();
          },
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
                          color: AppColors.primaryColorAccent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Row(children: [
                            Text(
                              '기준',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: 3),
                            ToolTipWrapper(
                              message:
                                  '베이커스 퍼센트는 밀가루의 중량을 기준으로 계산됩니다.\n밀가루에 해당되는 재료를 체크해주세요 :)',
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ]),
                        ),
                        const Expanded(
                          flex: 3,
                          child: Text(
                            '재료',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            '무게',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
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
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '재료를 오른쪽으로 스와이프하면 삭제할 수 있습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: viewModel.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredients = viewModel.ingredients;
                          return IngredientFormRow(
                            onLongPressed: (int id) => viewModel
                                .onLongPressedRow(ingredients[index].id),
                            onEditingWeightComplete: (int id) {
                              viewModel.onFinishedAddIngredient(
                                  ingredients[index].id);
                              _scrollDown();
                            },
                            ingredient: Ingredient(
                              id: ingredients[index].id,
                              name: ingredients[index].name,
                              weight: ingredients[index].weight,
                              percent: ingredients[index].percent,
                              isFlour: ingredients[index].isFlour,
                            ),
                            onDismissed: () => viewModel
                                .onDismissedIngredient(ingredients[index].id),
                            onEditingIngredient: (int id,
                                    {String? name, num? weight}) =>
                                viewModel.onEditingIngredient(id,
                                    name: name, weight: weight),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.onPressAddIngredientButton();
          _scrollDown();
        },
        tooltip: '재료 추가',
        backgroundColor: AppColors.primaryColor10,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _scrollDown() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 80);
  }
}
