import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:push_demo/consts.dart';
import 'package:push_demo/notifications/push_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController =
      TextEditingController(text: AgoraChatConfig.userId);
  final TextEditingController _tokenController =
      TextEditingController(text: AgoraChatConfig.userToken);

  void _login() async {
    String userId = _userIdController.text;
    String token = _tokenController.text;

    final isGranted = await PushManager.requestPermission();
    if (isGranted) {
      /// initialize Chat SDK
      ChatOptions options = ChatOptions(
          appKey: AgoraChatConfig.appKey, autoLogin: false, debugModel: true);
      options.enableFCM(AgoraChatConfig.fcmSenderID);
      options.enableAPNs(AgoraChatConfig.fcmSenderID);
      await ChatClient.getInstance.init(options);

      /// connect to Chat Server
      try {
        await ChatClient.getInstance.loginWithAgoraToken(
          userId,
          token,
        );
        await PushManager.registerPushToken();
      } catch (e) {
        if (kDebugMode) {
          print('login failed : $e');
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: 'The permission was not granted regarding push notifications.',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Token',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
