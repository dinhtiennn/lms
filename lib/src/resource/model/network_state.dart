import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../configs/configs.dart';

class NetworkState<T> {
  int? status;
  String? message;
  T? result;
  bool? successCode;

  NetworkState({this.message, this.result, this.status, this.successCode});


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.result;
    data['code'] = this.successCode;
    return data;
  }

  NetworkState.withError(error) {
    message = "Đã xảy ra lỗi không xác định!";
    int errorCode = AppEndpoint.errorSever;
    Response? response;

    if (error is DioException) {
      response = error.response;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = "Kết nối đến máy chủ bị hết thời gian!";
          break;
        case DioExceptionType.badResponse:
          if (response != null) {
            errorCode = response.statusCode ?? AppEndpoint.errorSever;
            final data = response.data;
            try {
              if (data is Map) {
                message = data["message"] ?? "Lỗi không xác định từ máy chủ!";
              } else if (data is String) {
                message = data;
              } else {
                message = "Lỗi không xác định từ máy chủ!";
              }
            } catch (e) {
              message = "Lỗi từ máy chủ: $e";
            }
          } else {
            message = "Lỗi từ máy chủ (không có phản hồi)!";
          }
          break;
        case DioExceptionType.cancel:
          message = "Yêu cầu đã bị huỷ!";
          break;
        case DioExceptionType.connectionError:
          message = "Không thể kết nối đến máy chủ!";
          break;
        case DioExceptionType.unknown:
        default:
          message = "Lỗi không xác định!";
          break;
      }
    } else {
      message = "Không thể kết nối đến máy chủ!";
    }

    this.message = message;
    this.status = errorCode;
    this.successCode = false;
  }

  NetworkState.withDisconnect() {
    message = "Mất kết nối internet, vui lòng kiểm tra wifi/3g và thử lại!";
    status = AppEndpoint.errorDisconnect;
    result = null;
    successCode = false;
    toast(message!);
  }

  NetworkState.withErrorConvert(error) {
    result = null;
    message = "Lỗi chuyển đổi dữ liệu";
    status = AppEndpoint.errorSever;
    successCode = false;
    Logger().e("Data conversion error: $error");
  }

  bool get isSuccess => status == AppEndpoint.success;

  bool get isError => status != AppEndpoint.success;

  @override
  String toString() {
    return 'NetworkState{status: $status, message: $message, data: $result, successCode: $successCode}';
  }
}