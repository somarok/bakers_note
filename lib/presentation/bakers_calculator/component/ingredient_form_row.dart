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
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();

    // _focus.addListener(() {
    //   if (!_focus.hasFocus) {
    //     widget.onEditingWeightComplete(widget.ingredient.id);
    //   }
    // });
  }

  @override
  void dispose() {
    _focus.dispose();
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
      key: UniqueKey(),
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
            Checkbox(
              value: ingredient.isFlour,
              onChanged: (v) => widget.onLongPressed(ingredient.id),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: ingredient.name.isEmpty ? '' : ingredient.name,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: '재료명 입력',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (value) {
                  widget.onEditingIngredient(
                    ingredient.id,
                    name: value,
                  );
                },
                onEditingComplete: () {
                  _focus.nextFocus();
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: widget.ingredient.weight == 0
                    ? ''
                    : widget.ingredient.weight.toString(),
                focusNode: _focus,
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
                onChanged: (value) {
                  widget.onEditingIngredient(
                    ingredient.id,
                    weight: int.tryParse(value) ?? 0,
                  );
                },
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
