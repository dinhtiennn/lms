import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart' as app_model;
import 'package:lms/src/utils/app_utils.dart';

class NotificationTeacherScreen extends StatefulWidget {
  const NotificationTeacherScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTeacherScreen> createState() =>
      _NotificationTeacherScreenState();
}

class _NotificationTeacherScreenState extends State<NotificationTeacherScreen> {
  late NotificationTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NotificationTeacherViewModel>(
        viewModel: NotificationTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Thông báo',
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                    onPressed: () => _viewModel.markAllAsRead(),
                    child: Text('Đọc tất cả',
                        style: styleVerySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: white,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1.0,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: white)))
              ],
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.refresh();
        return;
      },
      child: ValueListenableBuilder<app_model.NotificationView?>(
        valueListenable: _viewModel.notifications,
        builder: (context, notificationView, _) {
          if (notificationView == null && _viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationView?.notifications ?? [];

          if (notifications.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.8, // Đảm bảo chiều cao đủ để kéo
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 70,
                        color: grey4,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bạn chưa có thông báo nào',
                        style: styleMedium.copyWith(color: grey3),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _viewModel.scrollController,
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(vertical: 16)
                .copyWith(bottom: Get.height / 15),
            itemCount:
                notifications.length + (_viewModel.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notification = notifications[index];
              return _buildItemNotification(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemNotification(app_model.NotificationModel notification) {
    // Xác định màu và biểu tượng dựa trên loại thông báo
    Color accentColor;
    IconData iconData;
    String title = '';
    String message = '';
    String time = '';

    // Xác định thông tin hiển thị dựa trên loại thông báo
    switch (notification.notificationType) {
      case app_model.NotificationType.COMMENT:
        accentColor = success;
        iconData = Icons.comment;
        title = 'Bình luận mới';
        break;
      case app_model.NotificationType.COMMENT_REPLY:
        accentColor = Colors.orange;
        iconData = Icons.reply;
        title = 'Phản hồi bình luận';
        break;
      case app_model.NotificationType.CHAT_MESSAGE:
        accentColor = Colors.blue;
        iconData = Icons.chat;
        title = 'Tin nhắn mới';
        break;
      case app_model.NotificationType.MESSAGE:
      default:
        accentColor = primary3;
        iconData = Icons.notifications;
        title = 'Thông báo hệ thống';
        break;
    }

    // Lấy nội dung và thời gian
    message = notification.description ?? 'Không có nội dung';
    time = AppUtils.getTimeAgo(notification.createdAt ?? DateTime.now());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha((255 * 0.05).round()),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: transparent,
        child: InkWell(
          onTap: () => _viewModel.notificationDetail(notification),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  notification.isRead == true
                      ? transparent
                      : accentColor.withAlpha(10),
                  transparent,
                ],
              ),
              border: Border(
                left: BorderSide(
                  color: accentColor,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: styleSmallBold.copyWith(
                              color: black,
                              fontWeight: notification.isRead == true
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          Text(
                            time,
                            style: styleVerySmall.copyWith(
                              color: grey4,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        message,
                        style: styleSmall.copyWith(
                          color:
                              notification.isRead == true ? grey4 : blackLight,
                          fontWeight: notification.isRead == true
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
