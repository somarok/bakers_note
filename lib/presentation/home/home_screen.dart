import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:bakers_note/presentation/recipe_list/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(tabListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          ChangeNotifierProvider(
            create: (_) => BakersPercentViewModel()..addIngredientFormRow(),
            child: const BakersPercentScreen(),
          ),
          const RecipeListScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() {
          _currentIndex = value;
          _tabController.index = value;
        }),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.percent), label: '계산하기'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '레시피 노트'),
        ],
      ),
    );
  }
}
