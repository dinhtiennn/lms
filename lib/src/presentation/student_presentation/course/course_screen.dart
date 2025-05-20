import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late CourseViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseViewModel>(
        viewModel: CourseViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
          _scrollController.addListener(_scrollListener);
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Khóa học của tôi',
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
    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.getMyCourse();
      },
      child: ValueListenableBuilder<List<CourseModel>>(
        valueListenable: _viewModel.myCourse,
        builder: (context, courses, child) => courses.isEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: Get.height * 0.3),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(left: Get.width / 9),
                      child: Image(
                        image: AssetImage(AppImages.png('course_empty')),
                        width: Get.width / 4,
                        color: grey3,
                      ),
                    ),
                  ),
                  _buildLoadMoreIndicator()
                ],
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.symmetric(vertical: 8)
                            .copyWith(bottom: Get.height / 15),
                        shrinkWrap: true,
                        itemCount: courses.length,
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: buildItemCourse(
                              onTap: () {
                                Get.toNamed(Routers.courseDetail, arguments: {
                                  'course': courses[index],
                                });
                              },
                              course: courses[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isLoadingMoreCourses,
      builder: (context, isLoading, _) {
        return isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: LoadingAnimationWidget.stretchedDots(
                    color: primary,
                    size: 32,
                  ),
                ),
              )
            : SizedBox();
      },
    );
  }

  Widget buildItemCourse({Function()? onTap, required CourseModel course}) {
    final List<List<Color>> _gradients = [
      [Color(0xFF1A237E), Color(0xFF3949AB)],
      [Color(0xFF4A148C), Color(0xFF7B1FA2)],
      [Color(0xFF004D40), Color(0xFF00796B)],
      [Color(0xFFE65100), Color(0xFFF57C00)],
      [Color(0xFF880E4F), Color(0xFFC2185B)],
    ];

    List<Color> _getGradientForCourse(String? courseTitle) {
      if (courseTitle == null || courseTitle.isEmpty) {
        return _gradients[
            0]; // Mặc định màu xanh dương cho khóa học không có tên
      }

      // Tính hash của tên khóa học để có số cố định cho mỗi tên
      int hashCode = courseTitle.toLowerCase().hashCode.abs();
      // Lấy index dựa trên hash để đảm bảo cùng tên sẽ cho cùng màu
      int index = hashCode % _gradients.length;
      return _gradients[index];
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                child: WidgetImageNetwork(
                    url: course.image,
                    fit: BoxFit.cover,
                    widgetError: Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradientForCourse(course.name),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'LMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            const SizedBox(width: 18),
            // Course info and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    course.name ?? '',
                    style: styleSmallBold.copyWith(color: grey3),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.teacher?.fullName ?? '',
                    style: styleVerySmall.copyWith(color: grey3),
                  ),
                  const SizedBox(height: 14),
                  // Progress bar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: Get.width - 158,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      // Progress indicator
                      Builder(builder: (context) {
                        // Đảm bảo progress không null
                        final progressValue = course.progress ?? 0;
                        final progressWidth =
                            (progressValue / 100) * (Get.width - 158);

                        return Container(
                          width: progressWidth,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF003096),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                      Positioned(
                        top: -12,
                        right: -10,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 17),
                          child: Text(
                            '${course.progress ?? 0}%',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFB7B0B0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _viewModel.loadMoreMyCourses();
    }
  }
}
