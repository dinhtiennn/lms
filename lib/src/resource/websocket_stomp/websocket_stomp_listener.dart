import 'package:logger/logger.dart';

mixin StompListener {
  final Logger logger = Logger();

  void onStompConnect() {
    logger.i('✅ STOMP CONNECTED MIXIN');
  }

  void onStompDisconnect() {
    logger.w('🔌 STOMP DISCONNECTED MIXIN');
  }

  void onStompError(dynamic error) {
    logger.e('❌ STOMP ERROR MIXIN: $error');
  }

  void onStompChatReceived(dynamic data) {
    logger.i('↩️ STOMP CHAT RECEIVED MIXIN: $data');
  }

  void onStompCommentReceived(dynamic data) {
    logger.i('↩️ STOMP COMMENT RECEIVED MIXIN: $data');
  }

  void onStompReplyReceived(dynamic data) {
    logger.i('↩️ STOMP REPLY RECEIVED MIXIN: $data');
  }
  void onStompNotificationReceived(dynamic data) {
    logger.i('↩️ STOMP NOTIFICATION RECEIVED MIXIN: $data');
  }
}
