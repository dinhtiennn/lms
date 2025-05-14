import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          _buildStatItem(Icons.play_circle_outline, '${course?.lessonCount ?? 0}', 'Bài học'),
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
        const SizedBox(height: 12),
        (_viewModel.review ?? false)
            ? SizedBox()
            : ValueListenableBuilder<StatusJoin>(
                valueListenable: _viewModel.joinStatus,
                builder: (context, status, _) {
                  return _buildJoinButton();
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

  Widget _buildJoinButton() {
    return ValueListenableBuilder<StatusJoin>(
      valueListenable: _viewModel.joinStatus,
      builder: (context, joinStatus, child) {
        switch (joinStatus) {
          case StatusJoin.APPROVED:
            return _buildApprovedButton();
          case StatusJoin.PENDING:
            return _buildPendingButton();
          case StatusJoin.REJECTED:
            return _buildRejectedButton();
          case StatusJoin.NOT_JOINED:
            return _buildNotJoinedButton();
          }
      },
    );
  }

  Widget _buildApprovedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _viewModel.handleApproved();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: success,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Vào học ngay',
          style: styleMediumBold.copyWith(color: white),
        ),
      ),
    );
  }

  Widget _buildPendingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _viewModel.handlePending();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: warning,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top, color: white),
            const SizedBox(width: 8),
            Text(
              'Đang chờ duyệt',
              style: styleMediumBold.copyWith(color: white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _viewModel.handleRejected();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: error,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: white),
            const SizedBox(width: 8),
            Text(
              'Tham gia lại',
              style: styleMediumBold.copyWith(color: white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotJoinedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _viewModel.handleNotJoined();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary2,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Tham gia ngay',
          style: styleMediumBold.copyWith(color: white),
        ),
      ),
    );
  }
}
