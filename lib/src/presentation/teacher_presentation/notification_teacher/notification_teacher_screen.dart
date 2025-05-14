import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';

class NotificationTeacherScreen extends StatefulWidget {
  const NotificationTeacherScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTeacherScreen> createState() => _NotificationTeacherScreenState();
}

class _NotificationTeacherScreenState extends State<NotificationTeacherScreen> {
  late NotificationTeacherViewModel _viewModel;

  //Dữ liệu mẫu để demo
  final notifications = [
    {
      'title': 'Hệ thống',
      'message': 'Tài khoản của bạn đang được đăng nhập trên thiết bị khác',
      'time': 'Vừa xong',
      'isRead': false,
      'type': 'system'
    },
    {
      'title': 'Khóa học',
      'message': 'Bạn có bài tập mới trong khóa học "Thiết kế cơ sở dữ liệu"',
      'time': '2 giờ trước',
      'isRead': false,
      'type': 'course'
    },
    {
      'title': 'Lịch học',
      'message': 'Lớp học "Lập trình Java" vào ngày mai đã được chuyển sang phòng A305',
      'time': '10:30 AM',
      'isRead': true,
      'type': 'schedule'
    },
    {
      'title': 'Điểm số',
      'message': 'Điểm kiểm tra giữa kỳ môn "An toàn thông tin" đã được cập nhật',
      'time': 'Hôm qua',
      'isRead': true,
      'type': 'grade'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NotificationTeacherViewModel>(
        viewModel: NotificationTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'notification'.tr,
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                    onPressed: () {},
                    child: Text('read_all'.tr,
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
        // Thêm logic refresh dữ liệu thông báo ở đây
        await Future.delayed(Duration(milliseconds: 800));
      },
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(vertical: 16).copyWith(bottom: Get.height / 15),
        itemBuilder: (context, index) {
          return _buildItemNotification(
            title: '${notifications[index]['title']}',
            message: '${notifications[index]['message']}',
            time: '${notifications[index]['time']}',
            isRead: notifications[index]['isRead'] as bool? ?? false,
            type: '${notifications[index]['type']}',
            onTap: () {
              Get.toNamed(Routers.notificationDetailTeacher, arguments: notifications[index]);
            },
          );
        },
        itemCount: notifications.length,
      ),
    );
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
      case 'course':
        accentColor = Colors.green;
        iconData = Icons.book;
        break;
      case 'schedule':
        accentColor = Colors.orange;
        iconData = Icons.schedule;
        break;
      case 'grade':
        accentColor = Colors.purple;
        iconData = Icons.grade;
        break;
      case 'system':
      default:
        accentColor = Colors.blue;
        iconData = Icons.notifications;
        break;
    }

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
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
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
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
