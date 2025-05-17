import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/document_model.dart';

class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({Key? key}) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late DocumentDetailViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<DocumentDetailViewModel>(
        viewModel: DocumentDetailViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Chi tiết tài liệu',
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
    return ValueListenableBuilder(
      valueListenable: _viewModel.document,
      builder: (context, document, child) {
        if (document == null) {
          return Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Title
              Center(
                child: Text(
                  document.title ?? 'Không có tiêu đề',
                  style: styleLargeBold.copyWith(color: primary2),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Status and Date Info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Status
                    Row(
                      children: [
                        Icon(
                          document.status == 'PUBLIC' ? Icons.public : Icons.lock,
                          color: document.status == 'PUBLIC' ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Trạng thái: ${document.status == 'PUBLIC' ? 'Công khai' : 'Riêng tư'}',
                          style: styleMediumBold.copyWith(color: grey3),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Date Created
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Ngày tạo: ${document.createdAt != null ? DateFormat('dd/MM/yyyy').format(document.createdAt!) : 'N/A'}',
                          style: styleSmall.copyWith(color: grey3),
                        ),
                      ],
                    ),

                    // Major (if available)
                    if (document.major != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.school, color: primary3),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ngành: ${document.major?.name ?? 'N/A'}',
                              style: styleSmall.copyWith(color: grey3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Description
              Text(
                'Mô tả:',
                style: styleMediumBold.copyWith(color: grey3),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  document.description ?? 'Không có mô tả',
                  style: styleSmall.copyWith(color: grey3),
                ),
              ),
              SizedBox(height: 20),

              // File Information
              if (document.fileName != null) ...[
                Text(
                  'Tệp đính kèm:',
                  style: styleMediumBold.copyWith(color: grey3),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(document.fileName ?? ''),
                        color: primary,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.fileName ?? 'Unknown file',
                              style: styleSmallBold.copyWith(color: grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: primary),
                        onPressed: () => _viewModel.downloadFile(),
                        tooltip: 'Tải xuống',
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
