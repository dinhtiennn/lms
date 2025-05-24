import 'package:dio/dio.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';

class AuthRepository {
  AuthRepository._();

  static AuthRepository? _instance;

  factory AuthRepository() {
    _instance ??= AuthRepository._();
    return _instance!;
  }

  Future<NetworkState<String>> getToken({
    required String username,
    required String password,
    required String role,
  }) async {
    final isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      final response = await AppClients().post(
        AppEndpoint.TOKEN,
        data: {
          'username': username,
          'password': password,
          'rolerequest': role,
        },
        options: Options(
          extra: {'noAuth': true},
        ),
      );

      final data = response.data;
      final token = data['result']?['token'] ?? '';

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: data['code'] == 0,
        result: token,
        message: data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  // Future<NetworkState<StudentModel>> loginGoogle() async {
  //   SocialService service = SocialService();
  //   LoginSocialResult loginSocialResult = await service.signInGoogle();
  //   bool isDisconnect = await WifiService.isDisconnect();
  //   if (isDisconnect) return NetworkState.withDisconnect();
  //
  //   Response response = await AppClients()
  //       .post('AppEndpoint.LOGINGOOGLE', data: FormData.fromMap({'access_token': loginSocialResult.accessToken}));
  //   return NetworkState(
  //       status: response.statusCode ?? AppEndpoint.success,
  //       successCode: response.data['code'] == 0,
  //       result: StudentModel.fromJson(response.data['result']['student']),
  //       message: response.data['message']);
  // }

  Future<NetworkState> sendEmail({required String email}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients()
          .post(AppEndpoint.SEND, data: FormData.fromMap({'email': email}), options: Options(extra: {'noAuth': true}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 200,
        result: response.data['result'],
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> verifyOtp({required String email, required String otp}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(AppEndpoint.VERIFYCODE,
          data: FormData.fromMap({
            'email': email,
            'code': otp,
          }),
          options: Options(extra: {'noAuth': true}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: response.data['result'],
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<StudentModel>> registerStudent(
      {required String fullname, required String majorId, required String username, required String password}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(AppEndpoint.REGISTER,
          data: {
            'email': username,
            'password': password,
            'fullName': fullname,
            'majorId': majorId,
          },
          options: Options(extra: {'noAuth': true}));
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

  Future<NetworkState<StudentModel>> registerTeacher(
      {required String fullname, required String username, required String password}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(AppEndpoint.REGISTERTEACHER,
          data: {
            'email': username,
            'password': password,
            'fullName': fullname,
          },
          options: Options(extra: {'noAuth': true}));
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

  Future<NetworkState> logout() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients()
          .post(AppEndpoint.LOGOUT, data: {'token': AppPrefs.accessToken}, options: Options(extra: {'noAuth': true}));
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

  Future<NetworkState> changePass({required String email}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(AppEndpoint.REFRESHPASSWORD,
          data: FormData.fromMap({'email': email}), options: Options(extra: {'noAuth': true}));
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

  Future<NetworkState<NotificationView>> getNotifications({pageSize = 10, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients()
          .get(AppEndpoint.NOTIFICATION, data: FormData.fromMap({'pageSize': pageSize, 'pageNumber': pageNumber}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: NotificationView.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> markAsRead({String? notificationId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(
        AppEndpoint.READNOTIFICATION,
        data: [
          {'id': notificationId}
        ],
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> readAllNotification() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(
        AppEndpoint.READALLNOTIFICATION,
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<AccountModel>>> searchUser(
      {required String keyword, String? chatBoxId, int pageSize = 50, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().get(AppEndpoint.SEARCHUSER, queryParameters: {
        'chatBoxId': chatBoxId,
        'searchString': keyword,
        'pageSize': pageSize,
        'pageNumber': pageNumber
      });
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: AccountModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<ChatBoxModel>>> searchChatBox(
      {required String keyword, int pageSize = 50, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().get(AppEndpoint.SEARCHCHATBOX,
          queryParameters: {'name': keyword, 'pageSize': pageSize, 'pageNumber': pageNumber});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ChatBoxModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }
}
