import 'package:logger/logger.dart';

mixin StompListener {
  final Logger logger = Logger();

  void onStompConnect() {
    logger.i('✅ STOMP CONNECTED');
  }

  void onStompDisconnect() {
    logger.w('🔌 STOMP DISCONNECTED');
  }

  void onStompError(dynamic error) {
    logger.e('❌ STOMP ERROR: $error');
  }

  void onStompChatReceived(dynamic data) {
    logger.i('↩️ STOMP CHAT RECEIVED: $data');
  }

  void onStompCommentReceived(dynamic data) {
    logger.i('↩️ STOMP COMMENT RECEIVED: $data');
  }

  void onStompReplyReceived(dynamic data) {
    logger.i('↩️ STOMP REPLY RECEIVED: $data');
  }
  void onStompNotificationReceived(dynamic data) {
    logger.i('↩️ STOMP NOTIFICATION RECEIVED: $data');
  }
}
