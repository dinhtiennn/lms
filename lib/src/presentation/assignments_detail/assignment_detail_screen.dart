import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  late AssignmentDetailViewmodel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<AssignmentDetailViewmodel>(
      viewModel: AssignmentDetailViewmodel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primary2,
            title: Text(
              'upcoming_assignments'.tr,
              style: styleLargeBold.copyWith(color: white),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(child: _buildBody()),
          backgroundColor: grey5,
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: primary2,
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: white.withAlpha((255 * 0.2).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nộp bài thi học kỳ',
                            style: styleLargeBold.copyWith(color: white),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: white.withAlpha((255 * 0.2).round()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '100 ${'score'.tr}',
                              style: styleVerySmall.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: white.withAlpha((255 * 0.8).round()),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${'due_date'.tr}: 13:15, 31 thg 2, 2023',
                      style: styleSmall.copyWith(color: white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Phần thân bài
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: black.withAlpha((255 * 0.05).round()),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tệp đính kèm
                _buildSectionTitle('attached_file'.tr, Icons.attachment),
                SizedBox(height: 12),
                _buildImprovedAttachedFile('Dethi.pdf', isPrimary: true),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 16),

                // Phần bài tập của bạn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('your_exercise'.tr, Icons.assignment_turned_in),
                    _buildAddButton(),
                  ],
                ),
                SizedBox(height: 12),
                _buildImprovedAttachedFile('BaiLam_NguyenVanA.docx'),
                SizedBox(height: 12),
                _buildImprovedAttachedFile('BaiLam_NguyenVanA.pdf'),
                SizedBox(height: 12),
                _buildImprovedAttachedFile('BaiLam_NguyenVanA.pptx'),
                SizedBox(height: 12),
                _buildImprovedAttachedFile('BaiLam_NguyenVanA.jpg'),
              ],
            ),
          ),

          // Nút nộp bài
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: primary2,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: styleMediumBold.copyWith(color: blackLight),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: grey5,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: grey5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: primary2,
            ),
            SizedBox(width: 4),
            Text(
              'add_exercise'.tr,
              style: styleSmall.copyWith(color: primary2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovedAttachedFile(String fileName, {bool isPrimary = false}) {
    // Xác định loại file dựa trên phần mở rộng
    IconData fileIcon;
    Color fileColor;

    if (fileName.endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
      fileColor = error;
    } else if (fileName.endsWith('.docx') || fileName.endsWith('.doc')) {
      fileIcon = Icons.article;
      fileColor = primary3;
    } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
      fileIcon = Icons.table_chart;
      fileColor = success;
    } else if (fileName.endsWith('.pptx') || fileName.endsWith('.ppt')) {
      fileIcon = Icons.slideshow;
      fileColor = warning;
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png') || fileName.endsWith('.jpeg')) {
      fileIcon = Icons.image;
      fileColor = Colors.purple[700]!;
    } else {
      fileIcon = Icons.insert_drive_file;
      fileColor = Colors.grey[700]!;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Xem hoặc tải file
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: fileColor.withAlpha((255 * 0.2).round()),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  fileIcon,
                  color: fileColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: styleMedium.copyWith(color: black),
                    ),
                  ],
                ),
              ),
              isPrimary
                  ? IconButton(
                      icon: Icon(
                        Icons.download,
                        color: primary2,
                      ),
                      onPressed: () {
                        // Tải file
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                      ),
                      onPressed: () {
                        // Xóa file
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        print('submit exercise');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primary2,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'submit_exercise'.tr,
            style: styleMediumBold.copyWith(color: white),
          ),
        ],
      ),
    );
  }
}
