import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../configs/configs.dart';
import '../../utils/utils.dart';
import '../resource.dart';

class ChatBoxRepository {
  ChatBoxRepository._();

  static ChatBoxRepository? _instance;

  factory ChatBoxRepository() {
    _instance ??= ChatBoxRepository._();
    return _instance!;
  }

  Future<NetworkState<List<ChatBoxModel>>> chatBoxes({required int pageSize, required pageNumber}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().get(
        queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
        AppEndpoint.CHATBOXS,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: ChatBoxModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<MessageModel>>> messages(
      {required String id, int? pageSize = 10, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().get(
        queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
        AppEndpoint.MESSAGES.replaceAll('{id}', id),
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: MessageModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<ChatBoxModel>>> markAsRead({String? chatBoxId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().post(AppEndpoint.READMESSAGES.replaceAll('{id}', chatBoxId ?? ''));

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: ChatBoxModel.listFromJson(response.data['result']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }
}
