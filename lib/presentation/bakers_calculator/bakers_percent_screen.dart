import 'package:bakers_note/presentation/component/ingredient_form_row.dart';
import 'package:flutter/material.dart';

class BakersPercentScreen extends StatefulWidget {
  const BakersPercentScreen({super.key});

  @override
  State<BakersPercentScreen> createState() => _BakersPercentScreenState();
}

class _BakersPercentScreenState extends State<BakersPercentScreen> {
  final List<IngredientFormRow> _textFormWidget = [];
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '재료',
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
                  IngredientFormRow(
                    onEditingComplete: addTextField,
                  ),
                  ..._textFormWidget.map((e) => e),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => addTextField(),
                      child: const Text('재료 추가'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 동적으로 폼필드 추가시키기
  void addTextField() {
    setState(() {
      _textFormWidget.add(IngredientFormRow(
        onEditingComplete: addTextField,
      ));
    });
  }

  // TODO. 백분율 계산 후 텍스트 표시
  // TODO. 백분율 기준점 선택해서 설정하는 함수
  // TODO. 입력한 백분율로 용량 조절해서 보여주기
}
