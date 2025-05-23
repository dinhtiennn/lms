import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/constanst/constants.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/presentation/student_presentation/group_detail/widget/post_comment.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupDetailViewModel _viewModel;

  int _selectedIndex = 0;
  late List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<GroupDetailViewModel>(
        viewModel: GroupDetailViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: ValueListenableBuilder(
                valueListenable: _viewModel.group,
                builder: (context, group, child) => Text(
                  group?.name ?? 'N/A',
                  style: styleLargeBold.copyWith(color: grey3),
                ),
              ),
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
    ;
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
              return ValueListenableBuilder(
                valueListenable: _viewModel.group,
                builder: (context, group, child) =>
                    _buildItemPost(context: context, post: post, teacher: group?.teacher),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItemPost({required BuildContext context, required PostModel post, TeacherModel? teacher}) {
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
                    url: teacher?.avatar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    radiusAll: 100,
                    widgetError: Center(
                      child: Text(
                        (teacher?.fullName?.isNotEmpty ?? false) ? (teacher?.fullName![0] ?? '').toUpperCase() : "?",
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
                        teacher?.fullName ?? '',
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text('Bình luận'),
                  onPressed: () {
                    // Lưu bài đăng hiện tại vào postSelected
                    _viewModel.setPost(post);
                    // Tải comments của bài đăng này
                    _viewModel.loadComments(isReset: true, pageSize: 20);
                    // Hiển thị bottom sheet comment
                    _showCommentBottomSheet(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              AppUtils.isExpired(test.expiredAt) ? const SizedBox(height: 8) : const SizedBox(),
              AppUtils.isExpired(test.expiredAt)
                  ? Text(
                      '(Đã hết hạn)',
                      style: styleVerySmallBold.copyWith(color: error),
                    )
                  : const SizedBox(),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'Ngày bắt đầu: ${test.startedAt?.day ?? ''}/${test.startedAt?.month ?? ''}/${test.startedAt?.year ?? ''} ${test.startedAt?.hour ?? ''}:${test.startedAt?.minute ?? ''}',
                                style: styleVerySmall.copyWith(
                                    color: AppUtils.isExpired(test.startedAt) ? success : grey3),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Ngày hết hạn: ${test.expiredAt?.day ?? ''}/${test.expiredAt?.month ?? ''}/${test.expiredAt?.year ?? ''} ${test.expiredAt?.hour ?? ''}:${test.expiredAt?.minute ?? ''}',
                                style: styleVerySmall.copyWith(
                                    color: AppUtils.isExpired(test.expiredAt) ? error : success),
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
              const SizedBox(height: 16),
              test.isSuccess == null
                  ? SizedBox()
                  : test.isSuccess == true
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _viewModel.startResult(test);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: success,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Xem kết quả ',
                              style: styleMediumBold.copyWith(
                                color: white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: AppUtils.isExpired(test.expiredAt)
                              ? SizedBox()
                              : ElevatedButton(
                                  onPressed: () {
                                    _viewModel.startTest(test);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        !AppUtils.isExpired(test.expiredAt) && AppUtils.isExpired(test.startedAt)
                                            ? primary2
                                            : AppUtils.isExpired(test.expiredAt)
                                                ? grey4
                                                : grey5,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    !AppUtils.isExpired(test.startedAt) ? 'Chưa đến thời gian' : 'Bắt đầu làm bài',
                                    style: styleMediumBold.copyWith(
                                      color: !AppUtils.isExpired(test.expiredAt) && AppUtils.isExpired(test.startedAt)
                                          ? white
                                          : grey2,
                                    ),
                                  ),
                                ),
                        ),
            ],
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
              ValueListenableBuilder(
                valueListenable: _viewModel.group,
                builder: (context, group, child) => _buildSectionHeader(teacher: group?.teacher),
              ),

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

      String savePath;
      if (Platform.isAndroid) {
        final downloadPath = await AndroidPathProvider.downloadsPath;
        savePath = '$downloadPath/$fileName';
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

  void _showCommentBottomSheet(BuildContext context) {
    // Lấy bài đăng hiện tại từ postSelected
    PostModel? currentPost = _viewModel.postSelected.value;

    if (currentPost == null) {
      return; // Không mở bottom sheet nếu không có bài đăng nào được chọn
    }

    Widget commentWidget = PostComment(
      comments: _viewModel.comments,
      commentSelected: _viewModel.commentSelected,
      commentController: _viewModel.commentController,
      onSendComment: ({CommentModel? comment}) async {
        if (context.mounted) {
          // Gửi comment hoặc reply
          await _viewModel.send(comment: comment);
        }
      },
      setCommentSelected: _viewModel.setCommentSelected,
      onLoadMoreComments: ({required PostModel post, int pageSize = 20, int pageNumber = 0}) {
        _viewModel.loadComments(isReset: pageNumber == 0, pageSize: pageSize);
      },
      currentPost: currentPost,
      animatedCommentId: _viewModel.animatedCommentId,
      animatedReplyId: _viewModel.animatedReplyId,
      avatarUrl: _viewModel.student?.avatar,
      onLoadMoreReplies: _viewModel.loadMoreReplies,
      onEditComment: _viewModel.editComment,
      onEditReply: _viewModel.editReply,
      onDispose: _viewModel.resetCommentState,
      userEmail: _viewModel.student?.email,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      scrollControlDisabledMaxHeightRatio: 0.6,
      backgroundColor: Colors.white,
      useSafeArea: true,
      builder: (context) {
        return commentWidget;
      },
    );
  }
}
