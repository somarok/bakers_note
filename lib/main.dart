import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baker\'s Note 📝'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider<BakersPercentViewModel>(
                      create: (_) => BakersPercentViewModel(),
                      builder: (context, child) => const BakersPercentScreen(),
                    ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 10),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 255, 237, 202),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      '🥐 베이커스 퍼센트 계산하기 > ',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 255, 237, 202),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      '📙 내가 저장한 레시피 (준비중) > ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
