import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

void showAddStudentBottomSheet(
    BuildContext context, CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    scrollControlDisabledMaxHeightRatio: 0.7,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
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
                    'Thêm sinh viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    viewModel.cleanListStudentSearch();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Hiển thị các chip sinh viên đã chọn
          ValueListenableBuilder<List<StudentModel>>(
            valueListenable: viewModel.selectedStudents,
            builder: (context, selected, child) {
              if (selected.isEmpty) return SizedBox.shrink();
              return Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(16).copyWith(bottom: 0),
                child: Wrap(
                  children: selected
                      .map((student) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(student.fullName ?? ''),
                              onDeleted: () =>
                                  viewModel.removeSelectedStudent(student),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: WidgetInput(
              controller: viewModel.keywordController,
              hintText: 'Nhập tên hoặc email sinh viên...',
              prefix: Icon(Icons.search, color: grey2),
              borderRadius: BorderRadius.circular(12),
              onChanged: (value) {
                viewModel.searchStudentNotInCourse(keyword: value);
              },
              widthPrefix: 40,
              style: styleSmall.copyWith(color: grey2),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<StudentModel>?>(
              valueListenable: viewModel.studentsSearch,
              builder: (context, students, child) {
                if (students == null) {
                  return Center(
                    child: Text(
                      'Nhập tên hoặc email để tìm kiếm sinh viên',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  );
                }

                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy sinh viên nào',
                      style: styleMedium.copyWith(color: grey3),
                    ),
                  );
                }

                return ValueListenableBuilder<List<StudentModel>?>(
                  valueListenable: viewModel.selectedStudents,
                  builder: (context, listStudentSelected, child) =>
                      ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected =
                          listStudentSelected?.any((s) => s.id == student.id);
                      return Card(
                        color: white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: WidgetImageNetwork(
                            width: 40,
                            height: 40,
                            radiusAll: 100,
                            url: student.avatar ?? '',
                            widgetError: CircleAvatar(
                              backgroundColor: primary2,
                              child: Text(
                                'SV',
                                style: styleSmall.copyWith(color: white),
                              ),
                            ),
                          ),
                          title: Text(
                            student.fullName ?? '',
                            style: styleSmallBold.copyWith(color: black),
                          ),
                          subtitle: Text(
                            student.email ?? '',
                            style: styleSmall.copyWith(color: grey2),
                          ),
                          trailing: isSelected ?? false
                              ? Icon(Icons.check, color: successLight)
                              : ElevatedButton(
                                  onPressed: () {
                                    viewModel.addSelectedStudent(student);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Thêm'),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Nút thêm vào lớp
          ValueListenableBuilder<List<StudentModel>>(
            valueListenable: viewModel.selectedStudents,
            builder: (context, selected, child) {
              return Padding(
                padding: EdgeInsets.all(20).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        () {
                          if(selected.isEmpty){
                            return;
                          }
                            viewModel.cleanListStudentSearch();
                            viewModel.cleanStudentsSelected();
                            viewModel.addAllStudentToCourse(context, selected);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected.isEmpty ? Colors.grey.shade300 : primary2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Thêm vào lớp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
