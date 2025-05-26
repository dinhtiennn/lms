import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/resource/enum/course_enum.dart';

class CourseReviewTeacherScreen extends StatefulWidget {
  const CourseReviewTeacherScreen({Key? key}) : super(key: key);

  @override
  State<CourseReviewTeacherScreen> createState() => _CourseReviewTeacherScreenState();
}

class _CourseReviewTeacherScreenState extends State<CourseReviewTeacherScreen> {
  late CourseReviewTeacherViewModel _viewModel;

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
    return BaseWidget<CourseReviewTeacherViewModel>(
        viewModel: CourseReviewTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<CourseModel?>(
      valueListenable: _viewModel.course,
      builder: (context, course, child) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(courseName: course?.name ?? '', image: course?.image),
          _buildInfomationCourse(course),
        ],
      ),
    );
  }

  Widget _buildAppBar({required String courseName, String? image}) {
    return SliverAppBar(
      backgroundColor: primary2,
      expandedHeight: 220,
      pinned: true,
      elevation: 4,
      shadowColor: black,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          courseName,
          style: styleLargeBold.copyWith(color: white, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hình ảnh nền
            WidgetImageNetwork(
              url: image,
              fit: BoxFit.cover,
              widgetError: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppUtils.getGradientForCourse(courseName),
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
                  ],
                ),
              ),
            ),
            // Gradient để văn bản dễ đọc hơn
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((255 * 0.8).round()),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfomationCourse(CourseModel? course) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Fee & Duration Info
            _buildCourseHighlights(course: course),
            const SizedBox(height: 24),

            // Course Stats Summary
            _buildStatsSummary(course: course),
            const SizedBox(height: 24),

            // Tab Selection
            _buildTabSelection(),
            const SizedBox(height: 20),

            ValueListenableBuilder<CourseDetailModel?>(valueListenable: _viewModel.courseDetail, builder: (context, courseDetail, child) => _buildOverviewTab(courseDetail: courseDetail),)
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHighlights({CourseModel? course}) {
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
                      '${course!.price}',
                      style: styleSmall.copyWith(
                        color: isChargeable ? primary2 : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!isChargeable && !(course?.price != null))
                    Text(
                      _getStatusLabel(course!.status),
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
                    if (isLimited && (course?.startDate != null || course?.endDate != null))
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

  Widget _buildStatsSummary({CourseModel? course}) {
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
          _buildStatItem(Icons.people_outline, '${course?.studentCount ?? 0}', 'Người tham gia'),
          _buildVerticalDivider(),
          _buildStatItem(Icons.book_outlined, '${course?.chapterCount ?? 0}', 'Bài học'),
          if (course?.status?.isNotEmpty == true && course?.feeType == 'NON_CHARGEABLE') ...[
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

  Widget _buildTabSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton('Tổng quan'.tr),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: styleVeryLargeBold.copyWith(
          color: grey2,
        ),
      ),
    );
  }

  Widget _buildOverviewTab({CourseDetailModel? courseDetail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu về khóa học',
          style: styleLargeBold.copyWith(color: black),
        ),
        const SizedBox(height: 12),
        Text(
          courseDetail?.description ?? 'Không có mô tả cho khóa học này.',
          style: styleSmall.copyWith(color: grey2),
        ),
        const SizedBox(height: 24),
        Text(
          'Giảng viên',
          style: styleMediumBold.copyWith(color: black),
        ),
        const SizedBox(height: 12),
        _buildInstructor(teacher: courseDetail?.teacher),
        const SizedBox(height: 24),
        // Danh sách bài học
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Danh sách chương học',
                style: styleMediumBold.copyWith(color: black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courseDetail?.lesson?.length ?? 0,
          itemBuilder: (context, index) {
            final lesson = courseDetail?.lesson?[index];
            return _buildLessonItem(lesson!);
          },
        ),
      ],
    );
  }

  Widget _buildInstructor({TeacherModel? teacher}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey.withAlpha((255 * 0.2).round())),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
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
                  teacher?.email ?? '',
                  style: styleSmall.copyWith(color: grey2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String? status) {
    List<StatusOption> statusOptions = [
      StatusOption(Status.PUBLIC, 'Công khai', 'PUBLIC'),
      StatusOption(Status.PRIVATE, 'Riêng tư', 'PRIVATE'),
      StatusOption(Status.REQUEST, 'Yêu cầu tham gia', 'REQUEST'),
    ];

    return statusOptions
        .firstWhere(
          (e) => e.apiValue == status,
        )
        .label;
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
                  ],
                ),
                const SizedBox(height: 8),
                ...lesson.lessonMaterials!.map(
                      (material) => ListTile(
                    leading: Icon(Icons.file_present, color: primary2),
                    title: Text(
                      material.fileName ?? '',
                      style: styleSmall.copyWith(color: grey2),
                    ),
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
                  ],
                ),
                const SizedBox(height: 8),
                ...lesson.chapters!.map(
                      (chapter) => Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: Icon(
                            chapter.type == 'file' ? Icons.file_present : Icons.video_library,
                            color: primary2,
                          ),
                          title: Text(
                            chapter.name ?? '',
                            style: styleSmall.copyWith(color: grey2),
                          ),
                        ),
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
