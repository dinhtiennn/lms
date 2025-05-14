import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' as getx;
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:logger/logger.dart';
import '../configs/configs.dart';
import 'app_prefs.dart';

class _RequestRetryInfo {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final DioException dioError;

  _RequestRetryInfo(this.options, this.handler, this.dioError);
}

class AppClients extends DioForNative {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";

  // Biến để quản lý các request đang chờ xử lý
  final _pendingRequests = <_RequestRetryInfo>[];
  bool _isRefreshing = false;
  static AppClients? _instance;
  static Logger logger = Logger();

  factory AppClients({String baseUrl = AppEndpoint.baseUrl, BaseOptions? options}) {
    _instance ??= AppClients._(baseUrl: baseUrl);
    if (options != null) _instance!.options = options;
    _instance!.options.baseUrl = baseUrl;
    return _instance!;
  }

  AppClients._({String baseUrl = AppEndpoint.baseUrl, BaseOptions? options}) : super(options) {
    interceptors.add(InterceptorsWrapper(
      onRequest: _requestInterceptor,
      onResponse: _responseInterceptor,
      onError: _errorInterceptor,
    ));

    this.options.baseUrl = baseUrl;

    // Thêm timeout mặc định cho tất cả các request
    this.options.connectTimeout = Duration(milliseconds: AppEndpoint.connectionTimeout);
    this.options.receiveTimeout = Duration(milliseconds: AppEndpoint.receiveTimeout);
    this.options.sendTimeout = Duration(milliseconds: AppEndpoint.connectionTimeout);
  }

