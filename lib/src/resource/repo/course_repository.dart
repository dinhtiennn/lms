import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_clients.dart';
import 'package:lms/src/utils/app_utils.dart';

class CourseRepository {
  CourseRepository._();

  static CourseRepository? _instance;

  factory CourseRepository() {
    _instance ??= CourseRepository._();
    return _instance!;
  }

  Future<NetworkState<CourseModel>> addCourse({
    String? name,
    String? description,
    required String status,
    String? learningDurationType,
    String? feeType,
    String? price,
    String? startDate,
    String? endDate,
    String? majorId,
  }) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(AppEndpoint.CREATECOURSE, data: {
        'name': name,
        'description': description,
        'status': status,
        'learningDurationType': learningDurationType,
        'startDate': startDate,
        'endDate': endDate,
        'majorId': majorId,
        'feeType': feeType,
        'price': (price != null && price.isNotEmpty) ? double.parse(price) : null,
      });
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<CourseModel>> updateCourse(
      {String? courseId,
      String? name,
      String? description,
      required String status,
      String? learningDurationType,
      String? startDate,
      String? endDate,
      String? majorId,
      String? feeType,
      String? price}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().put(AppEndpoint.UPDATECOURSE, data: {
        'idCourse': courseId,
        'name': name,
        'description': description,
        'status': status,
        'learningDurationType': learningDurationType,
        'startDate': startDate,
        'endDate': endDate,
        'majorId': majorId,
        'feeType': feeType,
        'price': (price != null && price.isNotEmpty) ? double.parse(price) : null,
      });
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<CourseModel>>> myCourses({int pageNumber = 0, int pageSize = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients()
          .get(AppEndpoint.MYCOURSE, queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> uploadImage({String? id, XFile? image}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    final file = await MultipartFile.fromFile(
      image?.path ?? '',
    );

    FormData formData = FormData.fromMap({
      'file': file,
    });

    // Lưu thông tin tệp vào requestOptions.extra
    final options = Options(extra: {
      'fileMeta': [
        {
          'path': image?.path,
          'field': 'file',
        }
      ]
    });

    try {
      Response response = await AppClients().post(
        AppEndpoint.UPLOADIMAGE.replaceAll('{id}', id ?? ''),
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

  Future<NetworkState<List<CourseModel>>> getCoursesByTeacher({int pageNumber = 0, int pageSize = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients()
          .get(AppEndpoint.MYCOURSESBYTEACHER, queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<CourseModel>>> publicCourses({int pageNumber = 0, int pageSize = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients()
          .get(AppEndpoint.PUBLICCOURSE, queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<CourseModel>>> searchCourses(
      {required String keyword, String? teacher, int pageNumber = 0, int pageSize = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.SEARCHCOURSE,
          queryParameters: {'courseName': keyword, 'teacher': teacher, 'pageNumber': pageNumber, 'pageSize': pageSize});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<CourseModel>>> courseOfMajorFirst({int pageNumber = 0, int pageSize = 20}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients()
          .get(AppEndpoint.COURSEOFMAJORFIRST, queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<CourseDetailModel>> getCourseDetail({String? courseId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        '${AppEndpoint.COURSEDETAIL.replaceAll('{id}', '')}$courseId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CourseDetailModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> getProgressLesson({String? lessonId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        '${AppEndpoint.PROGRESSLESSON.replaceAll('{id}', '')}/$lessonId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> getProgressChapter({String? chapterId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        '${AppEndpoint.PROGRESSCHAPTER.replaceAll('{id}', '')}/$chapterId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> setChapterProgress({String? chapterId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        '${AppEndpoint.SAVEPROGRESSCHAPTER.replaceAll('{id}', '')}/$chapterId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> setLessonProgress({String? lessonId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        '${AppEndpoint.SAVEPROGRESSLESSON.replaceAll('{id}', '')}/$lessonId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> setCompleteChapterProgress({String? chapterId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().put(
        '${AppEndpoint.COMPELTEPROGRESSCHAPTER.replaceAll('{id}', '')}/$chapterId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ProgressModel>> setCompleteLessonProgress({String? lessonId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().put(
        '${AppEndpoint.COMPELTEPROGRESSLESSON.replaceAll('{id}', '')}/$lessonId',
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ProgressModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<bool>> joinCourse({String? idCourse}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(AppEndpoint.JOINCOURSE,
          data: FormData.fromMap({
            'courseId': idCourse,
          }));
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

  Future<NetworkState<List<RequestToCourseModel>>> getAllRequestToCourseByStudent(
      {String? studentId, int pageSize = 20, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.LISTREQUEST,
          data: FormData.fromMap({'studentId': studentId, 'pageSize': pageSize, 'pageNumber': pageNumber}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: RequestToCourseModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<RequestModel>>> getAllRequestToCourse(
      {String? courseId, int pageSize = 20, int pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(AppEndpoint.LISTREQUESTTOCOURSE,
          data: FormData.fromMap({'courseId': courseId, 'pageSize': pageSize, 'pageNumber': pageNumber}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: RequestModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<LessonModel>> addLesson({String? description, String? courseId, int? order}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients()
          .post(AppEndpoint.CREATELESSON, data: {'description': description, 'courseId': courseId, 'order': order});
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: LessonModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<LessonMaterialModel>> addMaterial({String? id, XFile? file, String? type}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    final getFile = await MultipartFile.fromFile(
      file?.path ?? '',
    );

    try {
      Response response = await AppClients()
          .post(AppEndpoint.ADDMATERIAL, data: FormData.fromMap({'id': id, 'file': getFile, 'type': type}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: LessonMaterialModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<ChapterModel>> addMChapter(
      {String? lessonId, String? name, int? order, XFile? file, String? type}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    final getFile = await MultipartFile.fromFile(
      file?.path ?? '',
    );

    try {
      Response response = await AppClients().post(AppEndpoint.ADDCHAPTER,
          data: FormData.fromMap({'lessonId': lessonId, 'name': name, 'order': order, 'file': getFile, 'type': type}));
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ChapterModel.fromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<LessonQuizModel>>> addQuiz({String? lessonId, required List<LessonQuizModel> quizs}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.CREATEQUIZ.replaceAll('{id}', lessonId ?? ''),
        data: quizs.map((e) => e.toJson()).toList(),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: LessonQuizModel.listFromJson(response.data['result']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<StudentModel>>> getAllStudentOfCourse(
      {String? courseId, int pageNumber = 0, pageSize = 10}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.STUDENTSOFCOURSE,
        data: FormData.fromMap({'courseId': courseId, 'pageNumber': pageNumber, 'pageSize': pageSize}),
      );
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

  Future<NetworkState> removeStudent({String? courseId, String? studentId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().delete(
        AppEndpoint.DELETESTUDENTOFCOURSE,
        data: FormData.fromMap({'courseId': courseId, 'studentId': studentId}),
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

  Future<NetworkState> addStudents({required String courseId, required List<StudentModel> students}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.ADDSTUDENT,
        data: {
          'courseId': courseId,
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

  Future<NetworkState> approvedRequest({String? courseId, String? studentId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.APPROVEDREQUEST,
        data: FormData.fromMap({'courseId': courseId, 'studentId': studentId}),
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

  Future<NetworkState> rejectedRequest({String? courseId, String? studentId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().post(
        AppEndpoint.REJECTEDREQUEST,
        data: FormData.fromMap({'courseId': courseId, 'studentId': studentId}),
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

  Future<NetworkState<String>> getStatusJoin({String? courseId}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.STATUSJOIN,
        data: FormData.fromMap({'courseId': courseId}),
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

  Future<NetworkState> removeCourse(String? id) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().delete(
        AppEndpoint.REMOVECOURSE,
        data: FormData.fromMap({'courseId': id}),
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

  Future<NetworkState> payCourse({
    required String courseId,
    required double price,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      Map<String, dynamic> data = {
        "price": price,
        "currency": "USD",
        "method": "paypal",
        "intent": "sale",
        "description": "Payment for course",
        "courseId": courseId,
      };

      // Thêm URL callback nếu được cung cấp
      if (successUrl != null) {
        data["successUrl"] = successUrl;
      }

      if (cancelUrl != null) {
        data["cancelUrl"] = cancelUrl;
      }

      var response = await AppClients().post(
        AppEndpoint.PAYMENT,
        data: data,
      );

      if (response.statusCode == 200) {
        return NetworkState(
          status: AppEndpoint.success,
          result: true,
          message: response.data['message'],
          successCode: true,
        );
      }

      return NetworkState(
        status: response.statusCode,
        message: "Lỗi thanh toán",
        successCode: false,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState> paymentSuccess({String? paymentId, String? payerID}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.PAYMENTSUCCESS,
        queryParameters: {'paymentId': paymentId, 'PayerID': payerID},
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

  Future<NetworkState> paymentCancel() async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.PAYMENTCANCEL,
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
