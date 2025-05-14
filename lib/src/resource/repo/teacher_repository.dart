import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_clients.dart';

class TeacherRepository {
  TeacherRepository._();

  static TeacherRepository? _instance;

  factory TeacherRepository() {
    _instance ??= TeacherRepository._();
    return _instance!;
  }

  Future<NetworkState<TeacherModel>> myInfo() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients(baseUrl: AppEndpoint.baseUrl).get(
        AppEndpoint.PROFILETEACHER,
      );
      return NetworkState(
          status: response.statusCode ?? AppEndpoint.success,
          successCode: response.data['code'] == 0,
          result: TeacherModel.fromJson(response.data['result']),
          message: response.data['message']
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> updateAvatar({required String id, required XFile avatar}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    final file = await MultipartFile.fromFile(
      avatar.path,
    );

    FormData formData = FormData.fromMap({
      'file': file,
    });

    // Lưu thông tin tệp vào requestOptions.extra
    final options = Options(extra: {
      'fileMeta': [
        {
          'path': avatar.path,
          'field': 'file',
        }
      ]
    });

    try {
      Response response = await AppClients().post(
        AppEndpoint.UPDATEAVATARTEACHER.replaceAll('id', id),
        data: formData,
        options: options,
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: response.data['result'],
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }
}
