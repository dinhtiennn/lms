import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class CourseCommentViewModel extends BaseViewModel with StompListener {
  late StompService stompService;
  StudentModel? student;
  TextEditingController commentController = TextEditingController();
  ValueNotifier<List<CommentModel>?> comments = ValueNotifier(null);
  ValueNotifier<CommentModel?> commentSelected = ValueNotifier(null);
  ValueNotifier<bool> canSend = ValueNotifier(false);
  ValueNotifier<String?> animatedCommentId = ValueNotifier(null);
  ValueNotifier<String?> animatedReplyId = ValueNotifier(null);
  ValueNotifier<ChapterModel?> chapterCurrent = ValueNotifier(null);
  ValueNotifier<CourseDetailModel?> courseDetailCurrent = ValueNotifier(null);

  // Thêm ScrollController cho comments
  final ScrollController commentsScrollController = ScrollController();

  bool hasMoreComments = true;
  bool isLoadingComments = false;
  int commentPageSize = 10;

  init() async {
    chapterCurrent.value = Get.arguments['chapter'];
    courseDetailCurrent.value = Get.arguments['courseDetail'];
    student = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    // Thiết lập kết nối socket
    commentsScrollController.addListener(_scrollListener);
    await setupSocket();
    // Khởi tạo lại các ValueNotifier nếu cần
    if (!animatedCommentId.hasListeners) {
      animatedCommentId = ValueNotifier(null);
    }
    if (!animatedReplyId.hasListeners) {
      animatedReplyId = ValueNotifier(null);
    }
  }

  void _scrollListener() {
    if (commentsScrollController.position.pixels >= commentsScrollController.position.maxScrollExtent - 300) {
      loadMoreComments();
    }
  }

  Future<void> setupSocket() async {
    try {
      // Khởi tạo hoặc lấy instance của StompService
      stompService = await StompService.instance();

      // Đăng ký listener cho từng loại kênh, xử lý lỗi riêng cho từng loại
      logger.i("Bắt đầu đăng ký các listener cho socket");

      try {
        stompService.registerListener(type: StompListenType.comment, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.comment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.comment: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.editComment, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.editComment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.editComment: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.reply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.reply");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.reply: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.editReply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.editReply");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.editReply: $e");
      }

      logger.i("🚀 Socket đã được kết nối và đăng ký tất cả listener thành công");
    } catch (e) {
      logger.e("⛔ Lỗi khi thiết lập kết nối socket: $e");
    }
  }

  void selectComment({CommentModel? comment}) {
    commentSelected.value = comment;
    commentSelected.notifyListeners();
  }

  Future<void> send({CommentModel? comment}) async {
    if (comment == null) {
      logger.i('Đang gửi comment mới');
      logger.i('Student info: ${student}');
      try {
        final payload = {
          'chapterId': chapterCurrent.value?.id,
          'courseId': courseDetailCurrent.value?.id ?? '',
          'username': student?.email ?? '',
          'detail': commentController.text,
        };

        stompService.send(
          StompListenType.comment,
          jsonEncode(payload),
        );
        commentController.clear();
      } catch (e) {
        logger.e("Lỗi khi gửi comment: $e");
        showToast(title: "Gửi thất bại!!!", type: ToastificationType.error);
      }
    } else {
      logger.i('Đang gửi reply cho comment: ${commentSelected.value?.username}');
      try {
        logger.i('Comment được chọn: ${commentSelected.value}');
        final payload = {
          'replyUsername': student?.email,
          'ownerUsername': commentSelected.value?.username,
          'chapterId': chapterCurrent.value?.id,
          'courseId': courseDetailCurrent.value?.id ?? '',
          'detail': commentController.text,
          'parentCommentId': commentSelected.value?.commentId,
        };

        logger.i('Gửi reply đến /app/comment-reply: ${jsonEncode(payload)}');
        stompService.send(
          StompListenType.reply,
          jsonEncode(payload),
        );
        commentController.clear();
      } catch (e) {
        logger.e("Lỗi khi gửi reply: $e");
        showToast(title: "Gửi phản hồi thất bại!!!", type: ToastificationType.error);
      }
    }
    setCommentSelected();
  }

  // Hàm thiết lập comment được chọn để phản hồi
  void setCommentSelected({CommentModel? comment}) {
    commentSelected.value = comment;
    commentSelected.notifyListeners();
  }

  Future<void> loadComments({bool isReset = false, int? pageSize}) async {
    if (isReset) {
      hasMoreComments = true;
      comments.value = null;
    }

    if (!hasMoreComments || isLoadingComments) return;

    isLoadingComments = true;
    notifyListeners();

    try {
      final String? courseId = courseDetailCurrent.value?.id;
      final String? chapterId = chapterCurrent.value?.id;

      if (courseId == null || chapterId == null) {
        logger.e("Không thể tải comments: courseId hoặc chapterId không tồn tại");
        isLoadingComments = false;
        notifyListeners();
        return;
      }

      // Sử dụng pageSize từ tham số nếu có, ngược lại dùng giá trị mặc định
      final int effectivePageSize = pageSize ?? commentPageSize;

      // Tính toán pageNumber dựa trên kích thước hiện tại của danh sách comments
      final int pageNumber = (comments.value?.length ?? 0);

      logger.i("Tải comments cho chapter: $chapterId, pageNumber: $pageNumber, pageSize: $effectivePageSize");

      final NetworkState<List<CommentModel>> result = await commentRepository.commentInChapter(
        chapterId: chapterId,
        pageSize: effectivePageSize,
        pageNumber: pageNumber,
      );

      if (result.isSuccess && result.result != null) {
        final List<CommentModel> newComments = result.result!;
        logger.i("Đã tải ${newComments.length} comments");

        if (isReset || comments.value == null) {
          comments.value = newComments;
        } else {
          final existingComments = List<CommentModel>.from(comments.value!);

          // Loại bỏ các comment trùng lặp
          final updatedComments = [...existingComments];
          for (final comment in newComments) {
            if (!existingComments.any((c) => c.commentId == comment.commentId)) {
              updatedComments.add(comment);
            }
          }

          comments.value = updatedComments;
        }

        // Kiểm tra xem còn comments để tải không
        hasMoreComments = newComments.length >= effectivePageSize;

        // Cập nhật UI
        comments.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi tải bình luận: $e");
    } finally {
      isLoadingComments = false;
      notifyListeners();
    }
  }

  // Hàm tải thêm comments
  Future<void> loadMoreComments() async {
    await loadComments();
  }

  // Hàm tải thêm replies cho một comment cụ thể
  Future<void> loadMoreReplies({required String commentId}) async {
    if (comments.value == null) return;

    try {
      // Tìm comment hiện tại
      final existingComments = List<CommentModel>.from(comments.value!);
      final commentIndex = existingComments.indexWhere((c) => c.commentId == commentId);

      if (commentIndex == -1) return;

      final comment = existingComments[commentIndex];

      // Sử dụng chính xác số lượng replies hiện tại làm pageNumber
      final int currentRepliesCount = comment.commentReplyResponses?.length ?? 0;

      logger.i("Tải replies cho comment: $commentId, pageNumber: $currentRepliesCount");

      final NetworkState<List<ReplyModel>> result = await commentRepository.getReplies(
        commentId: commentId,
        replyPageSize: 5, // Số lượng replies mỗi lần tải
        pageNumber: currentRepliesCount,
      );

      if (result.isSuccess && result.result != null) {
        final List<ReplyModel> newReplies = result.result!;
        logger.i("Đã tải ${newReplies.length} replies");

        // Loại bỏ các reply trùng lặp
        final List<ReplyModel> uniqueNewReplies = [];
        for (final newReply in newReplies) {
          if (!(comment.commentReplyResponses ?? [])
              .any((existingReply) => existingReply.commentReplyId == newReply.commentReplyId)) {
            uniqueNewReplies.add(newReply);
          }
        }

        // Cập nhật comment với replies mới
        final updatedComment = comment.copyWith(
          commentReplyResponses: [
            ...(comment.commentReplyResponses ?? []),
            ...uniqueNewReplies,
          ],
        );

        // Cập nhật danh sách comments
        existingComments[commentIndex] = updatedComment;
        comments.value = existingComments;
        comments.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi tải phản hồi: $e");
    }
  }

  void safelyUpdateNotifier<T>(ValueNotifier<T> notifier, T value) {
    // Kiểm tra trùng lặp dữ liệu trước khi cập nhật
    if (notifier.value == value) {
      logger.i("Dữ liệu không thay đổi, bỏ qua cập nhật ValueNotifier");
      return;
    }

    notifier.value = value;
    try {
      notifier.notifyListeners();
      logger.i("Đã cập nhật ValueNotifier thành công");
    } catch (e) {
      logger.e("Lỗi update ValueNotifier: $e");
    }
  }

  // Các hàm xử lý socket nhận comment, reply
  @override
  void onStompCommentReceived(dynamic body) {
    if (body == null) {
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(body);
      logger.i("Phản hồi comment từ server: ${data.toString()}");

      // Khởi tạo biến comment
      CommentModel comment;

      // Kiểm tra cấu trúc JSON để xác định phương thức tạo CommentModel thích hợp
      if (data['result']['updateDate'] != null) {
        // Trường hợp chỉnh sửa comment (có updateDate - lastUpdate)
        comment = CommentModel(
          countOfReply: data['result']['countOfReply'],
          courseId: data['result']['courseId'],
          commentId: data['result']['commentId'],
          username: data['result']['usernameOwner'],
          avatar: data['result']['avatarOwner'],
          fullname: data['result']['fullnameOwner'],
          chapterId: data['result']['chapterId'],
          createdDate: data['result']["createdDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["createdDate"]),
          detail: data['result']['newDetail'],
          lastUpdate: data['result']["updateDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["updateDate"]),
        );

        // Tìm và cập nhật comment trong danh sách
        _updateExistingComment(comment);
      } else {
        // Trường hợp comment mới (không có updateDate)
        comment = CommentModel.fromJson(data['result']);
        // Thêm comment mới vào đầu danh sách
        _addNewComment(comment);
      }

      // Set animated comment ID cho hiệu ứng highlight - thêm kiểm tra _isDisposed
      // if (!_isDisposed) {
      safelyUpdateNotifier(animatedCommentId, comment.commentId);

      Future.delayed(Duration(seconds: 2), () {
        safelyUpdateNotifier(animatedCommentId, null);
      });
      // }
    } catch (e) {
      logger.e("Lỗi khi xử lý comment từ socket: $e");
    }
  }

  void _updateExistingComment(CommentModel updatedComment) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int index = currentComments.indexWhere((comment) => comment.commentId == updatedComment.commentId);

    if (index != -1) {
      // Cập nhật nội dung comment nhưng giữ nguyên replies
      final CommentModel existingComment = currentComments[index];
      final updatedWithExistingReplies = updatedComment.copyWith(
        commentReplyResponses: existingComment.commentReplyResponses,
      );

      currentComments[index] = updatedWithExistingReplies;
      comments.value = currentComments;
      comments.notifyListeners();
    }
  }

  @override
  void onStompReplyReceived(dynamic body) {
    if (body == null) {
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(body);
      logger.i("Phản hồi reply từ server: ${data.toString()}");

      String actualParentCommentId = "";
      // Khởi tạo biến comment
      ReplyModel reply;

      // Kiểm tra cấu trúc JSON để xác định phương thức tạo CommentModel thích hợp
      if (data['result']['updateDate'] != null) {
        // Trường hợp chỉnh sửa reply (có updateDate - lastUpdate)
        // Lấy ID chính xác của comment cha từ comments hiện tại
        final String replyId = data['result']['commentReplyId'];

        // Tìm commentId chính xác từ comments hiện tại
        if (comments.value != null) {
          for (var comment in comments.value!) {
            final replies = comment.commentReplyResponses ?? [];
            for (var existingReply in replies) {
              if (existingReply.commentReplyId == replyId) {
                actualParentCommentId = comment.commentId ?? "";
                break;
              }
            }
            if (actualParentCommentId.isNotEmpty) break;
          }
        }

        reply = ReplyModel(
          commentReplyId: replyId,
          commentId: actualParentCommentId,
          detail: data['result']['newDetail'],
          createdDate: data['result']["createdDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["createdDate"]),
          avatarReply: data['result']['avatarReply'],
          fullnameOwner: data['result']['fullnameOwner'],
          fullnameReply: data['result']['fullnameReply'],
          replyCount: data['result']['replyCount'],
          usernameOwner: data['result']['usernameOwner'],
          usernameReply: data['result']['usernameReply'],
          lastUpdate: data['result']["updateDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["updateDate"]),
        );

        // Tìm và cập nhật reply trong danh sách
        _updateExistingReply(reply, actualParentCommentId);
      } else {
        // Trường hợp reply mới (không có updateDate)
        reply = ReplyModel.fromJson(data['result']);
        actualParentCommentId = data['result']['commentId'];

        // Thêm reply mới vào comment cha
        _addNewReply(reply, actualParentCommentId);
      }

      // Set animated reply ID cho hiệu ứng highlight - sử dụng safelyUpdateNotifier để tránh lỗi

      safelyUpdateNotifier(animatedReplyId, reply.commentReplyId);

      Future.delayed(Duration(seconds: 2), () {
        safelyUpdateNotifier(animatedReplyId, null);
      });
    } catch (e) {
      logger.e("Lỗi khi xử lý reply từ socket: $e");
    }
  }

// Hàm hỗ trợ thêm comment mới vào danh sách
  void _addNewComment(CommentModel newComment) {
    if (comments.value == null) {
      comments.value = [newComment];
    } else {
      // Kiểm tra xem comment đã tồn tại chưa
      final List<CommentModel> currentComments = List.from(comments.value!);
      final bool exists = currentComments.any((comment) => comment.commentId == newComment.commentId);

      if (!exists) {
        comments.value = [newComment, ...currentComments];
      }
    }

    comments.notifyListeners();
  }

// Hàm hỗ trợ thêm reply mới vào comment cha
  void _addNewReply(ReplyModel newReply, String parentCommentId) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments.indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];

      // Kiểm tra xem reply đã tồn tại chưa
      final List<ReplyModel> existingReplies = parentComment.commentReplyResponses ?? [];
      final bool replyExists = existingReplies.any((reply) => reply.commentReplyId == newReply.commentReplyId);

      if (!replyExists) {
        // Tạo bản sao của comment cha với danh sách replies đã cập nhật
        final CommentModel updatedParentComment = parentComment.copyWith(
          countOfReply: newReply.replyCount,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;

        comments.notifyListeners();
      }
    }
  }

// Hàm hỗ trợ cập nhật reply đã tồn tại
  void _updateExistingReply(ReplyModel updatedReply, String parentCommentId) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments.indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];
      final List<ReplyModel> replies = parentComment.commentReplyResponses ?? [];

      final int replyIndex = replies.indexWhere((reply) => reply.commentReplyId == updatedReply.commentReplyId);

      if (replyIndex != -1) {
        // Tạo bản sao danh sách replies và cập nhật reply
        final List<ReplyModel> updatedReplies = List.from(replies);
        updatedReplies[replyIndex] = updatedReply;

        // Tạo bản sao của comment cha với danh sách replies đã cập nhật
        final CommentModel updatedParentComment = parentComment.copyWith(
          commentReplyResponses: updatedReplies,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;

        comments.notifyListeners();
      }
    }
  }

// Hàm reset trạng thái của comment khi BottomSheet được đóng
  void resetCommentState() {
    logger.i("Reset trạng thái comment");
    hasMoreComments = true;
    isLoadingComments = false;
    comments.value = null;
    commentSelected.value = null;
    commentController.clear();

    // Đảm bảo UI được cập nhật
    comments.notifyListeners();
    commentSelected.notifyListeners();
  }

  Future<void> editComment({required String commentId, required String detail}) async {
    try {
      stompService.send(
        StompListenType.editComment,
        jsonEncode({
          'commentId': commentId,
          'usernameOwner': student?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(title: "Chỉnh sửa bình luận thất bại!", type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa comment: $e");
    }
  }

  Future<void> editReply({required String replyId, required String parentCommentId, required String detail}) async {
    await StompService.instance();

    try {
      stompService.send(
        StompListenType.editReply,
        jsonEncode({
          'commentReplyId': replyId,
          'usernameReply': student?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(title: "Chỉnh sửa phản hồi thất bại!", type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa reply: $e");
    }
  }

// Thêm phương thức hủy đăng ký riêng để có thể gọi từ nhiều nơi
  void unregisterStompListeners() {
    if (stompService != null) {
      try {
        logger.i("Hủy đăng ký tất cả listener");
        stompService.unregisterListener(type: StompListenType.comment, listener: this);
        stompService.unregisterListener(type: StompListenType.editComment, listener: this);
        stompService.unregisterListener(type: StompListenType.reply, listener: this);
        stompService.unregisterListener(type: StompListenType.editReply, listener: this);
      } catch (e) {
        logger.e("Lỗi khi hủy đăng ký listener: $e");
      }
    }
  }

  void setCanSend(bool can) {
    canSend.value = can;
  }
}
