import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/resource/enum/course_enum.dart';

class CourseReviewScreen extends StatefulWidget {
  const CourseReviewScreen({Key? key}) : super(key: key);

  @override
  State<CourseReviewScreen> createState() => _CourseReviewScreenState();
}

class _CourseReviewScreenState extends State<CourseReviewScreen> {
  late CourseReviewViewModel _viewModel;

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
    return BaseWidget<CourseReviewViewModel>(
        viewModel: CourseReviewViewModel(),
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
      actions: [
        SizedBox(
          width: Get.width / 2,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
                onPressed: () {
                  _viewModel.allRequest();
                },
                child: Text('Xem tất cả yêu cầu',
                    style: styleVerySmall.copyWith(
                        fontWeight: FontWeight.w500, color: white, overflow: TextOverflow.ellipsis))),
          ),
        )
      ],
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

            _buildOverviewTab(course: course)
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

  Widget _buildOverviewTab({CourseModel? course}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu về khóa học',
          style: styleLargeBold.copyWith(color: black),
        ),
        const SizedBox(height: 12),
        Text(
          course?.description ?? 'Không có mô tả cho khóa học này.',
          style: styleSmall.copyWith(color: grey2),
        ),
        const SizedBox(height: 24),
        Text(
          'Giảng viên',
          style: styleMediumBold.copyWith(color: black),
        ),
        const SizedBox(height: 12),
        _buildInstructor(teacher: course?.teacher),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: (_viewModel.review ?? false)
                  ? SizedBox()
                  : ValueListenableBuilder<StatusJoin>(
                      valueListenable: _viewModel.joinStatus,
                      builder: (context, statusJoin, child) {
                        return _buildJoinButton();
                      },
                    ),
            ),
          ],
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

  Widget _buildJoinButton() {
    return ValueListenableBuilder<StatusJoin>(
      valueListenable: _viewModel.joinStatus,
      builder: (context, statusJoin, child) {
        switch (statusJoin) {
          case StatusJoin.APPROVED:
            return MaterialButton(
              onPressed: _viewModel.handleApproved,
              color: success,
              textColor: white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Vào học ngay',
                style: styleMedium.copyWith(color: white),
              ),
            );
          case StatusJoin.PENDING:
            return MaterialButton(
              onPressed: _viewModel.handlePending,
              color: warning,
              textColor: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Đang chờ phê duyệt',
                style: styleMedium.copyWith(color: white),
              ),
            );
          case StatusJoin.REJECTED:
            return MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: _viewModel.handleRejected,
              color: error,
              textColor: white,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Bị từ chối - Click để yêu cầu lại',
                style: styleMedium.copyWith(color: white),
              ),
            );
          case StatusJoin.NOT_JOINED:
            // Thêm kiểm tra cho khóa học tính phí
            ValueNotifier<CourseModel?> course = _viewModel.course;
            if (course.value?.feeType == 'CHARGEABLE') {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Khóa học này yêu cầu thanh toán',
                      style: TextStyle(
                        color: grey3,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onPressed: _viewModel.payCourse,
                          color: primary2,
                          textColor: white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payment_rounded,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Thanh toán',
                                style: styleMedium.copyWith(color: white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _viewModel.handleNotJoined,
                color: primary2,
                textColor: white,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tham gia khóa học',
                  style: styleMedium.copyWith(color: white),
                ),
              );
            }
        }
      },
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
}
