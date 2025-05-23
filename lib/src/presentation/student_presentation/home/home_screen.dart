import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
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
    return BaseWidget<HomeViewModel>(
        viewModel: HomeViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
          _scrollController.addListener(_scrollListener);
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(child: _buildBody()),
            drawer: _buildDrawer(),
            backgroundColor: white,
          );
        });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMorePublicCourses();
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: ValueListenableBuilder<StudentModel?>(
        valueListenable: _viewModel.student,
        builder: (context, student, child) => Row(
          children: [
            _buildProfileAvatar(student),
            const SizedBox(width: 12),
            _buildUserGreeting(student),
          ],
        ),
      ),
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      backgroundColor: primary2,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(StudentModel? student) {
    return InkWell(
      splashColor: transparent,
      onTap: () {
        // Get.toNamed(Routers.editProfile);
      },
      child: student!.avatar != null
          ? Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(strokeAlign: BorderSide.strokeAlignOutside, width: 1, color: grey4)),
              child: WidgetImageNetwork(
                url: student.avatar,
                radiusAll: 100,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                widgetError: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: white,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: white,
              ),
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildUserGreeting(StudentModel? student) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('${'hi'.tr} 👋', style: styleVerySmall.copyWith(fontWeight: FontWeight.w600, color: white)),
            Text(
              student?.fullName ?? '',
              overflow: TextOverflow.ellipsis,
              style: styleVerySmall.copyWith(color: white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.setLoadMore(true);
        await _viewModel.getMyCourses();
        await _viewModel.getPublicCourses();
        _viewModel.logger.d('token ${AppPrefs.accessToken}');
      },
      child: SizedBox(
        height: Get.height,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildContinueWatchingSection(),
              _buildOutstandingCourseSection(),
              _buildLoadMoreIndicator(),
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isLoadingMorePublicCourses,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
            color: white, borderRadius: BorderRadius.circular(12), border: Border.all(color: grey5, width: 1)),
        child: WidgetInput(
          hintText: 'Tìm kiếm khóa học...',
          prefix: Icon(Icons.search, size: 32,),
          widthPrefix: 52,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          borderColor: Colors.transparent,
          readOnly: true,
          onTap: () {
            _viewModel.search();
          },
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection() {
    return ValueListenableBuilder<List<CourseModel>>(
      valueListenable: _viewModel.myCourse,
      builder: (context, courses, child) => courses.isNotEmpty
          ? Column(
              children: [
                _buildSectionHeader(
                  title: 'Khóa học đang học',
                  ontap: () {
                    _viewModel.toListCourseWatching();
                  },
                ),
                _buildCourseCarouselHorizontal(courses),
              ],
            )
          : SizedBox(),
    );
  }

  Widget _buildOutstandingCourseSection() {
    return ValueListenableBuilder<List<CourseModel>>(
      valueListenable: _viewModel.courseOfMajor,
      builder: (context, courses, child) => courses.isNotEmpty
          ? Column(
              children: [
                _buildSectionHeader(title: 'Khóa học dành cho bạn'),
                _buildCourseCarouselVertical(courses: courses),
                SizedBox(
                  height: 20,
                )
              ],
            )
          : SizedBox(),
    );
  }

  Widget _buildSectionHeader({required String title, Function()? ontap}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: styleMediumBold.copyWith(color: grey3),
          ),
          ontap != null
              ? InkWell(
                  onTap: ontap,
                  child: Text(
                    'Xem tất cả',
                    style: styleVerySmall.copyWith(color: grey3),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildCourseCarouselHorizontal(List<CourseModel> courses) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.9,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: courses.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              width: MediaQuery.of(context).size.width / 1.5,
              margin: const EdgeInsets.all(12).copyWith(left: index == 0 ? 0 : 12),
              child: WidgetItemCourse(
                course: courses[index],
                joined: true,
                onTap: () {
                  _viewModel.courseDetail(courses[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCarouselVertical({List<CourseModel>? courses}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: courses?.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            child: WidgetItemCourse(
              course: courses?[index],
              joined: false,
              onTap: () {
                _viewModel.previewCourse(courses![index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return SafeArea(
      child: Drawer(
        backgroundColor: white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: _buildAssignmentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return SizedBox(
      height: 64,
      child: DrawerHeader(
        decoration: BoxDecoration(color: primary2),
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            AppImages.png('logo2'),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return ListView(
      children: [
        ListTile(
          leading: Image(
            image: AssetImage(AppImages.png('util')),
            width: 32,
            height: 32,
          ),
          title: Text(
            "Tiện tích",
            style: styleMediumBold.copyWith(color: black),
          ),
        ),
        _buildContentUtil(),
      ],
    );
  }

  Widget _buildContentUtil() {
    final utilities = [
      {
        'image': 'documentation',
        'name': 'Tài liệu',
        'route': Routers.document,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        runSpacing: 8,
        spacing: 8,
        children: utilities
            .map((util) => _buildItemUtil(
                  image: util['image']!,
                  name: util['name']!,
                  onTap: () => Get.toNamed(util['route']!),
                ))
            .toList(),
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
                  offset: const Offset(0, 4),
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
          const SizedBox(height: 8),
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
