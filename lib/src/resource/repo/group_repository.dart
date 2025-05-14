import 'dart:io';

import 'package:cross_file/src/types/interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../configs/configs.dart';
import '../../utils/utils.dart';
import '../resource.dart';

class GroupRepository {
  GroupRepository._();

  static GroupRepository? _instance;

  factory GroupRepository() {
    _instance ??= GroupRepository._();
    return _instance!;
  }

  Future<NetworkState<List<GroupModel>>> getAllGroupByTeacher({int pageSize = 20, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients()
          .get(AppEndpoint.GROUPOFTEACHER, queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: GroupModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<GroupModel>>> getAllGroupByStudent({int pageSize = 20, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients()
          .get(AppEndpoint.GROUPSOFSTUDENT, queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: GroupModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<GroupModel>> create({required String name, required String description}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response =
          await AppClients().post(AppEndpoint.CREATEGROUP, data: {'name': name, 'description': description});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: GroupModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<GroupModel>> update({String? groupId, required String name, required String description}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients()
          .put(AppEndpoint.UPDATEGROUP, data: {'groupId': groupId, 'name': name, 'description': description});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: GroupModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<PostModel>> createPost({
    String? groupId,
    String? title,
    required String text,
    required List<File> filesPicker,
  }) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      final Map<String, dynamic> formMap = {
        'groupId': groupId,
        'title': title,
        'text': text,
      };

      for (int i = 0; i < filesPicker.length; i++) {
        final file = filesPicker[i];
        formMap['fileUploadRequests[$i].file'] = await MultipartFile.fromFile(
          file.path,
        );
        formMap['fileUploadRequests[$i].type'] = AppUtils.getFileType(file);
      }

      final formData = FormData.fromMap(formMap);

      final response = await AppClients().post(
        AppEndpoint.CREATEPOST,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: PostModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<PostModel>>> getPosts({String? groupId, int pageSize = 0, int pageNumber = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().get(AppEndpoint.POSTS,
          queryParameters: {'groupId': groupId, 'pageSize': pageSize, 'pageNumber': pageNumber});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: PostModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<TestModel>>> getTests({String? groupId, int pageSize = 0, int pageNumber = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().get(AppEndpoint.TESTS,
          data: FormData.fromMap({'groupId': groupId, 'pageSize': pageSize, 'pageNumber': pageNumber}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: TestModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState<List<StudentModel>>> getStudents({String? groupId, int pageSize = 0, int pageNumber = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().get(AppEndpoint.STUDENTSINGROUP,
          data: FormData.fromMap({'groupId': groupId, 'pageSize': pageSize, 'pageNumber': pageNumber}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        successCode: response.data['code'] == 0,
        result: StudentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
      );
    } catch (e) {
      return NetworkState.withErrorConvert(e);
    }
  }

  Future<NetworkState> deletePost(String postId) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().delete(AppEndpoint.DELETEPOST, data: FormData.fromMap({'postId': postId}));
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

  Future<NetworkState> createTestRequest(
      {String? groupId,
      required String title,
      required String description,
      required DateTime expiredAt,
      required List<TestQuestionRequestModel> questions,
      required DateTime startedAt}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) {
      return NetworkState.withDisconnect();
    }

    try {
      Response response = await AppClients().post(AppEndpoint.CREATETEST, data: {
        'groupId': groupId,
        'title': title,
        'description': description,
        'startedAt': AppUtils.toOffsetDateTimeString(startedAt),
        'expiredAt': AppUtils.toOffsetDateTimeString(expiredAt),
        'listQuestionRequest': questions.map((e) => e.toJson()).toList(),
      });
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

  Future<NetworkState<TestDetailModel>> testDetail({String? testId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.TESTDETAIL,
        data: FormData.fromMap({'testId': testId}),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: TestDetailModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<TestResultView>>> testResultView({String? testId, int? pageSize = 30, int? pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    // try {
      Response response = await AppClients().get(
        AppEndpoint.ALLTESTRESULT,
        data: FormData.fromMap({'testId': testId, 'pageSize': pageSize, 'pageNumber': pageNumber}),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: TestResultView.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    // } catch (e) {
    //   return NetworkState.withError(e);
    // }
  }

  Future<NetworkState<TestResultModel>> testStudentDetail({String? testId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.TESTSTUDENTDETAIL,
        data: FormData.fromMap({'testId': testId}),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: TestResultModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<TestResultModel>> testStudentDetailByTeacher({String? testId, String? studentId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.TESTRESULTDETAIL,
        data: FormData.fromMap({'testId': testId, 'studentId': studentId}),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: TestResultModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> startTest({String? testId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.STARTTEST,
        data: FormData.fromMap({'testId': testId}),
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

  Future<NetworkState> addStudents({required String groupId, required List<StudentModel> students}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.ADDSTUDENTTOGROUP,
        data: {
          'groupId': groupId,
          'studentIds': students
              .map(
                (e) => e.id,
              )
              .toList()
        },
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

  Future<NetworkState> removeStudent({String? groupId, String? studentId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().delete(
        AppEndpoint.DELETESTUDENTOFGROUP,
        data: FormData.fromMap({'groupId': groupId, 'studentId': studentId}),
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

  Future<NetworkState> submitTest({String? testId, List<AnswerModel>? answers}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();
    try {
      Response response = await AppClients().post(
        AppEndpoint.SUBMITTEST,
        data: {'testId': testId, 'answerRequests': answers?.map((e) => e.toJson()).toList()},
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
