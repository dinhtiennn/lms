import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class NotificationDetailViewModel extends BaseViewModel {
  ValueNotifier<NotificationModel?> notificationData = ValueNotifier(null);

  // Lưu trữ thông tin liên quan đến loại thông báo
  ValueNotifier<IconData> notificationIcon = ValueNotifier(Icons.notifications);
  ValueNotifier<Color> notificationColor = ValueNotifier(primary3);
  ValueNotifier<String> notificationTitle = ValueNotifier('');
  ValueNotifier<String> notificationDesc = ValueNotifier('');
  ValueNotifier<String> notificationTime = ValueNotifier('');
  ValueNotifier<List<ActionButton>> actionButtons = ValueNotifier([]);

  init() async {
    try {
      // Lấy thông tin thông báo từ arguments
      notificationData.value = Get.arguments['notification'];

      if (notificationData.value != null) {
        // Thiết lập UI dựa trên loại thông báo
        setupNotificationUI();
      } else {
        showToast(title: 'Không tìm thấy thông tin thông báo', type: ToastificationType.error);
      }
    } catch (e) {
      logger.e("Lỗi khi khởi tạo chi tiết thông báo: $e");
      showToast(title: 'Đã xảy ra lỗi', type: ToastificationType.error);
    }
  }

  void setupNotificationUI() {
    final notification = notificationData.value;
    if (notification == null) return;

    // Xử lý tiêu đề và mô tả
    notificationDesc.value = notification.description ?? '';

    // Xử lý thời gian
    if (notification.createdAt != null) {
      notificationTime.value = AppUtils.getTimeAgo(notification.createdAt!);
    } else {
      notificationTime.value = 'Vừa xong';
    }

    // Thiết lập icon, màu sắc và nút hành động dựa trên loại thông báo
    switch (notification.notificationType) {
      case NotificationType.COMMENT:
        notificationIcon.value = Icons.comment;
        notificationColor.value = success;
        notificationTitle.value = 'Bình luận mới';
        break;
      case NotificationType.COMMENT_REPLY:
        notificationIcon.value = Icons.reply;
        notificationColor.value = Colors.orange;
        notificationTitle.value = 'Phản hồi bình luận';
        break;
      case NotificationType.CHAT_MESSAGE:
        notificationIcon.value = Icons.chat;
        notificationColor.value = Colors.purple;
        notificationTitle.value = 'Tin nhắn mới';
        break;
      case NotificationType.MESSAGE:
      default:
        notificationIcon.value = Icons.notifications;
        notificationColor.value = primary3;
        notificationTitle.value = 'Thông báo hệ thống';
        break;
    }

    // Thông báo cập nhật UI
    notifyListeners();
  }

  Future<void> markAsRead() async {
    try {
      if (notificationData.value?.notificationId == null || notificationData.value?.isRead == true) {
        return;
      }
      setLoading(true);
      //todo: đánh dấu đọc đã đọc thông báo
      // NetworkState resultMarkAsRead = authRepository.markAsRead(notificationData.value?.notificationId);
      setLoading(false);
      if (Get.isRegistered<NotificationViewModel>()) {
        Get.find<NotificationViewModel>().refresh();
      }
    } catch (e) {
      logger.e("Lỗi khi đánh dấu thông báo đã đọc: $e");
    }
  }

  @override
  void dispose() {
    notificationData.dispose();
    notificationIcon.dispose();
    notificationColor.dispose();
    notificationTitle.dispose();
    notificationDesc.dispose();
    notificationTime.dispose();
    actionButtons.dispose();
    super.dispose();
  }
}
// Extension cho NotificationModel
extension NotificationModelExtension on NotificationModel {
  NotificationModel copyWith({
    String? notificationId,
    String? receivedAccountId,
    String? commentId,
    String? commentReplyId,
    NotificationType? notificationType,
    bool? isRead,
    String? description,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      receivedAccountId: receivedAccountId ?? this.receivedAccountId,
      commentId: commentId ?? this.commentId,
      commentReplyId: commentReplyId ?? this.commentReplyId,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
