import 'package:dio/dio.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_clients.dart';

class CommentRepository {
  CommentRepository._();

  static CommentRepository? _instance;

  factory CommentRepository() {
    _instance ??= CommentRepository._();
    return _instance!;
  }

  Future<NetworkState<List<CommentModel>>> commentInChapter(
      {required String chapterId, int pageSize = 20, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.COMMENTS,
        options: Options(
          headers: {
            'chapterId': chapterId,
            'pageNumber': pageNumber,
            'pageSize': pageSize,
          },
        ),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: CommentModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }

  Future<NetworkState<List<ReplyModel>>> getReplies(
      {required String commentId, int replyPageSize = 5, pageNumber = 0}) async {
    bool isDisconnect = await WifiService.isDisconnect();
    if (isDisconnect) return NetworkState.withDisconnect();

    try {
      Response response = await AppClients().get(
        AppEndpoint.REPLIES,
        options: Options(
          headers: {
            'commentId': commentId,
            'pageNumber': pageNumber,
            'pageSize': replyPageSize,
          },
        ),
      );
      return NetworkState(
        status: response.statusCode ?? AppEndpoint.success,
        result: ReplyModel.listFromJson(response.data['result']['content']),
        message: response.data['message'] ?? '',
        successCode: response.data['code'] == 0,
      );
    } catch (e) {
      return NetworkState.withError(e);
    }
  }
}
