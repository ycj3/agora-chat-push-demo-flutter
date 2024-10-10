import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/foundation.dart';

typedef MessageHandler = Future<void> Function(ChatMessage message);

class MessageManager {
  final List<MessageHandler> _messageHandlers = [];

  // Adding message event handlers
  // Handling message event

  MessageManager() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'chat_event_handler',
      ChatEventHandler(
        onMessagesReceived: (List<ChatMessage> messages) async {
          for (var message in messages) {
            await _messageListener(message);
          }
        },
      ),
    );
  }

  Future<void> _messageListener(ChatMessage message) async {
    for (var handler in _messageHandlers) {
      await handler(message);
    }
  }

  // Register an async message handler
  void addMessageHandler(MessageHandler handler) {
    _messageHandlers.add(handler);
    debugPrint("Message handler added");
  }

}
