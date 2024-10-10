import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:push_demo/agora-chat/message/message.dart';
import 'package:push_demo/consts.dart';
import 'package:push_demo/notifications/push_manager.dart';
import 'package:logging/logging.dart';
import 'package:push_demo/notifications/local_notifications_manager.dart';

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

  bool _isLoggedIn = false;
  // Create a logger instance
  final Logger _logger = Logger('LoginPageLogger');

  @override
  void initState() {
    super.initState();

    // Configure logger to log to the console
    Logger.root.level = Level.ALL;
    _logger.onRecord.listen((LogRecord record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

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

      /// add message listenter
      MessageManager().addMessageHandler(_handleIncomingMessage);

      /// connect to Chat Server
      try {
        await ChatClient.getInstance.loginWithAgoraToken(
          userId,
          token,
        );
        await PushManager.registerPushToken();
        setState(() {
          _isLoggedIn = true;
        });
        _logger.info('User logged in successfully.');
      } catch (e) {
        _logger.warning('Failed login : $e');
      }
    } else {
      Fluttertoast.showToast(
        msg: 'The permission was not granted regarding push notifications.',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _logout() async {
      /// disconnect to Chat Server
      bool isUnBindDeviceToken = true;
      try {
        await ChatClient.getInstance.logout(isUnBindDeviceToken);
        setState(() {
          _isLoggedIn = false;
        });
        _logger.info('User logged out. Unregisterd device token status is: $isUnBindDeviceToken');
      } catch (e) {
        _logger.warning('Failed logout : $e');
      }
  }

  Future<void> _handleIncomingMessage(ChatMessage message) async {
    _logger.warning("Message received: ${message.body.toString()}");
    
    if (message.body is ChatTextMessageBody) {
      ChatTextMessageBody body = message.body as ChatTextMessageBody;
      await LocalNotificationsManager.showNotification(
        title: message.from,
        body: body.content,
        payload: '',
      );
    } else {
      await LocalNotificationsManager.showNotification(
        title: message.from,
        body: 'Other message types content',
        payload: '',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Align buttons to left and right
              children: <Widget>[
                if (!_isLoggedIn)
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                if (_isLoggedIn)
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
