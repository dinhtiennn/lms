import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({Key? key}) : super(key: key);

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  late NotificationDetailViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NotificationDetailViewModel>(
      viewModel: NotificationDetailViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primary2,
            elevation: 0,
            title: Text(
              'Chi tiết thông báo',
              style: styleLargeBold.copyWith(color: white),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: _buildNotificationContent(),
          ),
          backgroundColor: white,
        );
      },
    );
  }

  Widget _buildNotificationContent() {
    return ValueListenableBuilder<NotificationModel?>(
      valueListenable: _viewModel.notificationData,
      builder: (context, notification, _) {
        if (notification == null) {
          return Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<IconData>(
          valueListenable: _viewModel.notificationIcon,
          builder: (context, iconData, _) {
            return ValueListenableBuilder<Color>(
              valueListenable: _viewModel.notificationColor,
              builder: (context, accentColor, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _viewModel.notificationTitle,
                  builder: (context, title, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _viewModel.notificationDesc,
                      builder: (context, description, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _viewModel.notificationTime,
                          builder: (context, time, _) {
                            return ValueListenableBuilder<List<ActionButton>>(
                              valueListenable: _viewModel.actionButtons,
                              builder: (context, actions, _) {
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
                                                              title,
                                                              style: styleMediumBold.copyWith(color: black),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              time,
                                                              style: styleVerySmall.copyWith(color: grey4),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
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
                                                    description,
                                                    style: styleSmall.copyWith(
                                                      color: Colors.black87,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
