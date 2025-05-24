import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart' as app_model;
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class NotificationDetailTeacherViewModel extends BaseViewModel {
  ValueNotifier<app_model.NotificationModel?> notificationData =
      ValueNotifier(null);

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
      if (Get.arguments != null &&
          Get.arguments is Map &&
          Get.arguments['notification'] != null) {
        notificationData.value = Get.arguments['notification'];

        // Đánh dấu là đã đọc sau khi build hoàn tất
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Thiết lập UI dựa trên loại thông báo
          setupNotificationUI();

          // Đánh dấu thông báo đã đọc nếu chưa đọc
          if (notificationData.value != null &&
              notificationData.value!.isRead != true) {
            markAsRead();
          }
        });
      } else {
        // Đảm bảo hiển thị toast sau khi build hoàn tất
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showToast(
              title: 'Không tìm thấy thông tin thông báo',
              type: ToastificationType.error);
        });
      }
    } catch (e) {
      logger.e("Lỗi khi khởi tạo chi tiết thông báo: $e");

      // Đảm bảo hiển thị toast sau khi build hoàn tất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(title: 'Đã xảy ra lỗi', type: ToastificationType.error);
      });
    }
  }

  void setupCourseButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Xem chi tiết',
        icon: Icons.visibility,
        color: success,
        onTap: () => Get.toNamed(Routers.courseDetail),
      ),
      ActionButton(
        label: 'Gửi phản hồi',
        icon: Icons.reply,
        color: grey3,
        onTap: () => {},
        outlined: true,
      ),
    ];
  }


  Future<void> markAsRead() async {
    try {
      if (notificationData.value?.notificationId == null ||
          notificationData.value?.isRead == true) {
        return;
      }

      // Chỉ hiển thị dialog loading nếu không phải trong quá trình khởi tạo
      if (WidgetsBinding.instance.schedulerPhase !=
          SchedulerPhase.persistentCallbacks) {
        setLoading(true);
      } else {
        notifyListeners(); // Vẫn thông báo cho UI biết state đã thay đổi
      }
      if (WidgetsBinding.instance.schedulerPhase !=
          SchedulerPhase.persistentCallbacks) {
        setLoading(false);
      } else {
        notifyListeners(); // Vẫn thông báo cho UI biết state đã thay đổi
      }

      if (Get.isRegistered<NotificationTeacherViewModel>()) {
        Get.find<NotificationTeacherViewModel>().refresh();
      }
    } catch (e) {
      logger.e("Lỗi khi đánh dấu thông báo đã đọc: $e");

      // Đảm bảo luôn tắt loading nếu có lỗi
      if (WidgetsBinding.instance.schedulerPhase !=
          SchedulerPhase.persistentCallbacks) {
        setLoading(false);
      }
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
        notificationIcon.value = Icons.comment_outlined;
        notificationColor.value = primary3;
        notificationTitle.value = 'Bình luận mới';
        setupCommentButtons();
        break;
      case NotificationType.COMMENT_REPLY:
        notificationIcon.value = Icons.reply_outlined;
        notificationColor.value = primary3;
        notificationTitle.value = 'Phản hồi bình luận';
        setupCommentButtons();
        break;
      case NotificationType.CHAT_MESSAGE:
        notificationIcon.value = Icons.chat_outlined;
        notificationColor.value = primary2;
        notificationTitle.value = 'Tin nhắn trò chuyện';
        setupChatButtons();
        break;
      case NotificationType.JOIN_CLASS_PENDING:
        notificationIcon.value = Icons.class_outlined;
        notificationColor.value = warning;
        notificationTitle.value = 'Yêu cầu tham gia lớp học';
        setupClassRequestButtons();
        break;
      case NotificationType.JOIN_CLASS_REJECTED:
        notificationIcon.value = Icons.cancel_outlined;
        notificationColor.value = error;
        notificationTitle.value = 'Từ chối tham gia lớp học';
        break;
      case NotificationType.JOIN_CLASS_APPROVED:
        notificationIcon.value = Icons.check_circle_outlined;
        notificationColor.value = success;
        notificationTitle.value = 'Chấp nhận tham gia lớp học';
        setupClassApprovedButtons();
        break;
      case NotificationType.POST_CREATED:
        notificationIcon.value = Icons.post_add_outlined;
        notificationColor.value = primary2;
        notificationTitle.value = 'Bài đăng mới';
        setupPostButtons();
        break;
      case NotificationType.POST_COMMENT:
        notificationIcon.value = Icons.comment_outlined;
        notificationColor.value = primary3;
        notificationTitle.value = 'Bình luận bài đăng';
        setupPostCommentButtons();
        break;
      case NotificationType.POST_COMMENT_REPLY:
        notificationIcon.value = Icons.reply_outlined;
        notificationColor.value = primary3;
        notificationTitle.value = 'Phản hồi bình luận bài đăng';
        setupPostCommentButtons();
        break;
      case NotificationType.MESSAGE:
      default:
        notificationIcon.value = Icons.notifications_outlined;
        notificationColor.value = grey3;
        notificationTitle.value = 'Thông báo hệ thống';
        break;
    }

    // Thông báo cập nhật UI
    notifyListeners();
  }

  void setupCommentButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Đi tới lớp học',
        icon: Icons.class_outlined,
        color: primary3,
        onTap: () => viewComment(),
      ),
    ];
  }

  void setupChatButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Mở cuộc trò chuyện',
        icon: Icons.chat_outlined,
        color: primary2,
        onTap: () => openChat(),
      ),
    ];
  }

  void setupClassRequestButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Xem lớp học',
        icon: Icons.class_outlined,
        color: warning,
        onTap: () => viewClass(),
      ),
    ];
  }

  void setupClassApprovedButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Xem lớp học',
        icon: Icons.class_outlined,
        color: success,
        onTap: () => enterClass(),
      ),
    ];
  }

  void setupPostButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Đi tới nhóm',
        icon: Icons.visibility_outlined,
        color: primary2,
        onTap: () => viewPost(),
      ),
    ];
  }

  void setupPostCommentButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Xem lớp học',
        icon: Icons.class_outlined,
        color: primary3,
        onTap: () => viewPostComment(),
      ),
    ];
  }

  void viewComment() {
    // TODO: Implement view comment action
    Get.back();
  }

  void replyToComment() {
    // TODO: Implement reply to comment action
    Get.back();
  }

  void openChat() {
    // TODO: Implement open chat action
    Get.back();
  }

  void viewClass() {
    // TODO: Implement view class action
    Get.back();
  }

  void enterClass() {
    // TODO: Implement enter class action
    Get.back();
  }

  void viewPost() {
    // TODO: Implement view post action
    Get.back();
  }

  void viewPostComment() {
    // TODO: Implement view post comment action
    Get.back();
  }

  void replyToPostComment() {
    // TODO: Implement reply to post comment action
    Get.back();
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
