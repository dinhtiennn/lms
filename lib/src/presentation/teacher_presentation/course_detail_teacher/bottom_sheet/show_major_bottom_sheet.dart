import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

void showMajorBottomSheet(BuildContext context, List<MajorModel> majors,
    CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    backgroundColor: white,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.paddingOf(context).bottom + 20),
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
                    'Chọn ngành học',
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
              itemCount: majors.length,
              itemBuilder: (context, index) {
                final major = majors[index];
                return ListTile(
                  title: Text(
                    major.name ?? '',
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  onTap: () {
                    viewModel.setMajor(major);
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
