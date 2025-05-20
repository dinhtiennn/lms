import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/presentation/student_presentation/group/group.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_valid.dart';

class GroupTeacherScreen extends StatefulWidget {
  const GroupTeacherScreen({Key? key}) : super(key: key);

  @override
  State<GroupTeacherScreen> createState() => _GroupTeacherScreenState();
}

class _GroupTeacherScreenState extends State<GroupTeacherScreen> {
  late GroupTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<GroupTeacherViewModel>(
        viewModel: GroupTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Nhóm học tập',
                style: styleVeryLargeBold.copyWith(color: white),
              ),
              backgroundColor: primary2,
              actions: [
                IconButton(
                    onPressed: _showCreateGroupModal,
                    icon: Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: white,
                    )),
              ],
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
              physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
              itemCount: groups?.length,
              controller: _viewModel.scrollController,
              itemBuilder: (context, index) {
                GroupModel? group = groups?[index];
                return Card(
                  elevation: 2,
                  color: white.withOpacity(0.8),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _viewModel.navigateToGroupDetail(group: group),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icon nhóm
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.group,
                                  color: primary2,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Tên nhóm
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group?.name ?? '',
                                      style: styleMediumBold.copyWith(color: grey2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Nhóm học tập',
                                      style: styleVerySmall.copyWith(color: grey3),
                                    ),
                                  ],
                                ),
                              ),
                              // Nút chỉnh sửa
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: primary2,
                                  size: 20,
                                ),
                                onPressed: () => _showEditGroupModal(group!),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashRadius: 24,
                              ),
                            ],
                          ),
                          if ((group?.description ?? '').isNotEmpty) SizedBox(height: 12),
                          if ((group?.description ?? '').isNotEmpty)
                            Text(
                              group?.description ?? '',
                              style: styleSmall.copyWith(color: grey4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  void _showCreateGroupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 70),
          child: Form(
            key: _viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: grey5,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Tạo nhóm mới', style: styleLargeBold.copyWith(color: primary2)),
                const SizedBox(height: 16),
                WidgetInput(
                  controller: _viewModel.groupName,
                  titleText: 'Tên nhóm',
                  titleStyle: styleSmall.copyWith(color: grey2),
                  style: styleSmall.copyWith(color: grey2),
                  borderRadius: BorderRadius.circular(12),
                  validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập tên nhóm'),
                ),
                const SizedBox(height: 16),
                WidgetInput(
                  controller: _viewModel.groupDescription,
                  titleText: 'Mô tả nhóm',
                  titleStyle: styleSmall.copyWith(color: grey2),
                  style: styleSmall.copyWith(color: grey2),
                  borderRadius: BorderRadius.circular(12),
                  maxLines: 3,
                  validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập mô tả nhóm'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: grey3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Đóng', style: styleMediumBold.copyWith(color: grey3)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_viewModel.formKey.currentState?.validate() ?? false) {
                            _viewModel.createGroup(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Tạo nhóm', style: styleMediumBold.copyWith(color: white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditGroupModal(GroupModel group) {
    _viewModel.groupName.text = group.name ?? '';
    _viewModel.groupDescription.text = group.description ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 70),
          child: Form(
            key: _viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: grey5,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Chỉnh sửa nhóm', style: styleLargeBold.copyWith(color: primary2)),
                const SizedBox(height: 16),
                WidgetInput(
                  controller: _viewModel.groupName,
                  titleText: 'Tên nhóm',
                  borderRadius: BorderRadius.circular(12),
                  titleStyle: styleSmall.copyWith(color: grey2),
                  style: styleSmall.copyWith(color: grey2),
                  validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập tên nhóm'),
                ),
                const SizedBox(height: 16),
                WidgetInput(
                  controller: _viewModel.groupDescription,
                  titleText: 'Mô tả nhóm',
                  borderRadius: BorderRadius.circular(12),
                  titleStyle: styleSmall.copyWith(color: grey2),
                  style: styleSmall.copyWith(color: grey2),
                  maxLines: 3,
                  validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập mô tả nhóm'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: grey3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Đóng', style: styleMediumBold.copyWith(color: grey3)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_viewModel.formKey.currentState?.validate() ?? false) {
                            _viewModel.editGroup(context, group);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Lưu thay đổi', style: styleMediumBold.copyWith(color: white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
