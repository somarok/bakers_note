import 'package:bakers_note/app_log_printer.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_screen.dart';
import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:bakers_note/presentation/recipe_list/recipe_list_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(tabListener);

    // 화면이 완전히 렌더링된 후 권한 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    // FCM 알림 권한 요청 (iOS)
    final notificationSettings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log.d('FCM 알림 권한: ${notificationSettings.authorizationStatus}');

    // Android 13+ 알림 권한 요청
    final notificationStatus = await Permission.notification.request();
    log.d('Android 알림 권한: $notificationStatus');

    // 카메라 권한 요청
    final cameraStatus = await Permission.camera.request();
    log.d('카메라 권한: $cameraStatus');

    // 사진 권한 요청
    final photosStatus = await Permission.photos.request();
    log.d('사진 권한: $photosStatus');

    String? token = await messaging.getToken();
    log.d('FCM 토큰: $token');
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
          const RecipeListScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.percent), label: 'BP계산기'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '레시피 노트'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), label: '단가계산기'),
        ],
      ),
    );
  }
}
