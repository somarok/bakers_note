import 'package:bakers_note/common/app_colors.dart';
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
  void dispose() {
    scrollController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BakersPercentViewModel viewModel = context.watch<BakersPercentViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          '베이커스 퍼센트 계산하기',
          style: TextStyle(fontSize: 15),
        ),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          TextButton(
            child: const Text('불러오기'),
            onPressed: () {
              _showLoadRecipeDialog(context, viewModel);
            },
          ),
          TextButton(
            child: const Text('저장'),
            onPressed: () {
              // 재료명만 있고 무게가 없는 경우 확인
              final ingredientsWithoutWeight = viewModel.ingredients
                  .where((ingredient) => ingredient.name.isNotEmpty && ingredient.weight <= 0)
                  .toList();

              if (ingredientsWithoutWeight.isNotEmpty) {
                final ingredientNames = ingredientsWithoutWeight.map((ingredient) => ingredient.name).join(', ');

                _showSnackBar(context, '$ingredientNames의 무게를 입력해주세요');
                return;
              }

              // 유효한 재료가 있는지 확인
              final validIngredients = viewModel.ingredients
                  .where((ingredient) => ingredient.name.isNotEmpty && ingredient.weight > 0)
                  .toList();

              if (validIngredients.isEmpty) {
                _showSnackBar(context, '재료의 이름을 입력해주세요');
                return;
              }

              _showSaveDialog(context, viewModel);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Stack(children: [
            Padding(
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
                      child: ReorderableListView.builder(
                        scrollController: scrollController,
                        buildDefaultDragHandles: false, // 커스텀 드래그 핸들 사용
                        itemCount: viewModel.ingredients.length + 1, // 버튼을 위한 +1
                        onReorder: (oldIndex, newIndex) {
                          // 마지막 인덱스(버튼)는 재정렬 불가
                          if (oldIndex == viewModel.ingredients.length || newIndex == viewModel.ingredients.length) {
                            return;
                          }
                          viewModel.reorderIngredients(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          // 마지막 인덱스일 때 버튼 반환
                          if (index == viewModel.ingredients.length) {
                            return Container(
                              key: const ValueKey('add_button'),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor10,
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  viewModel.onPressAddIngredientButton();
                                  _scrollDown();
                                },
                                tooltip: '재료 추가',
                                icon: const Icon(Icons.add),
                              ),
                            );
                          }

                          // 그 외에는 재료 행 반환
                          final ingredient = viewModel.ingredients[index];
                          return ReorderableDragStartListener(
                            key: ValueKey(ingredient.id),
                            index: index,
                            child: IngredientFormRow(
                              key: ValueKey('ingredient_${ingredient.id}'),
                              onLongPressed: (int id) => viewModel.onLongPressedRow(ingredient.id),
                              onEditingWeightComplete: (int id) {
                                viewModel.onFinishedAddIngredient(ingredient.id);
                                _scrollDown();
                              },
                              ingredient: ingredient,
                              onDismissed: () => viewModel.onDismissedIngredient(ingredient.id),
                              onEditingIngredient: (int id, {String? name, num? weight}) =>
                                  viewModel.onEditingIngredient(id, name: name, weight: weight),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scaleButton(
                    label: '1/4',
                    scale: 0.25,
                    viewModel: viewModel,
                  ),
                  const SizedBox(width: 10),
                  _scaleButton(
                    label: '1/2',
                    scale: 0.5,
                    viewModel: viewModel,
                  ),
                  const SizedBox(width: 10),
                  _scaleButton(
                    label: '2배',
                    scale: 2.0,
                    viewModel: viewModel,
                  ),
                  const SizedBox(width: 10),
                  _scaleButton(
                    label: '4배',
                    scale: 4.0,
                    viewModel: viewModel,
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _scaleButton({
    required String label,
    required double scale,
    required BakersPercentViewModel viewModel,
  }) {
    return TextButton(
      onPressed: () async {
        // 포커스 해제 (포커스 해제 시 ViewModel 업데이트됨)
        FocusManager.instance.primaryFocus?.unfocus();

        // 포커스 해제 완료 대기 (FocusNode listener 실행 대기)
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        // 백분율 계산
        viewModel.calculatePercent();

        if (!context.mounted) return;
        _showScaledRecipeDialog(context, viewModel, scale, label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  void _scrollDown() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 80);
  }

  void _showScaledRecipeDialog(
    BuildContext context,
    BakersPercentViewModel viewModel,
    double scale,
    String title,
  ) {
    // 유효한 재료만 필터링 (이미 calculatePercent가 호출되었음)
    final validIngredients =
        viewModel.ingredients.where((ingredient) => ingredient.name.isNotEmpty && ingredient.weight > 0).toList();

    if (validIngredients.isEmpty) {
      if (!context.mounted) return;
      _showSnackBar(context, '재료와 무게를 입력해주세요');

      return;
    }

    // 스케일 적용
    final scaledIngredients = validIngredients.map((ingredient) {
      num scaledWeight = ingredient.weight * scale;
      // 소수점 한 자리로 반올림
      scaledWeight = (scaledWeight * 10).round() / 10;
      if (scaledWeight % 1 == 0) {
        scaledWeight = scaledWeight.toInt();
      }

      return ingredient.copyWith(weight: scaledWeight);
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                AppBar(
                  title: Text('$title 용량'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...scaledIngredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${ingredient.name}${ingredient.isFlour ? ' 🌾' : ''}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${ingredient.weight}g',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${ingredient.percent}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          // 스케일된 무게를 현재 재료 목록에 적용
                          for (var scaledIngredient in scaledIngredients) {
                            viewModel.onEditingIngredient(
                              scaledIngredient.id,
                              weight: scaledIngredient.weight,
                            );
                          }

                          // 백분율 다시 계산
                          viewModel.calculatePercent();

                          if (!context.mounted) return;

                          _showSnackBar(context, '$title 용량이 적용되었습니다');
                        });
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor10,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '레시피에 적용',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              // border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) async {
              final name = nameController.text;
              Navigator.of(dialogContext).pop();
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
      _showSnackBar(
        context,
        recipe.name != null
            ? '"${recipe.name}" 레시피가 저장되었습니다 (재료 ${recipe.ingredients.length}개)'
            : '레시피가 저장되었습니다 (재료 ${recipe.ingredients.length}개)',
      );
    } catch (e) {
      if (!mounted || !context.mounted) return;

      // 에러 메시지 표시
      _showSnackBar(context, '저장 중 오류가 발생했습니다: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(255, 86, 86, 86),
      ),
    );
  }

  void _showLoadRecipeDialog(BuildContext context, BakersPercentViewModel viewModel) {
    final recipes = viewModel.getSavedRecipes();

    if (recipes.isEmpty) {
      _showSnackBar(context, '저장된 레시피가 없습니다');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                AppBar(
                  title: const Text('레시피 불러오기'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            recipe.name ?? '이름 없는 레시피',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('재료: ${recipe.ingredients.length}개'),
                            ],
                          ),
                          onTap: () {
                            viewModel.loadRecipe(recipe);
                            Navigator.of(dialogContext).pop();
                            _showSnackBar(context, '레시피를 불러왔습니다');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
