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
      case app_model.NotificationType.COMMENT:
        notificationIcon.value = Icons.comment;
        notificationColor.value = success;
        notificationTitle.value = 'Bình luận mới';
        setupCourseButtons();
        break;
      case app_model.NotificationType.COMMENT_REPLY:
        notificationIcon.value = Icons.reply;
        notificationColor.value = Colors.orange;
        notificationTitle.value = 'Phản hồi bình luận';
        setupGradeButtons();
        break;
      case app_model.NotificationType.CHAT_MESSAGE:
        notificationIcon.value = Icons.chat;
        notificationColor.value = Colors.purple;
        notificationTitle.value = 'Tin nhắn mới';
        setupSystemButtons();
        break;
      case app_model.NotificationType.MESSAGE:
      default:
        notificationIcon.value = Icons.notifications;
        notificationColor.value = primary3;
        notificationTitle.value = 'Thông báo hệ thống';
        setupSystemButtons();
        break;
    }

    // Thông báo cập nhật UI
    notifyListeners();
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

  void setupGradeButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Xem điểm',
        icon: Icons.assessment,
        color: Colors.orange,
        onTap: () => Get.toNamed(Routers.courseDetail),
      ),
    ];
  }

  void setupSystemButtons() {
    actionButtons.value = [
      ActionButton(
        label: 'Đổi mật khẩu',
        icon: Icons.lock_outline,
        color: primary3,
        onTap: () => Get.toNamed(Routers.changePassword),
      ),
      ActionButton(
        label: 'Hỗ trợ',
        icon: Icons.headset_mic,
        color: grey3,
        onTap: () => Get.toNamed(Routers.support),
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

      //todo: đánh dấu đọc đã đọc thông báo
      // NetworkState resultMarkAsRead = authRepository.markAsRead(notificationData.value?.notificationId);

      // Chỉ ẩn dialog loading nếu không phải trong quá trình khởi tạo
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
