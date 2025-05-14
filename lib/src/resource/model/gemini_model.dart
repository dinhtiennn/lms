import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/src/resource/model/model.dart';

class GeminiRequestModel {
  final List<Map<String, dynamic>> contents;

  GeminiRequestModel({required this.contents});

  factory GeminiRequestModel.fromMessages(List<MessageModel> messages) {
    return GeminiRequestModel(
      contents: messages.map((message) {
        return {
          "parts": [
            {"text": message.content}
          ],
          "role": message.senderType == "model" ? "model" : "user"
        };
      }).toList(),
    );
  }

  // Chuyển đối tượng thành chuỗi JSON
  String toJson() {
    return jsonEncode({"contents": contents});
  }

  // Chuyển danh sách messages thành JSON ngay lập tức
  static String listRequestToJson(List<MessageModel> messages) {
    return GeminiRequestModel.fromMessages(messages).toJson();
  }
}

class GeminiResponseModel {
  final List<CandidateModel> candidates;
  final UsageMetadataModel usageMetadata;
  final String modelVersion;

  GeminiResponseModel({
    required this.candidates,
    required this.usageMetadata,
    required this.modelVersion,
  });

  factory GeminiResponseModel.fromJson(Map<String, dynamic> json) {
    return GeminiResponseModel(
      candidates: (json['candidates'] as List<dynamic>).map((e) => CandidateModel.fromJson(e)).toList(),
      usageMetadata: UsageMetadataModel.fromJson(json['usageMetadata']),
      modelVersion: json['modelVersion'] ?? "",
    );
  }
}

class CandidateModel {
  final ContentModel content;
  final String finishReason;
  final double? avgLogprobs;

  CandidateModel({
    required this.content,
    required this.finishReason,
    this.avgLogprobs,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      content: ContentModel.fromJson(json['content']),
      finishReason: json['finishReason'] ?? "",
      avgLogprobs: json['avgLogprobs']?.toDouble(),
    );
  }
}

class ContentModel {
  final List<Part> parts;
  final String role;

  ContentModel({
    required this.parts,
    required this.role,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      parts: (json['parts'] as List<dynamic>).map((e) => Part.fromJson(e)).toList(),
      role: json['role'] ?? "user",
    );
  }
}

class Part {
  final String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(text: json['text'] ?? "");
  }
}

class UsageMetadataModel {
  final int promptTokenCount;
  final int candidatesTokenCount;
  final int totalTokenCount;
  final List<TokenDetailModel> promptTokensDetails;
  final List<TokenDetailModel> candidatesTokensDetails;

  UsageMetadataModel({
    required this.promptTokenCount,
    required this.candidatesTokenCount,
    required this.totalTokenCount,
    required this.promptTokensDetails,
    required this.candidatesTokensDetails,
  });

  factory UsageMetadataModel.fromJson(Map<String, dynamic> json) {
    return UsageMetadataModel(
      promptTokenCount: json['promptTokenCount'] ?? 0,
      candidatesTokenCount: json['candidatesTokenCount'] ?? 0,
      totalTokenCount: json['totalTokenCount'] ?? 0,
      promptTokensDetails:
          (json['promptTokensDetails'] as List<dynamic>?)?.map((e) => TokenDetailModel.fromJson(e)).toList() ?? [],
      candidatesTokensDetails:
          (json['candidatesTokensDetails'] as List<dynamic>?)?.map((e) => TokenDetailModel.fromJson(e)).toList() ?? [],
    );
  }
}

class TokenDetailModel {
  final String modality;
  final int tokenCount;

  TokenDetailModel({required this.modality, required this.tokenCount});

  factory TokenDetailModel.fromJson(Map<String, dynamic> json) {
    return TokenDetailModel(
      modality: json['modality'] ?? "unknown",
      tokenCount: json['tokenCount'] ?? 0,
    );
  }
}
