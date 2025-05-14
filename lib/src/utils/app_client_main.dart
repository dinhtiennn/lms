// import 'package:dio/dio.dart' as dio_package;
// import 'package:dio/io.dart';
// import 'package:get/get.dart';
// import 'package:lms/src/configs/configs.dart';
// import 'package:lms/src/presentation/presentation.dart';
// import 'package:lms/src/utils/app_prefs.dart';
// import 'package:logger/logger.dart';
//
// final logger = Logger();
//
// class AppClients extends dio_package.DioMixin implements dio_package.Dio {
//   static AppClients? _instance;
//
//   factory AppClients() => _instance ??= AppClients._internal();
//
//   AppClients._internal() {
//     options = dio_package.BaseOptions(
//       baseUrl: AppEndpoint.baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {'Content-Type': 'application/json'},
//     );
//
//     httpClientAdapter = IOHttpClientAdapter();
//
//     interceptors.add(
//       dio_package.InterceptorsWrapper(
//         onRequest: _requestInterceptor,
//         onResponse: _responseInterceptor,
//         onError: _errorInterceptor,
//       ),
//     );
//
//     interceptors.add(
//       dio_package.LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//         logPrint: (object) {
//           logger.d('📡 API: $object');
//         },
//       ),
//     );
//   }
//
//   void _requestInterceptor(
//       dio_package.RequestOptions options,
//       dio_package.RequestInterceptorHandler handler,
//       ) {
//     if (options.extra['noAuth'] == true) {
//       logger.i('📤 REQUEST [NO AUTH]: ${options.method} ${options.uri}');
//       return handler.next(options);
//     }
//
//     final accessToken = AppPrefs.accessToken;
//     if (accessToken != null) {
//       options.headers['Authorization'] = 'Bearer $accessToken';
//     }
//
//     logger.i('📤 REQUEST: ${options.method} ${options.uri}');
//     logger.d('📤 Headers: ${options.headers}');
//     if (options.data != null) {
//       logger.d('📤 Body: ${options.data}');
//     }
//     if (options.queryParameters.isNotEmpty) {
//       logger.d('📤 Query: ${options.queryParameters}');
//     }
//
//     handler.next(options);
//   }
//
//   void _responseInterceptor(
//       dio_package.Response response,
//       dio_package.ResponseInterceptorHandler handler,
//       ) {
//     logger.i('📥 RESPONSE [${response.statusCode}]: ${response.requestOptions.method} ${response.requestOptions.uri}');
//     logger.i('📥 Response headers: ${response.headers.map}');
//     logger.i('📥 Response data: ${response.data}');
//
//     final requestTime = response.requestOptions.extra['requestTime'];
//     if (requestTime != null) {
//       final now = DateTime.now();
//       final diff = now.difference(requestTime as DateTime);
//       logger.d('📥 Response time: ${diff.inMilliseconds}ms');
//     }
//
//     handler.next(response);
//   }
//
//   void _errorInterceptor(
//       dio_package.DioException dioError,
//       dio_package.ErrorInterceptorHandler handler,
//       ) async {
//     logger.e(
//         '❌ ERROR [${dioError.response?.statusCode ?? dioError.type}]: ${dioError.requestOptions.method} ${dioError.requestOptions.uri}');
//     logger.e('❌ Error message: ${dioError.message}');
//     if (dioError.response != null) {
//       logger.e('❌ Response data: ${dioError.response?.data}');
//       logger.e('❌ Response headers: ${dioError.response?.headers.map}');
//     }
//
//     if (dioError.response?.statusCode == 401 && !(dioError.requestOptions.extra['retry'] ?? false)) {
//       final refreshToken = AppPrefs.refreshToken;
//       if (refreshToken == null) {
//         logger.e("❌ Refresh token is null");
//         _handleAuthFailure();
//         return handler.reject(dioError);
//       }
//
//       try {
//         logger.i('🔄 Trying to refresh token...');
//
//         final refreshDio = dio_package.Dio(dio_package.BaseOptions(
//           baseUrl: AppEndpoint.baseUrl,
//           connectTimeout: const Duration(seconds: 10),
//           receiveTimeout: const Duration(seconds: 10),
//           headers: {'Content-Type': 'application/json'},
//         ));
//
//         refreshDio.interceptors.add(
//           dio_package.LogInterceptor(
//             requestBody: true,
//             responseBody: true,
//             logPrint: (object) {
//               logger.d('🔄 REFRESH TOKEN: $object');
//             },
//           ),
//         );
//
//         // Cấu trúc data đã sửa - cấu trúc JSON hợp lệ
//         final refreshResponse = await refreshDio.post(
//           AppEndpoint.REFRESH,
//           data: {
//             "token": refreshToken
//           },
//           options: dio_package.Options(
//             headers: {'Authorization': 'Bearer $refreshToken'},
//           ),
//         );
//
//         if (refreshResponse.statusCode != 200) {
//           logger.e("❌ Failed to refresh token. Status code: ${refreshResponse.statusCode}");
//           _handleAuthFailure();
//           return handler.reject(dioError);
//         }
//
//         final newAccessToken = refreshResponse.data['accessToken'];
//         if (newAccessToken == null) {
//           logger.e("❌ Access token not found in refresh response");
//           _handleAuthFailure();
//           return handler.reject(dioError);
//         }
//
//         AppPrefs.accessToken = newAccessToken;
//         logger.i('✅ Token refreshed successfully');
//         logger.d('✅ New Access Token: $newAccessToken');
//
//         final opts = dioError.requestOptions;
//         opts.headers['Authorization'] = 'Bearer $newAccessToken';
//         opts.extra['retry'] = true;
//
//         logger.i('🔄 Retrying original request with new token');
//         final cloneResponse = await fetch(opts);
//         return handler.resolve(cloneResponse);
//       } catch (e) {
//         logger.e("❌ Refresh token failed: $e");
//         _handleAuthFailure();
//         return handler.reject(dioError);
//       }
//     }
//
//     handler.next(dioError);
//   }
//
//   void _handleAuthFailure() {
//     logger.w('🔒 Authentication failed. Redirecting to login...');
//     AppPrefs.accessToken = null;
//     AppPrefs.refreshToken = null;
//     Get.offAll(Routers.login);
//   }
//
//   @override
//   Future<dio_package.Response<T>> request<T>(
//       String path, {
//         data,
//         Map<String, dynamic>? queryParameters,
//         dio_package.CancelToken? cancelToken,
//         dio_package.Options? options,
//         dio_package.ProgressCallback? onSendProgress,
//         dio_package.ProgressCallback? onReceiveProgress,
//       }) {
//     final requestOptions = options ?? dio_package.Options();
//     requestOptions.extra = {
//       ...requestOptions.extra ?? {},
//       'requestTime': DateTime.now(),
//     };
//
//     return super.request(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       cancelToken: cancelToken,
//       options: requestOptions,
//       onSendProgress: onSendProgress,
//       onReceiveProgress: onReceiveProgress,
//     );
//   }
// }