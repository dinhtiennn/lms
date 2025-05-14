import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/course_model.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchViewModel _viewModel;
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
    return BaseWidget<SearchViewModel>(
        viewModel: SearchViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
          _scrollController.addListener(_scrollListener);
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(
              child: _buildBody(),
            ),
            backgroundColor: white,
          );
        });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreCourses();
    }
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCourseSections(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: grey2),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 8),
          Text(
            'Khám phá khóa học',
            style: styleLargeBold.copyWith(
              color: grey2,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grey5, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: WidgetInput(
          controller: _viewModel.searchController,
          hintText: 'Tìm kiếm khóa học...',
          style: styleSmall.copyWith(color: grey2),
          prefix: Icon(Icons.search, size: 32,),
          widthPrefix: 52,
          suffix: ValueListenableBuilder(
            valueListenable: _viewModel.isSearching,
            builder: (context, isSearching, child) {
              return isSearching
                  ? IconButton(
                      icon: Icon(Icons.close, color: grey3, size: 18),
                      onPressed: () {
                        _viewModel.searchController.clear();
                      },
                    )
                  : SizedBox.shrink();
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          borderColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCourseSections() {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: _viewModel.isSearching,
        builder: (context, isSearching, _) {
          if (isSearching) {
            return _buildSearchResults();
          } else {
            return _buildCoursesByMajor();
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ValueListenableBuilder(
      valueListenable: _viewModel.courseSearch,
      builder: (context, courses, _) {
        if (courses.isEmpty) {
          return _buildEmptyState("Không tìm thấy khóa học phù hợp");
        }
        return _buildCourseList(
          courses: courses,
          isLoadingMore: _viewModel.isLoadingMore,
          title: "Kết quả tìm kiếm",
        );
      },
    );
  }

  Widget _buildCoursesByMajor() {
    return ValueListenableBuilder(
      valueListenable: _viewModel.courseOfMyMajor,
      builder: (context, courses, _) {
        if (courses.isEmpty) {
          return _buildEmptyState("Chưa có khóa học nào cho ngành của bạn");
        }
        return _buildCourseList(
          courses: courses,
          isLoadingMore: _viewModel.isLoadingMore,
          title: "Khóa học theo ngành",
        );
      },
    );
  }

  Widget _buildCourseList({
    required List<CourseModel> courses,
    required ValueNotifier<bool> isLoadingMore,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 12),
          child: Text(
            title,
            style: styleMediumBold.copyWith(color: primary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: courses.length + 1, // +1 for loading indicator
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == courses.length) {
                return ValueListenableBuilder(
                  valueListenable: isLoadingMore,
                  builder: (context, isLoading, _) {
                    return isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: LoadingAnimationWidget.stretchedDots(
                                color: primary,
                                size: 32,
                              ),
                            ),
                          )
                        : SizedBox(height: 40); // Bottom padding
                  },
                );
              }

              return _buildCourseItem(courses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(CourseModel course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: WidgetItemCourse(
        course: course,
        joined: false,
        onTap: () {
          Get.toNamed(Routers.courseReview, arguments: {'course': course});
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: grey4,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: styleMedium.copyWith(color: grey3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
