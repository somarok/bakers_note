
import 'package:flutter/material.dart';

class IngredientFormRow extends StatefulWidget {
  const IngredientFormRow({
    super.key,
    required this.onEditingComplete,
  });

  final Function onEditingComplete;
  @override
  State<IngredientFormRow> createState() => _IngredientFormRowState();
}

class _IngredientFormRowState extends State<IngredientFormRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
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
            decoration: const InputDecoration(
              hintText: '무게 입력',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 13),
            onEditingComplete: () => widget.onEditingComplete(),
          ),
        ),
        const Expanded(
          flex: 1,
          child: Text('data'),
        ),
      ],
    );
  }
}
