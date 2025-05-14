import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

void showManageStudentsBottomSheetRequest(BuildContext context, CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: primary2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yêu cầu tham gia khóa học',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<RequestModel>?>(
              valueListenable: viewModel.listRequestToCourse,
              builder: (context, requests, child) {
                if (requests == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (requests.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có yêu cầu nào',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  );
                }
                return ListView.builder(
                  controller: viewModel.requestsScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length + (viewModel.hasMoreRequests ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == requests.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LoadingAnimationWidget.stretchedDots(
                            color: primary,
                            size: 24,
                          ),
                        ),
                      );
                    }
                    final req = requests[index];
                    return Card(
                      color: white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Thông tin sinh viên
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.fullName ?? '',
                                    style: styleSmallBold.copyWith(fontSize: 15, color: black),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    req.email ?? '',
                                    style: styleSmall.copyWith(color: grey2, fontSize: 12),
                                  ),
                                  if (req.major?.name != null)
                                    Text(
                                      req.major!.name!,
                                      style: styleSmall.copyWith(color: primary2, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            // Nút chấp nhận/từ chối
                            Row(
                              children: [
                                Tooltip(
                                  message: 'Chấp nhận',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (context) => WidgetDialogConfirm(
                                          title: 'Chấp nhận',
                                          titleStyle: styleMediumBold.copyWith(color: success),
                                          colorButtonAccept: success,
                                          onTapConfirm: () {
                                            viewModel.approvedRequest(req.id ?? '', context);
                                          },
                                          content: 'Xác nhận sinh viên ${req.fullName} vào khóa học?',
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(Icons.check_circle, color: success, size: 28),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: 'Từ chối',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (context) => WidgetDialogConfirm(
                                          title: 'Từ chối',
                                          titleStyle: styleMediumBold.copyWith(color: error),
                                          colorButtonAccept: error,
                                          onTapConfirm: () {
                                            viewModel.rejectedRequest(req.id ?? '', context);
                                          },
                                          content: 'Từ chối sinh viên ${req.fullName} vào khóa học?',
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(Icons.cancel, color: error, size: 28),
                                      ),
                                    ),
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
              },
            ),
          ),
        ],
      ),
    ),
  );
}
