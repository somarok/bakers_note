import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        title: const Text('베이커스 노트'),
      ),
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const AlertDialog(
                      title: Text('text'),
                    );
                  });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: const Row(
                children: [
                  Text(
                    '베이커스 퍼센트 계산기',
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
