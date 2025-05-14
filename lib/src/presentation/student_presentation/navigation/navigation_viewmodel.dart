import 'package:lms/src/resource/resource.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NavigationViewModel extends BaseViewModel with StompListener {
  final PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  bool _isSocketConnected = false;
  bool _isDisposed = false;
  StompService? stompService;

  init() async {
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
      logger.i("Đăng ký listener mới cho socket");
      stompService?.registerListener(
          type: StompListenType.notification, listener: this);

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

  void setIndex(int index) {
    controller.index = index;
  }

  @override
  void onStompNotificationReceived(dynamic data) {
    logger.i('🔔 NavigationViewModel - Nhận thông báo: $data');
    // TODO: Thêm logic xử lý thông báo ở đây
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Hủy đăng ký listener khi dispose
    if (_isSocketConnected && stompService != null) {
      try {
        logger.i(
            "🧹 Hủy đăng ký listener notification trong NavigationViewModel");
        stompService?.unregisterListener(
            type: StompListenType.notification, listener: this);
        logger.i("✅ Đã hủy đăng ký notification thành công");
      } catch (e) {
        logger.e("❌ Lỗi khi hủy đăng ký notification: $e");
      }
    }

    controller.dispose();
    super.dispose();
    logger.i("🏁 NavigationViewModel đã được dispose");
  }
}
