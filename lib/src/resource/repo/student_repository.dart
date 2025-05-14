import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_clients.dart';

class StudentRepository {
  StudentRepository._();

  static StudentRepository? _instance;

  factory StudentRepository() {
    _instance ??= StudentRepository._();
    return _instance!;
  }

  Future<NetworkState<StudentModel>> myInfo() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.MYINFO,
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: StudentModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
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
        AppEndpoint.UPDATEAVATAR.replaceAll('id', id),
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

  Future<NetworkState> changerPassword({required String oldPass, required String newPass}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().put(AppEndpoint.CHANGERPASSWORD, data: {
        'oldPassword': oldPass,
        'newPassword': newPass,
      });
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<StudentModel>>> search(
      {required String keyword, required String type, int pageSize = 20, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.SEARCHSTUDENT,
          data: FormData.fromMap({
            'fullName': type.contains('fullName') ? keyword : null,
            'email': type.contains('email') ? keyword : null,
            'majorName': null,
            'pageSize': pageSize,
            'pageNumber': pageNumber,
          }));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: StudentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<StudentModel>>> searchStudentNotInCourse(
      {required String courseId, required String keyword, int pageSize = 20, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.SEARCHSTUDENTNOTIN,
          data: FormData.fromMap({
            'courseId': courseId,
            'keyword': keyword,
            'majorName': null,
            'pageSize': pageSize,
            'pageNumber': pageNumber,
          }));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: StudentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<StudentModel>>> searchStudentNotInGroup(
      {required String groupId, required String keyword, int pageSize = 20, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.STUDENTNOTINGROUP,
          data: FormData.fromMap({
            'groupId': groupId,
            'keyword': keyword,
            'pageSize': pageSize,
            'pageNumber': pageNumber,
          }));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: StudentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }
}
