import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';

class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({Key? key}) : super(key: key);

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
  late HomeTeacherViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_viewModel.isRefreshing) {
        _viewModel.loadMyCourse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<HomeTeacherViewModel>(
        viewModel: HomeTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: ValueListenableBuilder<TeacherModel?>(
                valueListenable: _viewModel.teacher,
                builder: (context, teacher, child) => Row(
                  children: [
                    WidgetImageNetwork(
                        url: teacher?.avatar ?? '',
                        width: 40,
                        height: 40,
                        radiusAll: 100,
                        widgetError: Container(
                          width: 40,
                          height: 40,
                          color: white,
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        )),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: ValueListenableBuilder<TeacherModel?>(
                        valueListenable: _viewModel.teacher,
                        builder: (context, teacher, child) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${'hi'.tr} 👋'.tr,
                                  style: styleVerySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: white)),
                              Text(
                                'GV. ${teacher?.fullName ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                style: styleVerySmall.copyWith(color: white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leadingWidth: 0,
              leading: SizedBox.shrink(),
              backgroundColor: primary2,
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              ],
            ),
            body: SafeArea(child: _buildBody()),
            drawer: SafeArea(
              child: Drawer(
                backgroundColor: white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 66,
                            child: DrawerHeader(
                              decoration: BoxDecoration(color: primary2),
                              padding: EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  AppImages.png('logo2'),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Image(
                              image: AssetImage(AppImages.png('util')),
                              width: 20,
                              height: 20,
                            ),
                            title: Text(
                              "Tiện ích",
                              style: styleSmall.copyWith(color: black),
                            ),
                          ),
                          _buildContentUtil()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.refresh();
      },
      child: Container(
        color: white,
        height: Get.height,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              SizedBox(
                height: 24,
              ),
              // Nút tạo khóa học
              WidgetButton(
                text: 'Tạo khóa học',
                iconHeader: Image(
                  image: AssetImage(AppImages.png('add')),
                  width: 20,
                  height: 20,
                  color: white,
                ),
                onTap: () {
                  _viewModel.createCourse();
                },
                radius: BorderRadius.circular(12),
                color: primary2,
                borderColor: Colors.transparent,
              ),
              SizedBox(height: 24),
              // Danh sách khóa học
              ValueListenableBuilder<List<CourseModel>?>(
                valueListenable: _viewModel.courses,
                builder: (context, courses, child) {
                  if (courses == null || courses.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có khóa học nào',
                        style: styleSmall.copyWith(color: grey3),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: courses.length + 1,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == courses.length) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _viewModel.isLoadingMore,
                          builder: (context, isLoading, child) {
                            if (!isLoading) return SizedBox.shrink();
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(primary2),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      final course = courses[index];
                      return WidgetItemCourse(
                        course: course,
                        onTap: () {
                          _viewModel.courseDetail(course);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grey5, width: 1)),
      child: WidgetInput(
        hintText: 'Tìm kiếm khóa học...',
        prefix: Icon(
          Icons.search,
          size: 32,
        ),
        widthPrefix: 52,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        borderColor: Colors.transparent,
        readOnly: true,
        onTap: () {
          _viewModel.search();
        },
      ),
    );
  }

  Widget _buildContentUtil() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              _buildItemUtil(
                  image: 'documentation',
                  name: 'Tài liệu',
                  onTap: () {
                    Get.toNamed(Routers.documentTeacher);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemUtil({
    required String image,
    required String name,
    required Function() onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: black.withAlpha(20),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Image(
                image: AssetImage(AppImages.png(image)),
                width: 32,
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: styleVerySmall.copyWith(color: blackLight),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
