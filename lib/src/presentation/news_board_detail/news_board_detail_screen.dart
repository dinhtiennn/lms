import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';

class NewsBoardDetailScreen extends StatefulWidget {
  const NewsBoardDetailScreen({Key? key}) : super(key: key);

  @override
  State<NewsBoardDetailScreen> createState() => _NewsBoardDetailScreenState();
}

class _NewsBoardDetailScreenState extends State<NewsBoardDetailScreen> {
  late NewsBoardDetailViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NewsBoardDetailViewModel>(
        viewModel: NewsBoardDetailViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'notification_detail'.tr,
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: black.withAlpha((255 * 0.05).round()),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with notification icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary3.withAlpha((255 * 0.1).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: primary3,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông báo về việc nộp bổ sung hồ sơ xét trợ cấp xã hội tháng 01-6 năm 2025 cho sinh viên chính quy',
                            style: styleLargeBold.copyWith(color: blackLight),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: grey3,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '06/02/2025 09:15',
                                style: styleSmall.copyWith(color: grey2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32, thickness: 1, color: grey5),
                Text(
                  'Nhà trường thông báo đến sinh viên toàn trường được biết về việc nộp hồ sơ xét trợ cấp xã hội tháng 01-6 năm 2025 cụ thể theo link chi tiết đính kèm TB_96_ĐHKH',
                  style: styleMedium.copyWith(color: blackLight),
                ),
                SizedBox(height: 16),
                Text(
                  'Nhà trường thông báo đến sinh viên toàn trường được biết về việc nộp hồ sơ xét trợ cấp xã hội tháng 01-6 năm 2025 cụ thể theo link chi tiết đính kèm TB_96_ĐHKH Nhà trường thông báo đến sinh viên toàn trường được biết về việc nộp hồ sơ xét trợ cấp xã hội tháng 01-6 năm 2025 cụ thể theo link chi tiết đính kèm TB_96_ĐHKH Nhà trường thông báo đến sinh viên toàn trường được biết về việc nộp hồ sơ xét trợ cấp xã hội tháng 01-6 năm 2025 cụ thể theo link chi tiết đính kèm TB_96_ĐHKH',
                  style: styleMedium.copyWith(color: blackLight),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TB_96_ĐHKH.pdf',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '245 KB',
                              style: styleVerySmall.copyWith(color: grey3),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.download,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
