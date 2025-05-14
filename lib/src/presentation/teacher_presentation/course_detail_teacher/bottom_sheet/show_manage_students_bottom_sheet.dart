import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

void showManageStudentsBottomSheet(
    BuildContext context, CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    useSafeArea: true,
    builder: (context) => Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    'Quản lý sinh viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
            child: ValueListenableBuilder<List<StudentModel>?>(
              valueListenable: viewModel.studentsOfCourse,
              builder: (context, students, child) {
                if (students == null) {
                  return Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: primary,
                      size: 32,
                    ),
                  );
                }

                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có sinh viên nào tham gia khóa học',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  );
                }

                return ListView.builder(
                  controller: viewModel.studentsScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      students.length + (viewModel.hasMoreStudents ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == students.length) {
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
                    return Card(
                      color: white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: WidgetImageNetwork(
                          width: 40,
                          height: 40,
                          radiusAll: 100,
                          url: students[index].avatar ?? '',
                          widgetError: CircleAvatar(
                            backgroundColor: primary2,
                            child: Text(
                              'SV',
                              style: styleSmall.copyWith(color: white),
                            ),
                          ),
                        ),
                        title: Text(
                          students[index].fullName ?? '',
                          style: styleSmallBold.copyWith(color: black),
                        ),
                        subtitle: Text(
                          students[index].email ?? '',
                          style: styleSmall.copyWith(color: grey2),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => WidgetDialogConfirm(
                              titleStyle:
                                  styleMediumBold.copyWith(color: error),
                              colorButtonAccept: error,
                              title: 'Xóa sinh viên',
                              onTapConfirm: () {
                                viewModel.removeStudentOfCourse(
                                    studentId: students[index].id,
                                    context: context);
                              },
                              content:
                                  'Xác nhận xóa sinh viên ${students[index].fullName} khỏi lớp học?',
                            ),
                          ),
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
