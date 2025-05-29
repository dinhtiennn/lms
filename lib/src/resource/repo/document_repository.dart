import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../configs/configs.dart';
import '../../utils/utils.dart';
import '../resource.dart';

class DocumentRepository {
  DocumentRepository._();

  static DocumentRepository? _instance;

  factory DocumentRepository() {
    _instance ??= DocumentRepository._();
    return _instance!;
  }

  Future<NetworkState> createDocument(
      {required String title, required String description, required String status, required String majorId, required String type,
        File? filePicker}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      MultipartFile getFile = await MultipartFile.fromFile(
        filePicker?.path ?? '',
      );

      final Map<String, dynamic> formMap = {
        'title': title,
        'description': description,
        'status': status,
        'majorId': majorId,
        'type': type,
        'file': getFile
      };

      FormData formData = FormData.fromMap(formMap);

      final response = await AppClients().post(
        AppEndpoint.CREATEDOCUMENT,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: response.data['result'],
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<DocumentModel>>> myDocument({String? keyword,required int pageSize, required pageNumber}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().get(
         queryParameters: {
           'keyword' : keyword,
           'pageSize': pageSize,
           'pageNumber' : pageNumber
         },
        AppEndpoint.MYDOCUMENT,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: DocumentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<DocumentModel>>> search({String? keyword,required int pageSize, required pageNumber, required String majorId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().get(
         queryParameters: {
           'title' : keyword,
           // 'majorId' : majorId,
           'pageSize': pageSize,
           'pageNumber' : pageNumber
         },
        AppEndpoint.SEARCHDOCUMENT,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: DocumentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<DocumentModel>>> publicDocument({required int pageSize, required pageNumber}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().get(
         queryParameters: {
           'pageSize': pageSize,
           'pageNumber' : pageNumber
         },
        AppEndpoint.PUBLICDOCUMENT,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: DocumentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState> updateDocumentStatus(String? id, String newStatus) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().put(
       data: FormData.fromMap({
        'documentId' : id,
         'status' : newStatus,
       }),
        AppEndpoint.UPDATEDOCUMENTSTATUS,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: response.data['result'],
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState> delete(String? id) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }
    try {
      final response = await AppClients().delete(
       data: FormData.fromMap({
        'documentId' : id,
       }),
        AppEndpoint.DELETEDOCUMENT,
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: response.data['result'],
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }
}