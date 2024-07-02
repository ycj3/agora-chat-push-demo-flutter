import 'package:flutter/material.dart';
import 'package:push_demo/notifications/local_notifications_manager.dart';
import 'notifications/push_manager.dart';
import 'page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await PushManager.initialize();
  await LocalNotificationsManager.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

