import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NotificationViewModel>(
        viewModel: NotificationViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary3,
              title: Text(
                'Thông báo',
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                    onPressed: () {
                      // Xử lý đánh dấu tất cả là đã đọc
                    },
                    child: Text('Đánh dấu đã đọc',
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
      child: ValueListenableBuilder<NotificationView?>(
        valueListenable: _viewModel.notifications,
        builder: (context, notificationView, _) {
          if (notificationView == null && _viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationView?.notifications ?? [];
          if (notifications.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            controller: _viewModel.scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(vertical: 16).copyWith(bottom: Get.height / 15),
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoadingMore,
                  builder: (context, isLoading, _) {
                    return isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  },
                );
              }

              final notification = notifications[index];
              final notificationType = _getNotificationType(notification.notificationType);

              return _buildItemNotification(
                title: _getNotificationTitle(notification),
                message: notification.description ?? 'Không có nội dung',
                time: _formatTime(notification.createdAt),
                isRead: notification.isRead ?? false,
                type: notificationType,
                onTap: () {
                  Get.toNamed(Routers.notificationDetail, arguments: {
                    'title': _getNotificationTitle(notification),
                    'message': notification.description,
                    'time': _formatTime(notification.createdAt),
                    'type': notificationType,
                    'id': notification.notificationId,
                    'isRead': notification.isRead
                  });
                },
              );
            },
            itemCount: notifications.length + 1, // +1 for loading indicator
          );
        },
      ),
    );
  }

  String _getNotificationType(NotificationType? type) {
    switch (type) {
      case NotificationType.COMMENT:
        return 'comment';
      case NotificationType.MESSAGE:
        return 'system';
      case NotificationType.COMMENT_REPLY:
        return 'reply';
      case NotificationType.CHAT_MESSAGE:
        return 'chat';
      default:
        return 'system';
    }
  }

  String _getNotificationTitle(NotificationModel notification) {
    switch (notification.notificationType) {
      case NotificationType.COMMENT:
        return 'Bình luận mới';
      case NotificationType.MESSAGE:
        return 'Tin nhắn mới';
      case NotificationType.COMMENT_REPLY:
        return 'Phản hồi bình luận';
      case NotificationType.CHAT_MESSAGE:
        return 'Tin nhắn trò chuyện';
      default:
        return 'Thông báo';
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Vừa xong';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildItemNotification({
    required String title,
    required String message,
    required String time,
    required bool isRead,
    required String type,
    Function()? onTap,
  }) {
    // Xác định màu và biểu tượng dựa trên loại thông báo
    Color accentColor;
    IconData iconData;

    switch (type) {
      case 'comment':
        accentColor = Colors.green;
        iconData = Icons.comment;
        break;
      case 'reply':
        accentColor = Colors.orange;
        iconData = Icons.reply_all;
        break;
      case 'chat':
        accentColor = Colors.purple;
        iconData = Icons.chat;
        break;
      case 'system':
      default:
        accentColor = primary3;
        iconData = Icons.notifications;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha((255 * 0.05).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  isRead ? transparent : accentColor.withAlpha(10),
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
                  padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: styleSmallBold.copyWith(
                                color: black,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: styleVerySmall.copyWith(
                              color: grey4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: styleSmall.copyWith(
                          color: isRead ? grey4 : blackLight,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
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
