import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class CourseDetailTeacherScreen extends StatefulWidget {
  const CourseDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailTeacherScreen> createState() =>
      _CourseDetailTeacherScreenState();
}

class _CourseDetailTeacherScreenState extends State<CourseDetailTeacherScreen> {
  late CourseDetailTeacherViewModel _viewModel;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getLearningDurationLabel(String? type) {
    switch (type) {
      case 'LIMITED':
        return 'Giới hạn thời gian';
      case 'UNLIMITED':
        return 'Không giới hạn';
      default:
        return type ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseDetailTeacherViewModel>(
      viewModel: CourseDetailTeacherViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _viewModel.init();
        });
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết khóa học'),
            backgroundColor: primary2,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _viewModel.initBottomSheet();
                  showEditBottomSheet(context, _viewModel);
                },
              ),
              ValueListenableBuilder<CourseDetailModel?>(
                valueListenable: _viewModel.courseDetail,
                builder: (context, courseDetail, child) => Builder(
                  builder: (BuildContext popupContext) {
                    return PopupMenuButton<String>(
                      key: UniqueKey(),
                      color: white,
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          switch (value) {
                            case 'manage_students':
                              _viewModel.getStudentsOfCourse().then((_) {
                                showManageStudentsBottomSheet(
                                    popupContext, _viewModel);
                              });
                              break;
                            case 'manage_students_request':
                              _viewModel.getAllRequestToCourse().then((_) {
                                showManageStudentsBottomSheetRequest(
                                    popupContext, _viewModel);
                              });
                              break;
                            case 'add_students':
                              showAddStudentBottomSheet(
                                  popupContext, _viewModel);
                              break;
                            case 'remove_course':
                              _showDialogRemoveCourse(popupContext);
                              break;
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: 'manage_students',
                            child: Row(
                              children: [
                                Icon(Icons.people_outline, color: primary3),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Quản lý sinh viên',
                                    style: styleSmall.copyWith(color: grey3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!(courseDetail?.status
                                  ?.toUpperCase()
                                  .contains('PUBLIC') ??
                              false))
                            PopupMenuItem(
                              value: 'manage_students_request',
                              child: Row(
                                children: [
                                  Image(
                                    image:
                                        AssetImage(AppImages.png('subscribe')),
                                    width: 20,
                                    height: 20,
                                    color: primary3,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Yêu cầu tham gia khóa học',
                                      style: styleSmall.copyWith(color: grey3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!(courseDetail?.status
                                  ?.toUpperCase()
                                  .contains('PUBLIC') ??
                              false))
                            PopupMenuItem(
                              value: 'add_students',
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_alt, color: primary3),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Thêm sinh viên vào khóa học',
                                      style: styleSmall.copyWith(color: grey3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'remove_course',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: error),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Xóa khóa học',
                                    style: styleSmall.copyWith(color: error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    );
                  },
                ),
              )
            ],
          ),
          body: SafeArea(
            child: _buildBody(),
          ),
          backgroundColor: white,
        );
      },
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<CourseDetailModel?>(
      valueListenable: _viewModel.courseDetail,
      builder: (context, course, child) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa khóa học
            WidgetImageNetwork(
                url: '${AppEndpoint.baseImageUrl}${course?.image}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                widgetError: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppUtils.getGradientForCourse(course?.name),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LMS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          course?.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên khóa học
                  Text(
                    course?.name ?? '',
                    style: styleLargeBold.copyWith(color: black),
                  ),
                  const SizedBox(height: 16),

                  // Thông tin chi tiết khóa học (phí và thời gian)
                  _buildCourseHighlights(course: course),
                  const SizedBox(height: 24),

                  // Thống kê tổng quan
                  _buildStatsSummary(course: course),
                  const SizedBox(height: 24),

                  // Ngành học
                  Row(
                    children: [
                      Icon(Icons.school, color: grey2, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ngành: ${course?.major ?? ''}',
                          style: styleSmall.copyWith(color: grey2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mô tả khóa học
                  Text(
                    'Mô tả khóa học',
                    style: styleMediumBold.copyWith(color: black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course?.description ?? '',
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  const SizedBox(height: 24),

                  // Danh sách bài học
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách bài học',
                        style: styleMediumBold.copyWith(color: black),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            showAddLessonBottomSheet(context, _viewModel),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: white,
                          size: 16,
                        ),
                        label: Text(
                          'Thêm bài học',
                          style: styleSmall.copyWith(color: white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary3,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: course?.lesson?.length ?? 0,
                    itemBuilder: (context, index) {
                      final lesson = course?.lesson?[index];
                      return _buildLessonItem(lesson!);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHighlights({CourseDetailModel? course}) {
    final bool isChargeable = course?.feeType == 'CHARGEABLE';
    final bool isLimited = course?.learningDurationType == 'LIMITED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).round()),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Loại phí
          Row(
            children: [
              Icon(
                isChargeable ? Icons.attach_money : Icons.money_off,
                color: isChargeable ? primary2 : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChargeable ? 'Khóa học tính phí' : 'Khóa học miễn phí',
                    style: styleMediumBold.copyWith(
                      color: isChargeable ? primary2 : Colors.green,
                    ),
                  ),
                  if (isChargeable && course?.price != null)
                    Text(
                    '${course!.price ?? ''}\$',
                      style: styleSmall.copyWith(
                        color: isChargeable ? primary2 : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Thời gian học
          Row(
            children: [
              Icon(
                isLimited ? Icons.timer : Icons.all_inclusive,
                color: grey2,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLearningDurationLabel(course?.learningDurationType),
                      style: styleMediumBold.copyWith(color: grey2),
                    ),
                    if (isLimited &&
                        (course?.startDate != null || course?.endDate != null))
                      Text(
                        course?.startDate != null && course?.endDate != null
                            ? 'Thời gian: ${_formatDate(course?.startDate)} - ${_formatDate(course?.endDate)}'
                            : course?.startDate != null
                                ? 'Bắt đầu: ${_formatDate(course?.startDate)}'
                                : 'Kết thúc: ${_formatDate(course?.endDate)}',
                        style: styleSmall.copyWith(color: grey3),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary({CourseDetailModel? course}) {
    // Tính toán số lượng chương học từ danh sách bài học
    int totalChapters = 0;
    if (course?.lesson != null) {
      for (var lesson in course!.lesson!) {
        totalChapters += lesson.chapters?.length ?? 0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).round()),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              Icons.book_outlined, '${course?.lesson?.length ?? 0}', 'Bài học'),
          _buildVerticalDivider(),
          _buildStatItem(
              Icons.menu_book_outlined, '$totalChapters', 'Chương học'),
          if (course?.status?.isNotEmpty == true) ...[
            _buildVerticalDivider(),
            _buildStatItem(
              course?.status == 'PUBLIC' ? Icons.public : Icons.lock_outlined,
              course?.status ?? '',
              'Trạng thái',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: primary3, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: styleMediumBold.copyWith(color: primary3),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: styleSmall.copyWith(color: grey2),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: grey.withAlpha(255 * (0.3).round()),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return Card(
      color: white,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          Icons.play_lesson_outlined,
          color: primary3,
        ),
        title: Text(
          lesson.description ?? '',
          style: styleSmallBold.copyWith(color: black),
        ),
        shape: const Border(),
        showTrailingIcon: true,
        children: [
          // Tài liệu bài học
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tài liệu bài học',
                        style: styleSmallBold.copyWith(color: black),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showAddMaterialBottomSheet(
                          context, lesson, _viewModel),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: primary3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...lesson.lessonMaterials!.map(
                  (material) => ListTile(
                    leading: Icon(Icons.file_present, color: primary2),
                    title: Text(
                      (material.path ?? '').split('/').last,
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () => Get.toNamed(
                        Routers.courseMaterialDetailTeacher,
                        arguments: {'material': material}),
                  ),
                ),
              ],
            ),
          ),

          // Chương học
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chương học',
                        style: styleSmallBold.copyWith(color: black),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showAddChapterBottomSheet(
                          context, lesson, _viewModel),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: primary3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...lesson.chapters!.map(
                  (chapter) => Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: Icon(
                            chapter.type == 'file'
                                ? Icons.file_present
                                : Icons.video_library,
                            color: primary2,
                          ),
                          title: Text(
                            chapter.name ?? '',
                            style: styleSmall.copyWith(color: grey2),
                          ),
                          onTap: () => Get.toNamed(
                              Routers.courseFileDetailTeacher,
                              arguments: {'chapter': chapter}),
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Icon(Icons.comment_outlined, color: primary2),
                        ),
                        onTap: () {
                          _viewModel.setChapter(chapter);
                          _showCommentBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bài kiểm tra
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Bài kiểm tra',
                        style: styleSmallBold.copyWith(color: black),
                      ),
                    ),
                    lesson.lessonQuizs?.isEmpty ?? false
                        ? IconButton(
                            onPressed: () {
                              if (lesson.chapters?.isEmpty ?? false) {
                                _viewModel.showToast(
                                    title:
                                        'Vui lòng thêm chương học trước khi thêm bài kiểm tra!',
                                    type: ToastificationType.warning);
                                return;
                              }
                              showCreateQuizBottomSheet(
                                  context, lesson, _viewModel);
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: primary3,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                const SizedBox(height: 8),
                ...lesson.lessonQuizs!.map(
                  (quiz) => ListTile(
                    leading: Icon(Icons.quiz, color: primary2),
                    title: Text(
                      quiz.question ?? '',
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () => Get.toNamed(Routers.courseQuizsDetailTeacher,
                        arguments: {'lesson': lesson}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    // Lấy chapter hiện tại từ chapterSelected
    ChapterModel? currentChapter = _viewModel.chapterSelected.value;

    Widget commentWidget = CourseCommentTeacher(
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
      onLoadMoreComments: (
          {required ChapterModel chapter,
          int pageSize = 20,
          int pageNumber = 0}) {
        _viewModel.loadComments(isReset: pageNumber == 0, pageSize: pageSize);
      },
      currentChapter: currentChapter,
      animatedCommentId: _viewModel.animatedCommentId,
      animatedReplyId: _viewModel.animatedReplyId,
      avatarUrl: _viewModel.teacher.value?.avatar,
      onLoadMoreReplies: _viewModel.loadMoreReplies,
      onEditComment: _viewModel.editComment,
      onEditReply: _viewModel.editReply,
      onDispose: _viewModel.resetCommentState,
      userEmail: _viewModel.teacher.value?.email,
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

  void _showDialogRemoveCourse(BuildContext popupContext) {
    showDialog(
      context: context,
      builder: (context) => WidgetDialogConfirm(
        titleStyle: styleMediumBold.copyWith(color: error),
        colorButtonAccept: error,
        title: 'Xóa khóa học',
        onTapConfirm: () {
          _viewModel.removeCourse();
          Navigator.pop(context);
        },
        content: 'Xác nhận xóa khóa học',
      ),
    );
  }
}
