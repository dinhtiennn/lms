import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../configs/configs.dart';
import '../../utils/utils.dart';
import '../resource.dart';

class MajorRepository {
  MajorRepository._();

  static MajorRepository? _instance;

  factory MajorRepository() {
    _instance ??= MajorRepository._();
    return _instance!;
  }

  Future<NetworkState<List<MajorModel>>> getAllMajor() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().get(AppEndpoint.MAJOR, options: Options(extra: {'noAuth': true}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: MajorModel.listFromJson(response.data['result']),
        message: response.data['message'] ?? '',
      );
    }catch (e) {
      return NetworkState.withErrorConvert("An unexpected error occurred.");
    }
  }
}
