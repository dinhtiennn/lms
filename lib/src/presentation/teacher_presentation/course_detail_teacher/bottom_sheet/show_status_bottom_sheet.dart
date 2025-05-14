import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';

void showStatusBottomSheet(
    BuildContext context, CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: white,
    useSafeArea: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Chọn trạng thái khóa học',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.statusOptions.length,
              itemBuilder: (context, index) {
                final status = viewModel.statusOptions[index];
                return ListTile(
                  title: Text(
                    status.label,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  onTap: () {
                    viewModel.statusSelected.value = status;
                    Navigator.pop(context);
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
