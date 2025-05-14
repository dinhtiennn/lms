import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lms/src/configs/constanst/constants.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_clients.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';

class GroupDetailTeacherScreen extends StatefulWidget {
  const GroupDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailTeacherScreen> createState() => _GroupDetailTeacherScreenState();
}

class _GroupDetailTeacherScreenState extends State<GroupDetailTeacherScreen> {
  late GroupDetailTeacherViewModel _viewModel;
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<GroupDetailTeacherViewModel>(
        viewModel: GroupDetailTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _viewModel.group.value?.name ?? '',
                style: styleLargeBold.copyWith(color: white),
              ),
              backgroundColor: primary2,
              actions: [
                IconButton(
                    onPressed: _showBottomSheetMenu,
                    icon: Icon(
                      Icons.add,
                      color: white,
                      size: 30,
                    ))
              ],
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: white,
              type: BottomNavigationBarType.fixed,
              unselectedLabelStyle: styleVerySmall,
              selectedLabelStyle: styleVerySmall,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.forum),
                  label: 'Bảng tin',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.quiz),
                  label: 'Bài kiểm tra',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Mọi người',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: grey3,
              onTap: _onItemTapped,
            ),
          );
        });
  }

  Widget _buildBody() {

    _widgetOptions = [
      listPost(),
      listTest(),
      listPerson(),
    ];

    return _widgetOptions.elementAt(_selectedIndex);
  }

  void _showBottomSheetCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: grey5,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Tạo bài đăng mới', style: styleLargeBold.copyWith(color: primary2)),
                  const SizedBox(height: 16),
                  WidgetInput(
                      controller: _viewModel.descriptionPost,
                      titleText: 'Nội dung',
                      borderRadius: BorderRadius.circular(12),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      style: styleSmall.copyWith(color: grey2),
                      maxLines: 5,
                      validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập nội dung')),
                  const SizedBox(height: 16),
                  Text('Tệp đính kèm', style: styleMediumBold.copyWith(color: grey3)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<File>>(
                    valueListenable: _viewModel.filesPicker,
                    builder: (context, files, child) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...files.map((file) => Chip(
                                backgroundColor: grey5,
                                label: Text(
                                  file.path.split('/').last,
                                  style: styleVerySmall.copyWith(color: grey2),
                                ),
                                onDeleted: () => _viewModel.removeFile(file),
                                side: BorderSide.none,
                              )),
                          ActionChip(
                            avatar: const Icon(Icons.attach_file),
                            label: Text('Chọn tệp', style: styleVerySmall.copyWith(color: white)),
                            side: BorderSide.none,
                            onPressed: _viewModel.pickFiles,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: grey3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Đóng', style: styleMediumBold.copyWith(color: grey3)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_viewModel.formKey.currentState?.validate() ?? false) {
                              _viewModel.createPost(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Đăng bài', style: styleMediumBold.copyWith(color: white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: grey5,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.post_add, color: primary2),
                title: Text(
                  'Thêm bài đăng',
                  style: styleMedium.copyWith(color: grey2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showBottomSheetCreatePost();
                },
              ),
              ListTile(
                leading: Icon(Icons.quiz, color: primary2),
                title: Text(
                  'Thêm bài kiểm tra',
                  style: styleMedium.copyWith(color: grey2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.createTest();
                },
              ),
              ListTile(
                leading: Icon(Icons.person_add, color: primary2),
                title: Text(
                  'Thêm sinh viên',
                  style: styleMedium.copyWith(color: grey2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showAddStudentBottomSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget listPost() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedIndex == 0) {
          _viewModel.refreshPost();
        }
      },
      child: ValueListenableBuilder<List<PostModel>?>(
        valueListenable: _viewModel.posts,
        builder: (context, postsList, child) {
          if (postsList == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postsList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: Get.height - 200,
                  child: Center(
                    child: Text(
                      'Chưa có bài đăng nào!',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _viewModel.postScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: postsList.length + (_viewModel.isLoadingPost && _viewModel.hasMorePost ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == postsList.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: primary,
                      size: 50,
                    ),
                  )),
                );
              }
              final post = postsList[index];
              return _buildItemPost(context: context, post: post);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemPost({required BuildContext context, required PostModel post}) {
    return Card(
      color: white,
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all(color: grey5), borderRadius: BorderRadius.circular(100)),
                  child: WidgetImageNetwork(
                    url: _viewModel.teacher?.avatar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    radiusAll: 100,
                    widgetError: Center(
                      child: Text(
                        (_viewModel.teacher?.fullName?.isNotEmpty ?? false)
                            ? (_viewModel.teacher?.fullName![0] ?? '').toUpperCase()
                            : "?",
                        style: styleMediumBold.copyWith(color: primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _viewModel.teacher?.fullName ?? '',
                        style: styleMediumBold.copyWith(color: black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.createdAt?.day}/${post.createdAt?.month}/${post.createdAt?.year} ${post.createdAt?.hour}:${post.createdAt?.minute}:${post.createdAt?.second}',
                        style: styleVerySmall.copyWith(color: grey3),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => WidgetDialogConfirm(
                      titleStyle: styleMediumBold.copyWith(color: error),
                      colorButtonAccept: error,
                      title: 'Xóa bài đăng',
                      onTapConfirm: () {
                        _viewModel.delete(post.id ?? '');
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      content: 'Xác nhận xóa bài ${post.title}?',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.text ?? '',
              style: styleSmall.copyWith(color: grey2),
            ),
            if (post.files?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.files!.map((file) {
                  return InkWell(
                    onTap: () {
                      _downloadFile(file.fileUrl ?? '', context);
                    },
                    child: Chip(
                      backgroundColor: grey5,
                      avatar: Icon(
                        Icons.download,
                        color: primary,
                      ),
                      label: Text(
                        file.fileName ?? '',
                        style: styleVerySmall.copyWith(color: grey2),
                      ),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text('Bình luận'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: white,
              title: Text(
                'Cần quyền truy cập',
                style: styleSmallBold.copyWith(color: grey3),
              ),
              content: Text(
                'Cần cấp quyền lưu trữ để tải xuống file. Vui lòng cấp quyền trong cài đặt của ứng dụng.',
                style: styleSmall.copyWith(color: grey3),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: styleSmall.copyWith(color: grey3),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mở cài đặt'),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }

    return true;
  }

  Future<void> _downloadFile(String url, BuildContext context) async {
    if (!context.mounted) return;

    try {
      final fileName = url.split('/').last;
      if (fileName.isEmpty) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
          showIcon: true,
          applyBlurEffect: true,
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text('Không thể xác định tên file'),
          type: ToastificationType.error,
        );
        return;
      }

      // Kiểm tra quyền lưu trữ trên thiết bị
      final hasPermission = await _requestStoragePermission(context);
      if (!hasPermission) {
        return;
      }

      late final String savePath;
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            showIcon: true,
            applyBlurEffect: true,
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
            style: ToastificationStyle.fillColored,
            context: context,
            title: const Text('Không thể truy cập bộ nhớ thiết bị'),
            type: ToastificationType.error,
          );
          return;
        }
        savePath = '${directory.path}/Downloads/$fileName';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: MyLoading()),
        );
      }

      final response = await AppClients().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Tải xuống: $progress%');
          }
        },
      );

      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            showIcon: true,
            applyBlurEffect: true,
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
            style: ToastificationStyle.fillColored,
            context: context,
            title: const Text('Tải xuống file thành công'),
            type: ToastificationType.success,
          );
        }
      } else {
        if (context.mounted) {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            showIcon: true,
            applyBlurEffect: true,
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
            style: ToastificationStyle.fillColored,
            context: context,
            title: Text('Lỗi ${response.statusCode}: Không thể tải xuống file'),
            type: ToastificationType.error,
          );
        }
      }
    } catch (e) {
      // Hide loading dialog if it's still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
          showIcon: true,
          applyBlurEffect: true,
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text('Đã xảy ra lỗi khi tải xuống. Vui lòng thử lại sau!'),
          type: ToastificationType.error,
        );
      }
      debugPrint('Download error: $e');
    }
  }

  Widget listTest() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedIndex == 1) {
          _viewModel.refreshTest();
        }
      },
      child: ValueListenableBuilder<List<TestModel>?>(
        valueListenable: _viewModel.tests,
        builder: (context, testsList, child) {
          if (testsList == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (testsList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: Get.height - 200,
                  child: Center(
                    child: Text(
                      'Chưa có bài kiểm tra nào!',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _viewModel.testScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: testsList.length + (_viewModel.isLoadingTest && _viewModel.hasMoreTest ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == testsList.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final test = testsList[index];
              return _buildItemTest(context: context, test: test);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemTest({required BuildContext context, required TestModel test}) {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _viewModel.testDetail(test);
        },
        child: Card(
          color: white,
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  test.title ?? '',
                  style: styleMediumBold.copyWith(color: grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ngày tạo: ${test.createdAt?.day ?? ''}/${test.createdAt?.month ?? ''}/${test.createdAt?.year ?? ''} ${test.createdAt?.hour ?? ''}:${test.createdAt?.minute ?? ''}',
                  style: styleVerySmall.copyWith(color: grey3),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Ngày bắt đầu: ${test.startedAt?.day ?? ''}/${test.startedAt?.month ?? ''}/${test.startedAt?.year ?? ''} ${test.startedAt?.hour ?? ''}:${test.startedAt?.minute ?? ''}',
                                  style: styleVerySmall.copyWith(color: grey3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Ngày hết hạn: ${test.expiredAt?.day ?? ''}/${test.expiredAt?.month ?? ''}/${test.expiredAt?.year ?? ''} ${test.expiredAt?.hour ?? ''}:${test.expiredAt?.minute ?? ''}',
                                  style: styleVerySmall.copyWith(color: grey3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  test.description ?? '',
                  style: styleSmall.copyWith(color: grey2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listPerson() {
    return RefreshIndicator(
      onRefresh: () async {
        await _viewModel.refreshStudent();
      },
      child: ValueListenableBuilder(
        valueListenable: _viewModel.students,
        builder: (context, students, child) {
          if (students == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _viewModel.studentScrollController,
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildSectionHeader(teacher: _viewModel.teacher),

              if (students.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: Text(
                      'Không có sinh viên nào!',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  ),
                )
              else
                ...students.map((student) => _buildPersonItem(student: student)).toList(),

              // Hiển thị indicator khi đang tải thêm
              if (_viewModel.isLoadingStudent && _viewModel.hasMoreStudent && students.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({TeacherModel? teacher}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giảng viên',
            style: styleMediumBold.copyWith(color: primary2),
          ),
          const SizedBox(height: 8),
          Card(
            color: white,
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                child: WidgetImageNetwork(
                  url: teacher?.avatar,
                  width: 40,
                  height: 40,
                  radiusAll: 100,
                  widgetError: Center(
                    child: Text(
                      (teacher?.fullName?.isNotEmpty ?? false) ? teacher!.fullName![0].toUpperCase() : "?",
                      style: styleMediumBold.copyWith(color: primary),
                    ),
                  ),
                ),
              ),
              title: Text(
                teacher?.fullName ?? '',
                style: styleMedium.copyWith(color: primary3),
              ),
              subtitle: Text('Giảng viên', style: styleSmall.copyWith(color: grey3)),
              trailing: const Icon(Icons.star, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sinh viên',
            style: styleMediumBold.copyWith(color: primary2),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonItem({StudentModel? student}) {
    if (student == null) return const SizedBox();

    return Card(
      color: white,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: WidgetImageNetwork(
            url: student.avatar,
            width: 40,
            height: 40,
            radiusAll: 100,
            widgetError: Center(
              child: Text(
                (student.fullName?.isNotEmpty ?? false) ? student.fullName![0].toUpperCase() : "?",
                style: styleMediumBold.copyWith(color: primary),
              ),
            ),
          ),
        ),
        title: Text(
          student.fullName ?? '',
          style: styleMedium.copyWith(color: primary3),
        ),
        subtitle: Text('Sinh viên', style: styleSmall.copyWith(color: grey3)),
        trailing: IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => WidgetDialogConfirm(
                titleStyle:
                styleMediumBold.copyWith(color: error),
                colorButtonAccept: error,
                title: 'Xóa sinh viên',
                onTapConfirm: () {
                  _viewModel.removeStudent(
                      studentId: student.id,
                      context: context);
                },
                content:
                'Xác nhận xóa sinh viên ${student.fullName} khỏi nhóm?',
              ),
            ),
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
            )),
      ),
    );
  }

  void showAddStudentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: 0.7,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const Text(
                      'Thêm sinh viên',
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
                      _viewModel.cleanListStudentSearch();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Hiển thị các chip sinh viên đã chọn
            ValueListenableBuilder<List<StudentModel>>(
              valueListenable: _viewModel.selectedStudents,
              builder: (context, selected, child) {
                if (selected.isEmpty) return SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(16).copyWith(bottom: 0),
                  child: Wrap(
                    children: selected
                        .map((student) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(student.fullName ?? ''),
                                onDeleted: () => _viewModel.removeSelectedStudent(student),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: WidgetInput(
                controller: _viewModel.keywordController,
                hintText: 'Nhập tên hoặc email sinh viên...',
                prefix: Icon(Icons.search, color: grey2),
                borderRadius: BorderRadius.circular(12),
                onChanged: (value) {
                  _viewModel.searchStudentNotInGroup(keyword: value);
                },
                widthPrefix: 40,
                style: styleSmall.copyWith(color: grey2),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<StudentModel>?>(
                valueListenable: _viewModel.studentsSearch,
                builder: (context, students, child) {
                  if (students == null) {
                    return Center(
                      child: Text(
                        'Nhập tên hoặc email để tìm kiếm sinh viên',
                        style: styleMedium.copyWith(color: grey3),
                      ),
                    );
                  }

                  if (students.isEmpty) {
                    return Center(
                      child: Text(
                        'Không tìm thấy sinh viên nào',
                        style: styleMedium.copyWith(color: grey3),
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<StudentModel>?>(
                    valueListenable: _viewModel.selectedStudents,
                    builder: (context, listStudentSelected, child) => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final isSelected = listStudentSelected?.any((s) => s.id == student.id);
                        return Card(
                          color: white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: WidgetImageNetwork(
                              width: 40,
                              height: 40,
                              radiusAll: 100,
                              url: student.avatar ?? '',
                              widgetError: CircleAvatar(
                                backgroundColor: primary2,
                                child: Text(
                                  'SV',
                                  style: styleSmall.copyWith(color: white),
                                ),
                              ),
                            ),
                            title: Text(
                              student.fullName ?? '',
                              style: styleSmallBold.copyWith(color: black),
                            ),
                            subtitle: Text(
                              student.email ?? '',
                              style: styleSmall.copyWith(color: grey2),
                            ),
                            trailing: isSelected ?? false
                                ? Icon(Icons.check, color: successLight)
                                : ElevatedButton(
                                    onPressed: () {
                                      _viewModel.addSelectedStudent(student);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Thêm'),
                                  ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Nút thêm vào lớp
            ValueListenableBuilder<List<StudentModel>>(
              valueListenable: _viewModel.selectedStudents,
              builder: (context, selected, child) {
                return Padding(
                  padding: EdgeInsets.all(20).copyWith(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selected.isEmpty) {
                          return;
                        }
                        _viewModel.cleanListStudentSearch();
                        _viewModel.cleanStudentsSelected();
                        _viewModel.addAllStudentToGroup(context, selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected.isEmpty ? Colors.grey.shade300 : primary2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Thêm vào lớp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
