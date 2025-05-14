import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';

class NotificationDetailTeacherScreen extends StatefulWidget {
  const NotificationDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<NotificationDetailTeacherScreen> createState() => _NotificationDetailTeacherScreenState();
}

class _NotificationDetailTeacherScreenState extends State<NotificationDetailTeacherScreen> {
  late NotificationDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NotificationDetailTeacherViewModel>(
      viewModel: NotificationDetailTeacherViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primary2,
            elevation: 0,
            title: Text(
              'notification_detail'.tr,
              style: styleLargeBold.copyWith(color: white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: error,
                ),
                onPressed: () {
                  // Hiển thị dialog xác nhận xóa
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Xác nhận'),
                      content: Text('Bạn có chắc chắn muốn xóa thông báo này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Get.back();
                            // Hiển thị snackbar
                            Get.snackbar(
                              'Thành công',
                              'Đã xóa thông báo',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: success,
                              colorText: Colors.white,
                              margin: EdgeInsets.all(16),
                            );
                          },
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
              child: ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: _viewModel.notificationData,
            builder: (context, notificationData, child) {
              Color accentColor;
              IconData iconData;

              switch (notificationData['type']) {
                case 'course':
                  accentColor = blackLight;
                  iconData = Icons.book;
                  break;
                case 'schedule':
                  accentColor = warning;
                  iconData = Icons.schedule;
                  break;
                case 'grade':
                  accentColor = Colors.purple;
                  iconData = Icons.grade;
                  break;
                case 'system':
                default:
                  accentColor = primary3;
                  iconData = Icons.notifications;
                  break;
              }

              return _buildBody(accentColor, iconData, notificationData);
            },
          )),
          backgroundColor: white,
        );
      },
    );
  }

  Widget _buildBody(Color accentColor, IconData iconData, Map<String, dynamic> notificationData) {
    String content = notificationData['content'] ?? notificationData['message'] ?? '';
    String dateString = notificationData['time'] ?? 'Vừa xong';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với thông tin cơ bản
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(10),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: accentColor,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notificationData['title'] ?? '',
                                  style: styleMediumBold.copyWith(color: black),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  dateString,
                                  style: styleVerySmall.copyWith(color: grey4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        notificationData['message'] ?? '',
                        style: styleSmallBold.copyWith(color: black),
                      ),
                    ],
                  ),
                ),

                // Nội dung chi tiết
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nội dung chi tiết',
                        style: styleSmallBold.copyWith(color: black),
                      ),
                      SizedBox(height: 12),
                      Text(
                        content,
                        style: styleSmall.copyWith(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      // Các action button
                      SizedBox(height: 32),
                      _buildActionButtons(accentColor, notificationData)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color accentColor, Map<String, dynamic> data) {
    // Tùy thuộc vào loại thông báo mà hiển thị các nút khác nhau
    List<Widget> buttons = [];

    switch (data['type']) {
      case 'course':
        buttons.add(
          _buildActionButton(
            'Xem bài tập',
            Icons.assignment,
            accentColor,
            () => Get.toNamed(Routers.courseDetail),
          ),
        );
        break;
      case 'schedule':
        // buttons.add(
        //   _buildActionButton('Xem lịch học', Icons.calendar_today, accentColor, () {
        //     if (Get.isRegistered<NavigationViewModel>()) {
        //       Get.back();
        //       Get.find<NavigationViewModel>().setIndex(2);
        //     }
        //   }),
        // );
        break;
      case 'grade':
        buttons.add(
          _buildActionButton(
            'Xem điểm số',
            Icons.assessment,
            accentColor,
            () {
              Get.toNamed(Routers.courseDetail);
            },
          ),
        );
        break;
      case 'system':
      default:
        buttons.add(
          _buildActionButton(
            'change_password'.tr,
            Icons.lock_outline,
            accentColor,
            () => Get.toNamed(Routers.changePassword),
          ),
        );
        buttons.add(SizedBox(width: 16));
        buttons.add(
          _buildActionButton(
            'support',
            Icons.headset_mic,
            grey3,
            () => Get.toNamed(Routers.support),
            outlined: true,
          ),
        );
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool outlined = false,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: outlined ? color : white,
          size: 18,
        ),
        label: Text(
          label,
          style: styleVerySmallBold.copyWith(
            color: outlined ? color : white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : color,
          foregroundColor: outlined ? color : white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: outlined ? BorderSide(color: color) : BorderSide.none,
          ),
          elevation: outlined ? 0 : 1,
        ),
      ),
    );
  }
}
