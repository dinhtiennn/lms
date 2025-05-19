import 'dart:ui';

import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:logger/logger.dart';

enum StompListenType {
  chatBox,
  chatBoxCreate,
  comment,
  editComment,
  reply,
  editReply,
  notification,
}

class RegisterStomp {
  final StompListener listener;
  final List<StompListenType> events;

  RegisterStomp({required this.listener, required this.events});

  @override
  String toString() {
    return 'RegisterStomp{listener: $listener, events: $events}';
  }
}

class StompService {
  static StompService? _instance;
  final Set<String> _subscribedDestinations = {};
  final Map<String, StompUnsubscribe> _unsubscribeMap = {};

  static Future<StompService> instance() async {
    _instance ??= StompService();
    if (_instance!._client == null || !_instance!._client!.connected) {
      _instance!.connect();
    }
    return _instance!;
  }

  final Logger _logger = Logger();
  final List<RegisterStomp> _listeners = [];
  StompClient? _client;

  void connect() async {
    await StudentRepository().myInfo(); // kiểm tra và làm mới token

    if (_client != null && _client!.connected) return;

    _client = StompClient(
      config: StompConfig(
          url: AppEndpoint.baseWebsocket,
          onConnect: _onConnect,
          onWebSocketError: _onError,
          onDisconnect: _onDisconnect,
          heartbeatIncoming: Duration(seconds: 5),
          heartbeatOutgoing: Duration(seconds: 5),
          stompConnectHeaders: {
            'Authorization': 'Bearer ${AppPrefs.accessToken}'
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer ${AppPrefs.accessToken}'
          },
          useSockJS: true),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _logger.i("🟢 STOMP Connected");
    _subscribedDestinations.clear();

    for (var type in StompListenType.values) {
      if (type == StompListenType.chatBox) continue;

      final destination = _getDestination(type);
      if (destination != null && !_subscribedDestinations.contains(destination)) {
        final unsubscribe = _client!.subscribe(
          destination: destination,
          callback: (frame) {
            for (var reg in _listeners) {
              if (reg.events.contains(type)) {
                _handleIncoming(type, reg.listener, frame.body);
              }
            }
          },
        );
        _logger.i("📡 Subscribed to $destination");
        _unsubscribeMap[destination] = unsubscribe;
        _subscribedDestinations.add(destination);
      }
    }

    // Log khi đăng ký listener
    for (var reg in _listeners) {
      _logger.i('Registered listener for ${reg.events}');
      reg.listener.onStompConnect();
    }
  }

  void send(StompListenType type, dynamic body) {
    final destination = _getSendDestination(type);
    _logger.w('$destination          $body');
    if (destination != null) {
      _client?.send(destination: destination, body: body);
    }
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  void registerListener({
    required StompListenType type,
    required StompListener listener,
    String? chatBoxId,
  }) {
    // Kiểm tra nếu là kiểu chatBox nhưng không cung cấp chatBoxId
    if (type == StompListenType.chatBox && chatBoxId == null) {
      _logger.e("❌ Không thể đăng ký kênh chatBox mà không có chatBoxId");
      return;
    }

    final existingIndex =
        _listeners.indexWhere((e) => e.listener == listener && e.listener.runtimeType == listener.runtimeType);

    if (existingIndex != -1) {
      final existing = _listeners[existingIndex];
      if (!existing.events.contains(type)) {
        existing.events.add(type);
      }
    } else {
      _listeners.add(RegisterStomp(listener: listener, events: [type]));
    }

    // Rest of the method remains the same
    final destination = _getDestination(type, chatBoxId: chatBoxId);
    if (_client?.connected == true && destination != null && !_subscribedDestinations.contains(destination)) {
      final unsubscribe = _client!.subscribe(
        destination: destination,
        callback: (frame) {
          for (var reg in _listeners) {
            if (reg.events.contains(type)) {
              _handleIncoming(type, reg.listener, frame.body);
            }
          }
        },
      );

      _unsubscribeMap[destination] = unsubscribe;
      _subscribedDestinations.add(destination);

      _logger.i("Subscribed to $destination for $type");
    } else if (_subscribedDestinations.contains(destination)) {
      _logger.i("ℹAlready subscribed to $destination");
    } else {
      _logger.w("STOMP not connected or destination is null when registering for $type");
    }
    for (var element in _listeners) {
      _logger.e(element.toString());
      for (var element2 in element.events) {
        _logger.w(_getDestination(element2));
      }
    }
  }

  void unregisterListener({
    required StompListenType type,
    required StompListener listener,
    String? chatBoxId,
  }) {
    // Kiểm tra nếu là kiểu chatBox nhưng không cung cấp chatBoxId
    if (type == StompListenType.chatBox && chatBoxId == null) {
      _logger.e("❌ Không thể hủy đăng ký kênh chatBox mà không có chatBoxId");
      return;
    }

    final index = _listeners.indexWhere((e) => e.listener == listener);
    if (index == -1) return;

    final reg = _listeners[index];
    reg.events.remove(type);

    if (reg.events.isEmpty) {
      _listeners.removeAt(index);
    }

    // Không hủy đăng ký khi còn listener khác đang nghe kênh đó
    final destination = _getDestination(type, chatBoxId: chatBoxId);
    final stillHasListener = _listeners.any((e) => e.events.contains(type));
    if (!stillHasListener && destination != null && _unsubscribeMap.containsKey(destination)) {
      _unsubscribeMap[destination]!();
      _unsubscribeMap.remove(destination);
      _subscribedDestinations.remove(destination);
    }
    for (var element in _listeners) {
      _logger.e(element.toString());
      for (var element2 in element.events) {
        _logger.w(_getDestination(element2));
      }
    }
  }

  void _handleIncoming(StompListenType type, StompListener listener, String? body) {
    switch (type) {
      case StompListenType.comment:
        listener.onStompCommentReceived(body);
        break;
      case StompListenType.editComment:
        listener.onStompCommentReceived(body);
        break;
      case StompListenType.reply:
        listener.onStompReplyReceived(body);
        break;
      case StompListenType.editReply:
        listener.onStompReplyReceived(body);
        break;
      case StompListenType.chatBox:
        listener.onStompChatReceived(body);
        break;
      case StompListenType.notification:
        listener.onStompNotificationReceived(body);
        break;
      case StompListenType.chatBoxCreate:
        listener.onStompChatBoxCreateReceived(body);
        break;
    }
  }

  String? _getDestination(StompListenType type, {String? chatBoxId}) {
    String? userName;
    if (AppPrefs.getUser<StudentModel>(StudentModel.fromJson) != null) {
      StudentModel? studentModel = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
      userName = studentModel?.email;
    } else if (AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson) != null) {
      TeacherModel? teacherModel = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
      userName = teacherModel?.email;
    }
    switch (type) {
      case StompListenType.comment:
        return "/topic/comments";
      case StompListenType.editComment:
        return "/topic/comments";
      case StompListenType.reply:
        return "/topic/comment-replies";
      case StompListenType.editReply:
        return "/topic/comment-replies";
      case StompListenType.chatBox:
        return chatBoxId != null ? "/topic/chatbox/$chatBoxId" : null;
      case StompListenType.notification:
        return "/topic/notifications/$userName";
      case StompListenType.chatBoxCreate:
        return "/topic/chatbox/${userName}/created";
    }
  }

  String? _getSendDestination(StompListenType type) {
    switch (type) {
      case StompListenType.comment:
        return "/app/comment";
      case StompListenType.editComment:
        return "/app/comment/update";
      case StompListenType.reply:
        return "/app/comment-reply";
      case StompListenType.editReply:
        return "/app/comment-reply/update";
      case StompListenType.chatBox:
        return "/app/chat/sendMessage";
      case StompListenType.notification:
        return "";
      case StompListenType.chatBoxCreate:
        return "/app/chat/create";
    }
  }

  void _onDisconnect(StompFrame frame) {
    _logger.w("🔌 STOMP Disconnected");
    for (var reg in _listeners) {
      reg.listener.onStompDisconnect();
    }
  }

  void _onError(dynamic error) async {
    _logger.e("❌ WebSocket Error: $error");

    // Kiểm tra xem lỗi là do 401 (Unauthorized)
    if (error.toString().contains("401")) {
      _logger.w("🔄 Thử refresh token do lỗi 401 WebSocket");

      final result = await StudentRepository().myInfo();
      if (result.isSuccess) {
        _logger.i("✅ Refresh token thành công, reconnect STOMP");
        // reconnect();
      } else {
        _logger.e("❌ Không thể refresh token. Đăng xuất.");
        forceLogout();
      }
    }
  }

  void reconnect() {
    _client?.deactivate();
    _client = null;
    connect();
  }

  void forceLogout() {
    AppPrefs.accessToken = null;
    AppPrefs.refreshToken = null;

    Get.offAllNamed(Routers.login, arguments: {'errMessage': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!'});
  }

  static Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_instance == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_instance!._client == null || !_instance!._client!.connected) {
          _instance!.connect();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      default:
        break;
    }
  }
}
