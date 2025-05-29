import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/presentation/presentation.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late DocumentViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<DocumentViewModel>(
        viewModel: DocumentViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Tài liệu học tập',
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
    return Column(
      children: [
        // Phần tìm kiếm
        Padding(
          padding: EdgeInsets.all(16.0),
          child: WidgetInput(
            controller: _viewModel.keyword,
            hintText: 'Tìm kiếm tài liệu...',
            hintStyle: styleSmall.copyWith(color: grey4),
            style: styleSmall.copyWith(color: grey2),
            prefix: const Icon(
              Icons.search,
              color: grey3,
              size: 20,
            ),
            widthPrefix: 40,
            borderRadius: BorderRadius.circular(50),
            onChanged: (value) {
              _viewModel.refresh();
            },
          ),
        ),

        // Phần tiêu đề tài liệu mới
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tài liệu học tập',
                style: styleMediumBold.copyWith(color: grey3),
              ),
            ],
          ),
        ),

        // Danh sách tài liệu
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _viewModel.refresh(),
            child: ValueListenableBuilder<List<DocumentModel>?>(
              valueListenable: _viewModel.documents,
              builder: (context, documents, child) {
                if (documents == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (documents.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 70,
                              color: grey4,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có tài liệu nào!',
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
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length + 1, // +1 cho indicator loading
                  itemBuilder: (context, index) {
                    if (index == documents.length) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _viewModel.isLoadingMore,
                        builder: (context, isLoading, _) {
                          return isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox.shrink();
                        },
                      );
                    }

                    final document = documents[index];
                    return _buildDocumentItem(document);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(DocumentModel document) {
    // Xác định icon dựa trên loại file
    IconData iconData = Icons.insert_drive_file;
    if (document.path != null) {
      final fileExtension = document.path!.split('.').last.toLowerCase();
      if (fileExtension == 'pdf') {
        iconData = Icons.picture_as_pdf;
      } else if (['doc', 'docx'].contains(fileExtension)) {
        iconData = Icons.description;
      }
    }

    // Format thời gian
    String formattedDate = '';
    if (document.createdAt != null) {
      formattedDate = DateFormat('dd/MM/yyyy').format(document.createdAt!);
    }

    return Card(
      color: white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primary2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            iconData,
            color: white,
            size: 30,
          ),
        ),
        title: Text(
          document.title ?? 'Không có tiêu đề',
          style: styleSmallBold.copyWith(color: black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              document.description ?? 'Không có mô tả',
              style: styleVerySmall.copyWith(color: black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: grey3),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: styleVerySmall.copyWith(color: grey3, fontSize: 10),
                ),
                const SizedBox(width: 8),
                Icon(Icons.person, size: 12, color: grey3),
                const SizedBox(width: 4),
                Text(
                  document.teacherModel?.fullName ?? 'Giảng viên',
                  style: styleVerySmall.copyWith(fontSize: 10, color: grey3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          document.status == 'PUBLIC' ? Icons.public : Icons.lock,
          color: document.status == 'PUBLIC' ? Colors.green : Colors.orange,
        ),
        onTap: () {
          Get.toNamed(Routers.documentDetail,
              arguments: {'document': document});
        },
      ),
    );
  }
}
