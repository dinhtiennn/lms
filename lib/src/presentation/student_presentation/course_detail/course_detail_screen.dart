import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late CourseDetailViewModel _viewModel;
  MediaQueryData? _mediaQuery;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseDetailViewModel>(
      viewModel: CourseDetailViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: white,
              )),
          title: Text(
            _viewModel.course?.name ?? '',
            style: styleLargeBold.copyWith(color: white),
          ),
          backgroundColor: primary2,
          actions: [
            ValueListenableBuilder(
              valueListenable: _viewModel.currentContent,
              builder: (context, content, child) {
                if (content is ChapterContent) {
                  return IconButton(
                    icon:
                        Icon(Icons.chat_bubble_outline, color: white, size: 20),
                    onPressed: () {
                      _showCommentBottomSheet(context);
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.play_lesson_outlined, color: white, size: 20),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
            Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.info_outline, color: white, size: 20),
                    onPressed: _viewModel.courseReview)),
          ],
        ),
        endDrawer: CourseDrawer(
          course: _viewModel.course,
          courseDetail: _viewModel.courseDetail,
          logger: _viewModel.logger,
          onChapterSelected: _viewModel.setChapterContent,
          onMaterialSelected: _viewModel.setMaterialContent,
          onQuizSelected: _viewModel.setQuizContent,
          currentContent: _viewModel.currentContent,
          lessonCurrent: _viewModel.lessonCurrent,
          tapToInfo: () {
            _viewModel.courseReview();
          },
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
        backgroundColor: white,
      ),
    );
  }

  Widget _buildBody() {
    final mediaQuery = _mediaQuery ?? MediaQuery.of(context);
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _viewModel.currentContent,
                builder: (context, content, child) {
                  if (!mounted) return const SizedBox();

                  String? path;
                  ChapterModel? chapter;
                  if (content is MaterialContent) {
                    path = content.material.path;
                  } else if (content is ChapterContent) {
                    path = content.chapter.path;
                    chapter = content.chapter;
                  } else if (content is QuizContent) {
                    return CourseQuiz(
                        quizs: content.quizs,
                        onComplete: _viewModel.setCompletedLesson,
                        lesson: _viewModel.lessonCurrent.value);
                  }

                  if (path != null) {
                    final cleanPath = path;
                    final url = AppUtils.pathMediaToUrl(
                        "${AppEndpoint.baseImageUrl}$cleanPath");
                    return _buildContentWidget(
                        path: cleanPath,
                        url: url,
                        mediaQuery: mediaQuery,
                        isChapter: content is ChapterContent,
                        chapter: chapter);
                  }

                  return _buildLoading();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // widget hiển thị nội dung theo định dạng file
  Widget _buildContentWidget(
      {required String path,
      required String url,
      required MediaQueryData mediaQuery,
      required bool isChapter,
      ChapterModel? chapter}) {
    if (path.endsWith('.mp4')) {
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      final videoHeight = screenWidth * 9 / 16;
      final maxAllowedHeight = screenHeight * 0.35;
      final finalHeight =
          videoHeight > maxAllowedHeight ? maxAllowedHeight : videoHeight;

      return Container(
        height: finalHeight,
        width: double.infinity,
        color: Colors.black,
        child: ValueListenableBuilder(
          valueListenable: _viewModel.videoPlayerHelper,
          builder: (context, videoPlayerHelper, child) => CourseVideo(
            videoPlayerHelper: videoPlayerHelper,
            mediaQuery: mediaQuery,
            path: url,
          ),
        ),
      );
    } else if (path.endsWith('.pdf') ||
        path.endsWith('.docx') ||
        path.endsWith('.txt')) {
      return CourseFile(
        key: ValueKey(url),
        url: url,
        filePath: path,
        mediaQuery: mediaQuery,
        onViewedDone: () {
          if (isChapter && chapter != null) {
            _viewModel.onViewedDone(chapterCompleted: chapter);
          }
        },
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Không hỗ trợ hiển thị định dạng này: ${path.split('.').last}',
                style: styleSmall.copyWith(color: grey3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadFile(
                    url,
                    path,
                    () => _viewModel.onViewedDone(
                        chapterCompleted: chapter ?? ChapterModel())),
                icon: const Icon(
                  Icons.download,
                  color: white,
                ),
                label: const Text('Tải xuống file'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        Get.back(); // Đóng dialog

        Get.defaultDialog(
          backgroundColor: white,
          title: 'Cần quyền truy cập',
          titleStyle: styleSmallBold.copyWith(color: grey3),
          content: Text(
            'Cần cấp quyền lưu trữ để tải xuống file. Vui lòng cấp quyền trong cài đặt của ứng dụng.',
            style: styleSmall.copyWith(color: grey3),
          ),
          confirm: ElevatedButton(
            onPressed: () async {
              Get.back(); // Đóng dialog
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mở cài đặt'),
          ),
        );

        return false;
      }
    }

    return true;
  }

  // Hàm tải xuống file
  Future<void> _downloadFile(
      String url, String path, Function()? onViewedDone) async {
    try {
      final fileName = path.split('/').last;

      // Kiểm tra quyền lưu trữ trên thiết bị
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return;
      }

      late final String savePath;
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        savePath = '${directory?.path}/Downloads/$fileName';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }
      _viewModel.setLoading(true);
      final response = await AppClients().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          final progress = (received / total * 100).toStringAsFixed(0);
          debugPrint('Tải xuống: $progress%');
        },
      );
      _viewModel.setLoading(false);

      if (response.statusCode == 200) {
        _viewModel.showToast(
          title: 'Tải xuống file thành công',
          type: ToastificationType.success,
        );
        onViewedDone?.call();
      } else {
        _viewModel.showToast(
          title: 'Lỗi, Không thể tải xuống file',
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      _viewModel.setLoading(false);
      _viewModel.showToast(
        title: 'Đã xảy ra lỗi khi tải xuống. Vui lòng thử lại sau!',
        type: ToastificationType.error,
      );
      _viewModel.logger.e('Lỗi tải xuống: $e');
    }
  }

  Widget _buildLoading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoadingAnimationWidget.stretchedDots(
          color: primary,
          size: 50,
        ),
      ],
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    // Lấy chapter hiện tại từ currentContent nếu có
    ChapterModel? currentChapter;
    if (_viewModel.currentContent.value is ChapterContent) {
      currentChapter =
          (_viewModel.currentContent.value as ChapterContent).chapter;
    }

    Widget commentWidget = CourseComment(
      comments: _viewModel.comments,
      email: _viewModel.student.value?.email,
      commentSelected: _viewModel.commentSelected,
      commentController: _viewModel.commentController,
      onSendComment: ({CommentModel? comment}) async {
        if (context.mounted) {
          // Gửi comment hoặc reply
          await _viewModel.send(comment: comment);
        }
      },
      setCommentSelected: _viewModel.setCommentSelected,
      onLoadMoreComments: _viewModel.loadComment,
      onLoadMoreRepLies: _viewModel.loadReply,
      currentChapter: currentChapter,
      animatedCommentId: _viewModel.animatedCommentId,
      animatedReplyId: _viewModel.animatedReplyId,
      onEditComment: _viewModel.editComment,
      onEditReply: _viewModel.editReply,
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
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 20),
          child: commentWidget,
        );
      },
    );
  }
}
