import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/presentation/student_presentation/group/group.dart';
import 'package:lms/src/resource/resource.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late GroupViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<GroupViewModel>(
        viewModel: GroupViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Nhóm học tập',
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
          _viewModel.refresh();
        },
        child: ValueListenableBuilder<List<GroupModel>?>(
          valueListenable: _viewModel.groups,
          builder: (context, groups, child) {
            if (groups?.isEmpty ?? false) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: Get.height - 200,
                    child: Center(
                      child: Text(
                        'Hiện tại không có nhóm nào!',
                        style: styleMedium.copyWith(color: grey3),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.paddingOf(context).bottom + 40),
              itemCount: groups?.length,
              controller: _viewModel.scrollController,
              itemBuilder: (context, index) {
                GroupModel? group = groups?[index];
                return _buildGroupCard(group);
              },
            );
          },
        ));
  }

  Widget _buildGroupCard(GroupModel? group) {
    if (group == null) return SizedBox.shrink();
    return Card(
      color: white,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewModel.navigateToGroupDetail(group: group),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name ?? '',
                          style: styleMediumBold.copyWith(color: primary2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          group.description ?? '',
                          style: styleSmall.copyWith(color: grey3),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(height: 1, color: grey5),
              SizedBox(height: 12),
              if (group.teacher != null) _buildTeacherInfo(group.teacher!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherInfo(TeacherModel teacher) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: teacher.avatar != null && teacher.avatar!.isNotEmpty
              ? WidgetImageNetwork(
                  url: teacher.avatar,
                  width: 36,
                  height: 36,
                  radiusAll: 100,
                )
              : Center(
                  child: Text(
                    (teacher.fullName?.isNotEmpty ?? false) ? teacher.fullName![0].toUpperCase() : '?',
                    style: styleSmallBold.copyWith(color: primary),
                  ),
                ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher.fullName ?? '',
                style: styleSmallBold.copyWith(color: grey2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Giảng viên',
                style: styleVerySmall.copyWith(color: grey3),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: grey3),
      ],
    );
  }
}
