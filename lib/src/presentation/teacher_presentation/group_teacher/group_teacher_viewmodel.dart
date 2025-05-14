import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class GroupTeacherViewModel extends BaseViewModel {
  final ValueNotifier<List<GroupModel>?> groups = ValueNotifier(null);
  final formKey = GlobalKey<FormState>();
  TextEditingController groupName = TextEditingController();
  TextEditingController groupDescription = TextEditingController();
  final ScrollController scrollController = ScrollController();
  int pageNumber = 0;
  final int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;

  void init() async {
    pageNumber = 0;
    hasMore = true;
    scrollController.addListener(_onScroll);
    await loadMoreGroups();
  }

  void refresh() async {
    pageNumber = 0;
    hasMore = true;
    groups.value = [];
    await loadMoreGroups();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreGroups();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    groupName.dispose();
    groupDescription.dispose();
    super.dispose();
  }

  Future<void> loadMoreGroups() async {
    if (isLoading || !hasMore) return;
    isLoading = true;

    NetworkState<List<GroupModel>> resultGroups = await groupRepository
        .getAllGroupByTeacher(pageSize: pageSize, pageNumber: pageNumber);

    if (resultGroups.isSuccess && resultGroups.result != null) {
      if (resultGroups.result!.isEmpty) {
        hasMore = false;
      } else {
        groups.value = [...(groups.value ?? []), ...resultGroups.result!];
        pageNumber = pageNumber + 1;
      }
    } else {
      hasMore = false;
    }

    isLoading = false;
  }

  void navigateToGroupDetail({GroupModel? group}) {
    Get.toNamed(Routers.groupDetailTeacher, arguments: {'group': group});
  }

  void createGroup(BuildContext context) async {
    NetworkState<GroupModel> resultCreateGroup = await groupRepository.create(
        name: groupName.text, description: groupDescription.text);
    if (resultCreateGroup.isSuccess && resultCreateGroup.result != null) {
      pageNumber = 0;
      hasMore = true;
      groups.value = [];
      await loadMoreGroups();
      showToast(title: 'Tạo nhóm thành công', type: ToastificationType.success);
      groupName.text = '';
      groupDescription.text = '';
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(
          title: 'Lỗi ${resultCreateGroup.message}',
          type: ToastificationType.error);
    }
  }

  void editGroup(BuildContext context, GroupModel group) async {
    NetworkState<GroupModel> resultUpdateGroup = await groupRepository.update(
        groupId: group.id,
        name: groupName.text,
        description: groupDescription.text);
    if (resultUpdateGroup.isSuccess && resultUpdateGroup.result != null) {
      pageNumber = 0;
      hasMore = true;
      groups.value = [];
      await loadMoreGroups();
      showToast(
          title: 'Cập nhật nhóm thành công', type: ToastificationType.success);
      groupName.text = '';
      groupDescription.text = '';
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(
          title: 'Lỗi ${resultUpdateGroup.message}',
          type: ToastificationType.error);
    }
  }
}
