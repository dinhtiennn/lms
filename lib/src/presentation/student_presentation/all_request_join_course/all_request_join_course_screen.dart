import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';

class AllRequestJoinCourseScreen extends StatefulWidget {
  const AllRequestJoinCourseScreen({Key? key}) : super(key: key);

  @override
  State<AllRequestJoinCourseScreen> createState() => _AllRequestJoinCourseScreenState();
}

class _AllRequestJoinCourseScreenState extends State<AllRequestJoinCourseScreen> {
  late AllRequestJoinCourseViewModel _viewModel;
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<AllRequestJoinCourseViewModel>(
        viewModel: AllRequestJoinCourseViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Yêu cầu tham gia khóa học', style: styleVeryLargeBold.copyWith(color: grey3)),
              backgroundColor: white,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<List<RequestToCourseModel>?>(
      valueListenable: _viewModel.listRequest,
      builder: (context, requests, child) {
        if (requests == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: grey3),
                const SizedBox(height: 16),
                Text(
                  'Không có yêu cầu tham gia khóa học nào',
                  style: styleMedium.copyWith(color: grey3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: requests.length + 1,
          itemBuilder: (context, index) {
            if (index == requests.length) {
              return ValueListenableBuilder<bool>(
                valueListenable: _viewModel.isLoadingMore,
                builder: (context, isLoadingMore, child) {
                  if (!isLoadingMore) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            }

            final request = requests[index];
            return Card(
              color: white,
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: grey3.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: WidgetImageNetwork(
                              url: request.image,
                              radiusAll: 8,
                              widgetError: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: AppUtils.getGradientForCourse(request.name),
                                    ),
                                  ),
                                  child: Icon(Icons.school, size: 32, color: white)),
                            )),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.name ?? 'Không có tên',
                                style: styleLargeBold.copyWith(color: grey3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request.description ?? 'Không có mô tả',
                                style: styleSmall.copyWith(color: grey3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    // Course Info
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.person_outline,
                            'Giảng viên',
                            request.teacher?.fullName ?? 'Chưa có giảng viên',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.school_outlined,
                            'Chuyên ngành',
                            request.major ?? 'Chưa có chuyên ngành',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.calendar_today_outlined,
                            'Thời gian học',
                            request.learningDurationType ?? 'Không xác định',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.people_outline,
                            'Học viên',
                            '${request.studentCount ?? 0} người',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.book_outlined,
                            'Bài học',
                            '${request.lessonCount ?? 0} bài',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.date_range_outlined,
                            'Ngày bắt đầu',
                            request.startDate != null
                                ? '${request.startDate!.day}/${request.startDate!.month}/${request.startDate!.year}'
                                : 'Chưa có',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(request.status),
                        style: styleSmall.copyWith(color: white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: grey3),
            const SizedBox(width: 4),
            Text(
              label,
              style: styleSmall.copyWith(color: grey3),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: styleMedium.copyWith(color: grey3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return grey3;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'public':
        return 'Công khai';
      case 'private':
        return 'Riêng tư';
      case 'draft':
        return 'Bản nháp';
      default:
        return 'Không xác định';
    }
  }
}
