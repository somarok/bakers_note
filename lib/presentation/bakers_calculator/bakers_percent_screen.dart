import 'package:bakers_note/common/app_colors.dart';
import 'package:bakers_note/data/model/ingredient.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:bakers_note/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _showSaveDialog(context, viewModel),
            tooltip: '저장',
          ),
        ],
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
                              '밀가루',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: 3),
                            ToolTipWrapper(
                              message: '베이커스 퍼센트는 밀가루의 중량을 기준으로 계산됩니다.\n밀가루에 해당되는 재료를 체크해주세요 :)',
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ]),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              '재료',
                              textAlign: TextAlign.left,
                            ),
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
                            onLongPressed: (int id) => viewModel.onLongPressedRow(ingredients[index].id),
                            onEditingWeightComplete: (int id) {
                              viewModel.onFinishedAddIngredient(ingredients[index].id);
                              _scrollDown();
                            },
                            ingredient: Ingredient(
                              id: ingredients[index].id,
                              name: ingredients[index].name,
                              weight: ingredients[index].weight,
                              percent: ingredients[index].percent,
                              isFlour: ingredients[index].isFlour,
                            ),
                            onDismissed: () => viewModel.onDismissedIngredient(ingredients[index].id),
                            onEditingIngredient: (int id, {String? name, num? weight}) =>
                                viewModel.onEditingIngredient(id, name: name, weight: weight),
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

  void _showSaveDialog(BuildContext context, BakersPercentViewModel viewModel) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('레시피 저장'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: '레시피 이름을 입력하세요',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) {
              final name = nameController.text;
              Navigator.of(dialogContext).pop();
              // 다이얼로그가 완전히 닫힌 후 정리 및 저장 작업 실행
              Future.delayed(const Duration(milliseconds: 100), () {
                nameController.dispose();
                if (!context.mounted) return;
                _saveRecipe(context, viewModel, name);
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // 다이얼로그가 완전히 닫힌 후 정리
                Future.delayed(const Duration(milliseconds: 100), () {
                  nameController.dispose();
                });
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                Navigator.of(dialogContext).pop();
                // 다이얼로그가 완전히 닫힌 후 정리 및 저장 작업 실행
                Future.delayed(const Duration(milliseconds: 100), () {
                  nameController.dispose();
                  if (!context.mounted) return;
                  _saveRecipe(context, viewModel, name);
                });
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRecipe(
    BuildContext context,
    BakersPercentViewModel viewModel,
    String recipeName,
  ) async {
    if (!mounted) return;

    try {
      final recipe = await viewModel.saveRecipe(name: recipeName.trim().isEmpty ? null : recipeName.trim());

      if (!mounted || !context.mounted) return;

      // 저장 완료 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipe.name != null
                ? '"${recipe.name}" 레시피가 저장되었습니다 (재료 ${recipe.ingredients.length}개)'
                : '레시피가 저장되었습니다 (재료 ${recipe.ingredients.length}개)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // 레시피 목록 화면으로 이동
      context.push(AppRouter.recipeList);
    } catch (e) {
      if (!mounted || !context.mounted) return;

      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
