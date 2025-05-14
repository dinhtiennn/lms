import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../configs/configs.dart';
import '../../utils/utils.dart';
import '../resource.dart';

class OtherRepository {
  OtherRepository._();

  static OtherRepository? _instance;

  factory OtherRepository() {
    _instance ??= OtherRepository._();
    return _instance!;
  }

  Future<NetworkState<VerifyModel>> getDefault() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      debugPrint("No internet connection.");
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().get('AppEndpoint.DEFAULT');
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: response.data['data'],
        message: response.data['message'],
      );
    } on DioException catch (dioError) {
      debugPrint("Error DIO: ${dioError.message}");
      return NetworkState.withError(dioError);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return NetworkState.withErrorConvert("An unexpected error occurred.");
    }
  }
}
