import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/lesson_model.dart';

class CourseQuizDetailTeacherScreen extends StatefulWidget {
  const CourseQuizDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<CourseQuizDetailTeacherScreen> createState() =>
      _CourseQuizDetailTeacherScreenState();
}

class _CourseQuizDetailTeacherScreenState
    extends State<CourseQuizDetailTeacherScreen> {
  late CourseQuizDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseQuizDetailTeacherViewModel>(
        viewModel: CourseQuizDetailTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Danh sách câu hỏi kiểm tra',
                style: styleMediumBold.copyWith(color: white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return SafeArea(
      child: _viewModel.lesson.lessonQuizs?.isNotEmpty ?? false
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _viewModel.lesson.lessonQuizs!.length,
              itemBuilder: (context, index) {
                final quiz = _viewModel.lesson.lessonQuizs![index];
                return _buildQuizItem(context, quiz, index);
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: grey2),
                  SizedBox(height: 16),
                  Text(
                    'Không có câu hỏi kiểm tra nào',
                    style: styleMedium.copyWith(color: grey3),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuizItem(BuildContext context, LessonQuizModel quiz, int index) {
    return GestureDetector(
      onTap: () => showQuizDetailScreen(context, quiz),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Số câu hỏi
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Câu ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Câu hỏi
                  Text(
                    quiz.question ?? '',
                    style: styleMedium.copyWith(
                      color: black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Đáp án đúng
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Đáp án đúng:',
                    style: styleSmall.copyWith(color: grey3),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      quiz.answer ?? '',
                      style: styleSmall.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showQuizDetailScreen(BuildContext context, LessonQuizModel quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: grey2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Tiêu đề
                Text(
                  'Chi tiết câu hỏi',
                  style: styleMediumBold.copyWith(
                    fontSize: 18,
                    color: black,
                  ),
                ),
                SizedBox(height: 20),

                // Nội dung câu hỏi
                Text(
                  'Câu hỏi:',
                  style: styleMedium.copyWith(color: grey3),
                ),
                SizedBox(height: 8),
                Text(
                  quiz.question ?? '',
                  style: styleMedium.copyWith(
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Các lựa chọn
                if (quiz.option != null && quiz.option!.isNotEmpty) ...[
                  Text(
                    'Các lựa chọn:',
                    style: styleMedium.copyWith(color: grey3),
                  ),
                  SizedBox(height: 8),
                  ...quiz.getOptions().asMap().entries.map((entry) {
                    int idx = entry.key;
                    String option = entry.value;
                    bool isCorrect = quiz.answer == quiz.getOptionLetter(idx);

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              quiz.getOptionLetter(idx),
                              style: styleMedium.copyWith(
                                color:
                                    isCorrect ? Colors.green.shade700 : grey3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.substring(3), // Bỏ chữ cái đầu và dấu chấm
                              style: styleMedium.copyWith(
                                color: black,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Đáp án đúng
                SizedBox(height: 16),
                Text(
                  'Đáp án đúng:',
                  style: styleMedium.copyWith(color: grey3),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    quiz.answer ?? '',
                    style: styleMedium.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
