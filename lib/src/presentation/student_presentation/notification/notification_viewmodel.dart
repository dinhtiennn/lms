import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart' as app_model;
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';

class NotificationViewModel extends BaseViewModel with StompListener {
  ValueNotifier<app_model.NotificationView?> notifications = ValueNotifier(null);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  final ScrollController scrollController = ScrollController();
  bool hasMoreData = true;
  int pageSize = 10;
  bool _isLoading = false;
  StompService? stompService;
  bool _isSocketConnected = false;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;

  init() async {
    scrollController.addListener(_onScroll);
    setupSocket();
    // Sử dụng Future.microtask để đảm bảo refresh() được gọi sau khi build hoàn tất
    Future.microtask(() => refresh());
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
      logger.i("Socket đã được kết nối và đăng ký listener thành công");
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

  @override
  void onStompNotificationReceived(dynamic data) {
    try {
      logger.i("Nhận thông báo mới từ socket: $data");
      refresh();
    } catch (e) {
      logger.e("Lỗi khi xử lý thông báo từ socket: $e");
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMoreData) {
      final notificationsLength = notifications.value?.notifications?.length ?? 0;
      loadNotification(offset: notificationsLength);
    }
  }

  void refresh() async {
    hasMoreData = true;
    await loadNotification(offset: 0);
  }

  Future<void> loadNotification({int offset = 0}) async {
    if (isLoadingMore.value || !hasMoreData) return;

    if (offset == 0) {
      _isLoading = true;
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<app_model.NotificationView> resultNotifications =
        await authRepository.getNotifications(pageSize: pageSize, pageNumber: offset);

    if (resultNotifications.isSuccess && resultNotifications.result != null) {
      if (offset == 0) {
        notifications.value = resultNotifications.result;
      } else {
        if (notifications.value != null) {
          final app_model.NotificationView updatedNotificationView = app_model.NotificationView(
            countUnreadNotification: notifications.value!.countUnreadNotification,
            notifications: [
              ...(notifications.value!.notifications ?? []),
              ...(resultNotifications.result!.notifications ?? [])
            ],
          );
          notifications.value = updatedNotificationView;
        } else {
          notifications.value = resultNotifications.result;
        }
      }

      hasMoreData = (resultNotifications.result!.notifications?.length ?? 0) >= pageSize;
    }

    if (offset == 0) {
      _isLoading = false;
    } else {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    }
  }

  void notificationDetail(NotificationModel notification) async {
    if (notification.isRead == true) {
      Get.toNamed(Routers.notificationDetail, arguments: {'notification': notification});
    } else {
      NetworkState resultMarkAsRead = await authRepository.markAsRead(notificationId: notification.notificationId);
      if (resultMarkAsRead.isSuccess) {
        Get.toNamed(Routers.notificationDetail, arguments: {'notification': notification})?.then((_) {
          refresh();
        });
      }
    }
  }

  void readAllNotification() async {
    NetworkState resultReadAllNotification = await authRepository.readAllNotification();
    if (resultReadAllNotification.isSuccess) {
      Get.back();
      refresh();
    }
  }

  @override
  void dispose() {
    if (_isSocketConnected && stompService != null) {
      stompService?.unregisterListener(type: StompListenType.notification, listener: this);
      logger.i("Đã hủy đăng ký listener thông báo");
    }

    _isDisposed = true;
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
