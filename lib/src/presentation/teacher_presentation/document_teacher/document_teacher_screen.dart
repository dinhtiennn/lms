import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:intl/intl.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_valid.dart';

class DocumentTeacherScreen extends StatefulWidget {
  const DocumentTeacherScreen({Key? key}) : super(key: key);

  @override
  State<DocumentTeacherScreen> createState() => _DocumentTeacherScreenState();
}

class _DocumentTeacherScreenState extends State<DocumentTeacherScreen> {
  late DocumentTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<DocumentTeacherViewModel>(
        viewModel: DocumentTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Tài liệu',
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      _viewModel.initBottomSheet();
                      showCreateDocumentBottomSheet(context);
                    },
                    icon: Icon(Icons.add_rounded))
              ],
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
                'Tài liệu của tôi',
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
              valueListenable: _viewModel.myDocuments,
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
                              'Bạn chưa có tài liệu nào',
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
        trailing: Icon(document.status == 'PUBLIC' ? Icons.public : Icons.lock,color: document.status == 'PUBLIC' ? Colors.green : Colors.orange,),
        onTap: () {
          Get.toNamed(Routers.documentDetailTeacher, arguments: {'document' : document});
        },
      ),
    );
  }

  void showCreateDocumentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary2,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const Text(
                      'Tạo tài liệu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16)
                    .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
                child: Form(
                  key: _viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Tên khóa học
                      WidgetInput(
                        controller: _viewModel.documentNameController,
                        titleText: 'Tên tài liệu',
                        style: styleSmall.copyWith(color: grey2),
                        titleStyle: styleSmall.copyWith(color: grey2),
                        borderRadius: BorderRadius.circular(12),
                        hintText: 'Tên tài liệu',
                        hintStyle: styleSmall.copyWith(color: grey4),
                        validator: AppValid.validateRequireEnter(
                            titleValid: 'Vui lòng nhập tên tài liệu'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Mô tả khóa học
                      WidgetInput(
                        controller: _viewModel.documentDescriptionController,
                        titleText: 'Mô tả',
                        style: styleSmall.copyWith(color: grey2),
                        titleStyle: styleSmall.copyWith(color: grey2),
                        borderRadius: BorderRadius.circular(12),
                        hintText: 'Nhập mô tả ',
                        hintStyle: styleSmall.copyWith(color: grey4),
                        maxLines: 5,
                        validator: AppValid.validateRequireEnter(
                            titleValid: 'Vui lòng nhập mô tả'),
                      ),
                      const SizedBox(height: 16),

                      // Chọn ngành học
                      ValueListenableBuilder<List<MajorModel>?>(
                        valueListenable: _viewModel.majors,
                        builder: (context, majors, child) {
                          if (majors == null) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text(
                                  'Ngành học',
                                  style: styleSmall.copyWith(color: grey2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () =>
                                    showMajorBottomSheet(context, majors),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: grey5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child:
                                            ValueListenableBuilder<MajorModel?>(
                                          valueListenable:
                                              _viewModel.majorSelected,
                                          builder: (context, major, child) =>
                                              Text(
                                            (major != null &&
                                                    major.name != null)
                                                ? major.name!
                                                : 'Vui lòng chọn ngành học',
                                            style: styleSmall.copyWith(
                                              color:
                                                  major != null ? grey2 : grey4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: grey2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Trạng thái khóa học
                      ValueListenableBuilder<StatusOption?>(
                        valueListenable: _viewModel.statusSelected,
                        builder: (context, selectedStatus, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text(
                                  'Trạng thái khóa học',
                                  style: styleSmall.copyWith(color: grey2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => showStatusBottomSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: grey5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedStatus?.label ??
                                              'Vui lòng chọn trạng thái',
                                          style: styleSmall.copyWith(
                                            color: selectedStatus != null
                                                ? grey2
                                                : grey4,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: grey2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text('Tệp đính kèm',
                          style: styleMediumBold.copyWith(color: grey3)),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<File?>(
                        valueListenable: _viewModel.filePicker,
                        builder: (context, file, child) {
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<String?>(
                                      valueListenable: _viewModel.fileName,
                                      builder: (context, fileName, _) {
                                        return Expanded(
                                          child: Text(
                                            fileName ??
                                                'Chưa có file nào được chọn',
                                            style: styleSmall.copyWith(
                                              color: fileName != null
                                                  ? grey2
                                                  : grey4,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        _viewModel.selectFile();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Chọn file',
                                        style:
                                            styleSmall.copyWith(color: white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lưu ý: Chỉ chấp nhận file PDF (.pdf) hoặc Word (.doc, .docx)',
                                style: styleVerySmall.copyWith(
                                    color: Colors.orange),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Nút lưu
                      SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _viewModel.isLoading,
                          builder: (context, isLoading, _) {
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_viewModel.formKey.currentState!
                                          .validate()) {
                                        _viewModel.createDocument();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary2,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Lưu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMajorBottomSheet(
    BuildContext context,
    List<MajorModel> majors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16)
            .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Chọn ngành học',
                      style: styleMedium.copyWith(color: grey2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: majors.length,
                itemBuilder: (context, index) {
                  final major = majors[index];
                  return ListTile(
                    title: Text(
                      major.name ?? '',
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () {
                      _viewModel.setMajor(major);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: white,
      useSafeArea: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16)
            .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Chọn trạng thái khóa học',
                      style: styleMedium.copyWith(color: grey2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _viewModel.statusOptions.length,
                itemBuilder: (context, index) {
                  final status = _viewModel.statusOptions[index];
                  return ListTile(
                    title: Text(
                      status.label,
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () {
                      _viewModel.statusSelected.value = status;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
