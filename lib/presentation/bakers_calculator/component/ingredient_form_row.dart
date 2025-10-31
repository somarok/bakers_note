import 'package:bakers_note/data/model/ingredient.dart';
import 'package:flutter/material.dart';

class IngredientFormRow extends StatefulWidget {
  const IngredientFormRow({
    super.key,
    required this.ingredient,
    required this.onDismissed,
    required this.onEditingIngredient,
    required this.onEditingWeightComplete,
    required this.onLongPressed,
  });

  final Ingredient ingredient;
  final Function(int id) onEditingWeightComplete;
  final Function onDismissed;
  final Function(int id, {String? name, num? weight}) onEditingIngredient;
  final Function(int id) onLongPressed;

  @override
  State<IngredientFormRow> createState() => _IngredientFormRowState();
}

class _IngredientFormRowState extends State<IngredientFormRow> {
  final _nameFocus = FocusNode();
  final _weightFocus = FocusNode();
  late TextEditingController _nameController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.ingredient.name.isEmpty ? '' : widget.ingredient.name,
    );
    _weightController = TextEditingController(
      text: widget.ingredient.weight == 0 ? '' : widget.ingredient.weight.toString(),
    );

    // 포커스를 잃을 때만 ViewModel 업데이트
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        widget.onEditingIngredient(widget.ingredient.id, name: _nameController.text);
      }
    });

    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus) {
        widget.onEditingIngredient(
          widget.ingredient.id,
          weight: int.tryParse(_weightController.text) ?? 0,
        );
      }
    });
  }

  @override
  void didUpdateWidget(IngredientFormRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 외부에서 재료명이 변경되었을 때 업데이트 (레시피 불러오기 등)
    if (widget.ingredient.name != oldWidget.ingredient.name) {
      final newName = widget.ingredient.name;
      if (!_nameFocus.hasFocus && _nameController.text != newName) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_nameFocus.hasFocus && _nameController.text != newName) {
            _nameController.value = TextEditingValue(
              text: newName,
              selection: TextSelection.collapsed(offset: newName.length),
            );
          }
        });
      }
    }

    // 외부에서 무게를 변경했을 때 업데이트 (절반 다이얼로그, 레시피 불러오기 등)
    if (widget.ingredient.weight != oldWidget.ingredient.weight) {
      final newWeight = widget.ingredient.weight == 0 ? '' : widget.ingredient.weight.toString();
      if (!_weightFocus.hasFocus && _weightController.text != newWeight) {
        // 현재 프레임이 끝난 후에 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_weightFocus.hasFocus && _weightController.text != newWeight) {
            _weightController.value = TextEditingValue(
              text: newWeight,
              selection: TextSelection.collapsed(offset: newWeight.length),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // 명시적으로 포커스 해제
    _nameFocus.unfocus();
    _weightFocus.unfocus();

    // FocusNode와 Controller dispose
    _nameFocus.dispose();
    _weightFocus.dispose();
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = widget.ingredient;
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => widget.onDismissed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 10),
        color: Colors.amber,
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
      ),
      key: ValueKey(ingredient.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1,
              spreadRadius: 1,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.drag_indicator_outlined, color: Colors.grey[400], size: 16),
            Checkbox(
              value: ingredient.isFlour,
              onChanged: (v) => widget.onLongPressed(ingredient.id),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: '재료명 입력',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13),
                onEditingComplete: () {
                  _weightFocus.requestFocus();
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _weightController,
                focusNode: _weightFocus,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '무게 입력',
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                ),
                onEditingComplete: () {
                  widget.onEditingWeightComplete(ingredient.id);
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                ingredient.percent == 0 ? '-' : '${ingredient.percent}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color.fromARGB(255, 170, 79, 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
