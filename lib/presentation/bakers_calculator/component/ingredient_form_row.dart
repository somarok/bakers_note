import 'package:bakers_note/data/model/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IngredientFormRow extends StatefulWidget {
  const IngredientFormRow({
    super.key,
    required this.onEditingComplete,
    required this.ingredient,
    required this.onDismissed,
  });

  final Ingredient ingredient;
  final Function onEditingComplete;
  final Function() onDismissed;

  @override
  State<IngredientFormRow> createState() => _IngredientFormRowState();
}

class _IngredientFormRowState extends State<IngredientFormRow> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction) => widget.onDismissed!(),
      key: UniqueKey(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              widget.ingredient.id.toString(),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: widget.ingredient.name,
              decoration: const InputDecoration(
                hintText: '재료명 입력',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: widget.ingredient.weight == 0
                  ? ''
                  : widget.ingredient.weight.toString(),
              decoration: const InputDecoration(
                hintText: '무게 입력',
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
              ),
              onEditingComplete: () => widget.onEditingComplete(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              widget.ingredient.percent == 0
                  ? '-'
                  : widget.ingredient.percent.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color.fromARGB(255, 170, 79, 0)),
            ),
          ),
        ],
      ),
    );
  }
}
