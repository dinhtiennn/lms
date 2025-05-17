import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lms/src/presentation/presentation.dart';

class NavigationTeacherViewModel extends BaseViewModel with StompListener {
  final PersistentTabController controller = PersistentTabController(initialIndex: 0);
  ValueNotifier<NotificationView?> notificationView = ValueNotifier(null);
  bool _isSocketConnected = false;
  bool _isDisposed = false;
  StompService? stompService;

  init() async {
    await _loadNotificationUnRead();
    setupSocket();
    // Kiểm tra trạng thái kết nối và thiết lập lại nếu cần
    if (!_isSocketConnected) {
      logger.w("Kết nối socket chưa được thiết lập, đang thử lại...");
      await Future.delayed(Duration(seconds: 1));
      setupSocket();
    }
  }

  void setupSocket() async {
    try {
      if (_isDisposed) {
        logger.w("Không thể thiết lập socket vì ViewModel đã bị hủy");
        return;
      }

      // Khởi tạo hoặc lấy instance của StompService
      stompService = await StompService.instance();

      // Đăng ký listener
      logger.i("Đăng ký listener thông báo");
      stompService?.registerListener(type: StompListenType.notification, listener: this);

      _isSocketConnected = true;
      logger.i("Socket đã được kết nối thành công");
    } catch (e) {
      logger.e("Lỗi khi thiết lập kết nối socket: $e");
      _isSocketConnected = false;

      // Thử kết nối lại sau một khoảng thời gian nếu việc thiết lập thất bại
      if (!_isDisposed) {
        Future.delayed(Duration(seconds: 3), () {
          if (!_isDisposed && !_isSocketConnected) {
            logger.i("Đang thử kết nối lại socket sau khi thất bại");
            setupSocket();
          }
        });
      }
    }
  }

  void setIndex(int index) {
    controller.index = index;
  }

  Future<void> _loadNotificationUnRead() async {
    NetworkState<NotificationView> resultNotifications =
        await authRepository.getNotifications(pageSize: 1, pageNumber: 0);
    if (resultNotifications.isSuccess && resultNotifications.result != null) {
      notificationView.value = resultNotifications.result;
    }
  }

  @override
  void onStompNotificationReceived(dynamic data) {
    try {
      logger.i("Nhận thông báo mới từ socket: $data");

      if (data != null) {
        // Parse JSON dữ liệu từ socket
        final Map<String, dynamic> notificationData = jsonDecode(data);
        if (notificationData['countUnreadNotification'] != null) {
          // notificationView.value =
          //     notificationView.value?.copyWith(countUnreadNotification: notificationData['countUnreadNotification']);
          notificationView.value = notificationView.value
              ?.copyWith(countUnreadNotification: (notificationView.value?.countUnreadNotification ?? 0) + 1);
        }
        notificationView.value = notificationView.value
            ?.copyWith(countUnreadNotification: (notificationView.value?.countUnreadNotification ?? 0) + 1);
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý thông báo từ socket: $e");
    }
  }
}