  _requestInterceptor(RequestOptions options, RequestInterceptorHandler handler) async {
    final noAuth = options.extra['noAuth'] == true;
    logger.d("→ [Interceptor] Request: ${options.uri}");
    logger.d("→ [Interceptor] noAuth = $noAuth");
    logger.d("→ [Interceptor] extra = ${options.extra}");

    if (!noAuth) {
      final accessToken = AppPrefs.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    logger.d("${options.method}: ${options.uri}\nHeaders: ${options.headers}");

    switch (options.method) {
      case AppClients.GET:
        logger.d("Params: ${options.queryParameters}");
        break;
      default:
        if (options.data is Map) {
          logger.d("Params: ${options.data}");
        } else if (options.data is FormData) {
          logger.d("Params: ${(options.data as FormData).fields}");
          logger.d("Files: ${(options.data as FormData).files}");

          final oldData = options.data as FormData;
          final newData = FormData();

          for (var field in oldData.fields) {
            newData.fields.add(field);
          }
          for (var file in oldData.files) {
            newData.files.add(file);
          }

          options.data = newData;
        }
        break;
    }

    // Đảm bảo timeout được thiết lập cho mỗi request
    options.connectTimeout = Duration(milliseconds: AppEndpoint.connectionTimeout);
    options.receiveTimeout = Duration(milliseconds: AppEndpoint.receiveTimeout);
    options.sendTimeout = Duration(milliseconds: AppEndpoint.connectionTimeout);

    handler.next(options);
  }

  _responseInterceptor(Response response, ResponseInterceptorHandler handler) {
    logger.i("✅ Response ${response.requestOptions.uri}: ${response.statusCode}");
    logger.i("✅ Data: ${response.data}");
    handler.next(response);
  }

  _errorInterceptor(DioException dioError, ErrorInterceptorHandler handler) async {
    // Tạo NetworkState từ lỗi để có thông tin lỗi chuẩn
    final networkState = NetworkState.withError(dioError);
    logger.e("⛔ Error ${dioError.requestOptions.uri}: ${networkState.status} - ${networkState.message}");

    final noAuth = dioError.requestOptions.extra['noAuth'] == true;

    // Kiểm tra lỗi kết nối hoặc timeout
    if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.receiveTimeout ||
        dioError.type == DioExceptionType.sendTimeout) {
      logger.e("⛔ Timeout Error: ${networkState.message}");
      return handler.next(dioError);
    }

    if (noAuth) {
      logger.w("⚠️ Bỏ qua refresh token do noAuth = true");
      return handler.next(dioError);
    }

    // Xử lý lỗi 401 - Unauthorized
    if (dioError.response?.statusCode == 401) {
      logger.e("⛔ Lỗi 401: ${networkState.message}");

      final options = dioError.requestOptions;
      String? refreshToken = AppPrefs.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        logger.e("❌ Refresh token không có sẵn");
        forceLogout('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!');
        return handler.next(dioError);
      }

      // Lưu request hiện tại vào hàng đợi
      _pendingRequests.add(_RequestRetryInfo(options, handler, dioError));

      // Nếu đang refresh token, không gọi lại API refresh
      if (_isRefreshing) {
        logger.w("⏳ Đang refresh token, thêm request vào hàng đợi");
        return;
      }

      // Bắt đầu quá trình refresh token
      _isRefreshing = true;

      try {
        logger.i("🔄 Bắt đầu refresh token");
        final dio = Dio()
          ..options.connectTimeout = const Duration(seconds: 10)
          ..options.receiveTimeout = const Duration(seconds: 10)
          ..options.sendTimeout = const Duration(seconds: 10);

        final response = await dio.post(
          '${AppEndpoint.baseUrl}${AppEndpoint.REFRESH}',
          data: {'token': refreshToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        String? newToken;
        if (response.statusCode == 200 && response.data['result']?['token'] != null) {
          newToken = response.data['result']['token'];
          AppPrefs.accessToken = newToken;
          AppPrefs.refreshToken = newToken;
          logger.i("💡 🔁 Cập nhật token mới thành công: $newToken");
        } else {
          logger.e("❌ Phản hồi refresh token không hợp lệ: ${response.data}");
        }

        // Xử lý các request đang chờ
        _processQueuedRequests(newToken);
      } catch (e) {
        logger.e("❌ Exception khi refresh token: $e");
        _processQueuedRequests(null); // Xử lý hàng đợi với token = null
      } finally {
        _isRefreshing = false;
      }

      // Return void - handler đã được xử lý trong hàng đợi
      return;
    }

    // Xử lý các lỗi HTTP khác
    if (dioError.response != null) {
      final statusCode = dioError.response!.statusCode;

      switch (statusCode) {
        case 403:
          logger.e("⛔ Lỗi 403: Không có quyền truy cập - ${networkState.message}");
          break;
        case 404:
          logger.e("⛔ Lỗi 404: Không tìm thấy - ${networkState.message}");
          break;
        case 500:
        case 502:
        case 503:
          logger.e("⛔ Lỗi máy chủ $statusCode - ${networkState.message}");
          break;
      }
    }

    return handler.next(dioError);
  }

  void _processQueuedRequests(String? newToken) {
    logger.i("🔄 Xử lý ${_pendingRequests.length} request đang chờ");

    if (newToken == null) {
      // Refresh token thất bại, từ chối tất cả các request đang chờ
      logger.e("❌ Refresh token thất bại, từ chối tất cả request và logout");
      forceLogout('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!');

      // Xử lý tất cả các request trong hàng đợi
      for (var request in _pendingRequests) {
        request.handler.next(request.dioError);
      }

      _pendingRequests.clear();
      return;
    }

    // Xử lý từng request đang chờ trong hàng đợi
    final requests = List<_RequestRetryInfo>.from(_pendingRequests);
    _pendingRequests.clear();

    for (var request in requests) {
      _retryRequest(request, newToken);
    }
  }

  void _retryRequest(_RequestRetryInfo requestInfo, String token) async {
    final options = requestInfo.options;
    final handler = requestInfo.handler;

    try {
      var newData = options.data;
      if (options.data is FormData) {
        // Xử lý FormData
        final oldData = options.data as FormData;
        final newFormData = FormData();

        for (var field in oldData.fields) {
          newFormData.fields.add(field);
        }

        for (var file in oldData.files) {
          newFormData.files.add(file);
        }

        newData = newFormData;
      }

      final newOptions = Options(
        method: options.method,
        headers: {
          ...options.headers ?? {},
          'Authorization': 'Bearer $token',
        },
        contentType: options.contentType,
        responseType: options.responseType,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      logger.i("🔄 Thử lại request: ${options.path}");
      final newRequest = await request(
        options.path,
        data: newData,
        queryParameters: options.queryParameters,
        options: newOptions,
      );

      handler.resolve(newRequest);
    } catch (e) {
      logger.e("❌ Lỗi khi thử lại request: $e");

      // Nếu lỗi vẫn là 401, đăng xuất người dùng
      if (e is DioException && e.response?.statusCode == 401) {
        // Chỉ hiển thị thông báo, không gọi lại forceLogout vì đã có ở _processQueuedRequests
        logger.e("❌ Vẫn nhận lỗi 401 sau khi refresh token");
      }

      // Không thử lại nữa, trả về lỗi ban đầu
      handler.next(requestInfo.dioError);
    }
  }

  void forceLogout(String message) {
    AppPrefs.accessToken = null;
    AppPrefs.refreshToken = null;
    AppPrefs.setUser(null);

    getx.Get.offAllNamed(Routers.chooseRole, arguments: {'errMessage': message});
  }

  // Phương thức wrapper để xử lý lỗi một cách nhất quán
  Future<NetworkState<T>> requestWithErrorHandling<T>(
      String path, {
        String method = AppClients.GET,
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool noAuth = false,
      }) async {
    try {
      final opts = options ?? Options();
      opts.method = method;
      opts.extra = {'noAuth': noAuth, ...(opts.extra ?? {})};

      final response = await request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
      );

      // Chuyển đổi response thành NetworkState
      final networkState = NetworkState<T>();

      if (response.data is Map) {
        networkState.status = response.data['status'] ?? response.statusCode;
        networkState.message = response.data['message'] ?? "Thành công";
        networkState.result = response.data['result'] ?? response.data['data'];
        networkState.successCode = (response.data['code'] as int) == 0;
      } else {
        networkState.status = response.statusCode;
        networkState.message = "Thành công";
        networkState.result = response.data;
        networkState.successCode = true;
      }

      return networkState;
    } on DioException catch (e) {
      return NetworkState<T>.withError(e);
    } catch (e) {
      return NetworkState<T>.withErrorConvert(e);
    }
  }

  // Phương thức tiện ích cho các loại request chính
  Future<NetworkState<T>> getRequest<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool noAuth = false,
      }) {
    return requestWithErrorHandling<T>(
      path,
      method: GET,
      queryParameters: queryParameters,
      options: options,
      noAuth: noAuth,
    );
  }

  Future<NetworkState<T>> postRequest<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool noAuth = false,
      }) {
    return requestWithErrorHandling<T>(
      path,
      method: POST,
      data: data,
      queryParameters: queryParameters,
      options: options,
      noAuth: noAuth,
    );
  }

  Future<NetworkState<T>> putRequest<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool noAuth = false,
      }) {
    return requestWithErrorHandling<T>(
      path,
      method: PUT,
      data: data,
      queryParameters: queryParameters,
      options: options,
      noAuth: noAuth,
    );
  }

  Future<NetworkState<T>> deleteRequest<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool noAuth = false,
      }) {
    return requestWithErrorHandling<T>(
      path,
      method: DELETE,
      data: data,
      queryParameters: queryParameters,
      options: options,
      noAuth: noAuth,
    );
  }
}