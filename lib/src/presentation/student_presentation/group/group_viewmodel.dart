import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

class GroupViewModel extends BaseViewModel {
  final ValueNotifier<List<GroupModel>?> groups = ValueNotifier(null);
  final ScrollController scrollController = ScrollController();

  init() async {
    scrollController.addListener(_onScroll);
    refresh();
  }

  int pageNumber = 0;
  final int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;

  void refresh() async {
    pageNumber = 0;
    hasMore = true;
    groups.value = [];
    await loadMoreGroups();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreGroups();
    }
  }

  void navigateToGroupDetail({GroupModel? group}) {
    Get.toNamed(Routers.groupDetail, arguments: {'group' : group});
  }

  Future<void> loadMoreGroups() async {
    if (isLoading || !hasMore) return;
    isLoading = true;

    NetworkState<List<GroupModel>> resultGroups =
        await groupRepository.getAllGroupByStudent(pageSize: pageSize, pageNumber: pageNumber);

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
}
