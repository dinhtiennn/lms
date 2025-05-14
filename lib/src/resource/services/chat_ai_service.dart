import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lms/src/resource/model/model.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';

enum MessageRole { user, model }

class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  GeminiApiException(
      {required this.message, this.statusCode, this.responseBody});

  @override
  String toString() => 'GeminiApiException: $message (Status: $statusCode)';
}

class ChatAiService {
  static Logger logger = Logger();
  final _storage = GetStorage();
  final _connectivity = Connectivity();
  static const String _cacheKey = 'ai_chat_cache';
  static const int _maxTokens = 1000;
  static const Duration _rateLimit = Duration(seconds: 2);
  DateTime? _lastRequestTime;

  String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw GeminiApiException(
          message: 'API key không tồn tại. Vui lòng kiểm tra cấu hình.');
    }
    return key;
  }

  String get apiUrl =>
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  Future<String> chatWithGemini(List<MessageModel> messages) async {
    // Kiểm tra kết nối mạng
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw GeminiApiException(
          message: 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.');
    }

    // Kiểm tra rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _rateLimit) {
        await Future.delayed(_rateLimit - timeSinceLastRequest);
      }
    }

    if (messages.isEmpty) return "Không có tin nhắn nào được gửi.";

    // Giới hạn số lượng tin nhắn gửi đi
    final limitedMessages = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    // Chuyển danh sách tin nhắn thành JSON
    final payloadJson = GeminiRequestModel.listRequestToJson(
        limitedMessages..sort((a, b) => a.sentAt.compareTo(b.sentAt)));

    try {
      // Kiểm tra cache
      final cachedResponse = _getCachedResponse(payloadJson);
      if (cachedResponse != null) {
        return cachedResponse;
      }

      logger.d("uri: ${Uri.parse(apiUrl)}");
      logger.d("📥 json gửi đi: $payloadJson}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: payloadJson,
      );

      logger.d('📥 Phản hồi từ API: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw GeminiApiException(
            message: "Lỗi API",
            statusCode: response.statusCode,
            responseBody: response.body);
      }

      final data = jsonDecode(response.body);
      final geminiResponse = GeminiResponseModel.fromJson(data);

      if (geminiResponse.candidates.isEmpty) {
        throw GeminiApiException(
            message: "Không có phản hồi hợp lệ từ Gemini.");
      }

      final candidate = geminiResponse.candidates.first;
      final content = candidate.content;

      if (content.parts.isEmpty || content.parts.first.text.isEmpty) {
        return "Gemini không có phản hồi.";
      }

      final responseText = content.parts.first.text;

      // Cache response
      _cacheResponse(payloadJson, responseText);

      _lastRequestTime = DateTime.now();

      return responseText;
    } catch (e) {
      if (e is GeminiApiException) rethrow;
      throw GeminiApiException(message: "Lỗi kết nối: $e");
    }
  }

  String? _getCachedResponse(String payload) {
    final cache = _storage.read<Map<String, dynamic>>(_cacheKey) ?? {};
    return cache[payload];
  }

  void _cacheResponse(String payload, String response) {
    final cache = _storage.read<Map<String, dynamic>>(_cacheKey) ?? {};
    cache[payload] = response;
    _storage.write(_cacheKey, cache);
  }

  void createChatWithAI(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatboxes')
        .doc("chat_with_ai")
        .set({
      'chatType': 'ai',
      'participants': [userId, 'model'],
    });
  }

//todo chức năng chat với user thì tạo chat_service riêng rôi ném vào.
// void createChatWithUser(String userId, String otherUserId) {
//   String chatId = userId.hashCode <= otherUserId.hashCode
//       ? "$userId-$otherUserId"
//       : "$otherUserId-$userId";
//
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('chatboxes')
//       .doc(chatId)
//       .set({
//     'chatType': 'user',
//     'participants': [userId, otherUserId],
//   });
//
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(otherUserId)
//       .collection('chatboxes')
//       .doc(chatId)
//       .set({
//     'chatType': 'user',
//     'participants': [userId, otherUserId],
//   });
// }
}
