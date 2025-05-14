import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/constanst/constants.dart';
import 'package:intl/intl.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/group_model.dart';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({Key? key}) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  late TestResultViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<TestResultViewModel>(
        viewModel: TestResultViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Kết quả bài kiểm tra',
                style: styleMediumBold.copyWith(color: primary2),
              ),
              backgroundColor: white,
              elevation: 0.5,
              iconTheme: IconThemeData(color: primary2),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
            ),
            backgroundColor: white,
            body: SafeArea(child: _buildBody()),
          );
        });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<TestResultModel?>(
      valueListenable: _viewModel.testResult,
      builder: (context, testResult, _) {
        if (testResult == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary2),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultSummary(testResult),
              SizedBox(height: 24),
              _buildAnswersList(testResult),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultSummary(TestResultModel testResult) {
    final testInfo = testResult.testInGroup;
    final score = testResult.score;
    final totalCorrect = testResult.totalCorrect;
    final startedAt = testResult.startedAt;
    final submittedAt = testResult.submittedAt;

    // Tính thời gian làm bài
    String durationText = '';
    if (startedAt != null && submittedAt != null) {
      final duration = submittedAt.difference(startedAt);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      durationText = '$minutes phút $seconds giây';
    }

    return Card(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề bài kiểm tra
            Text(
              testInfo?.title ?? 'Kết quả bài kiểm tra',
              style: styleVeryLargeBold.copyWith(color: primary2),
            ),
            SizedBox(height: 8),
            Text(
              testInfo?.description ?? '',
              style: styleSmall.copyWith(color: grey3),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Tổng quan kết quả
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildScoreCircle(score),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultInfoItem(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        label: 'Số câu đúng',
                        value: '$totalCorrect / ${testResult.testStudentAnswer?.length ?? 0}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _buildResultInfoItem(
              icon: Icons.timer,
              iconColor: primary2,
              label: 'Thời gian làm bài',
              value: durationText,
            ),
            SizedBox(height: 8),
            // Thông tin thời gian
            _buildResultInfoItem(
              icon: Icons.calendar_today,
              iconColor: primary2,
              label: 'Bắt đầu làm',
              value: startedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(startedAt) : '--',
            ),
            SizedBox(height: 8),
            _buildResultInfoItem(
              icon: Icons.check_box,
              iconColor: primary2,
              label: 'Thời gian nộp bài',
              value: submittedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt) : '--',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double? score) {
    final displayScore = score?.toStringAsFixed(1) ?? '0';
    final Color scoreColor =
        score != null ? (score >= 8 ? Colors.green : (score >= 5 ? Colors.orange : Colors.red)) : Colors.grey;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scoreColor.withOpacity(0.1),
        border: Border.all(
          color: scoreColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayScore,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            Text(
              'điểm',
              style: styleSmall.copyWith(color: scoreColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: styleSmall.copyWith(color: grey),
        ),
        Text(
          value,
          style: styleSmall.copyWith(color: black),
        ),
      ],
    );
  }

  Widget _buildAnswersList(TestResultModel testResult) {
    final answers = testResult.testStudentAnswer;
    if (answers == null || answers.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu câu trả lời',
          style: styleSmall.copyWith(color: grey3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết câu trả lời',
          style: styleLargeBold.copyWith(color: primary2),
        ),
        SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: answers.length,
          separatorBuilder: (_, __) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildAnswerItem(answers[index], index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildAnswerItem(TestStudentAnswer answer, int questionNumber) {
    final question = answer.testQuestion;
    final isCorrect = answer.correct ?? false;
    final userAnswer = answer.answer ?? '';
    final correctAnswer = question?.correctAnswers ?? '';

    return Card(
      elevation: 1,
      color: white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với số câu và điểm
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Câu $questionNumber',
                    style: styleSmall.copyWith(color: isCorrect ? Colors.green : Colors.red),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${question?.point ?? 0} điểm',
                    style: styleVerySmall.copyWith(color: primary2),
                  ),
                ),
                Spacer(),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(height: 12),

            // Nội dung câu hỏi
            Text(
              question?.content ?? '',
              style: styleMediumBold.copyWith(color: grey),
            ),
            SizedBox(height: 16),

            // Loại câu hỏi và các lựa chọn
            if (question?.options != null && question!.options!.isNotEmpty)
              _buildOptionsWithAnswer(
                question.options!,
                userAnswer,
                correctAnswer,
                question.type ?? '',
              ),

            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),

            // Câu trả lời của bạn và đáp án đúng
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu trả lời của bạn:',
                        style: styleSmall.copyWith(color: grey3),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userAnswer,
                        style: styleMediumBold.copyWith(
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đáp án đúng:',
                        style: styleSmall.copyWith(color: grey3),
                      ),
                      SizedBox(height: 4),
                      Text(
                        correctAnswer,
                        style: styleMediumBold.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsWithAnswer(
    String options,
    String userAnswer,
    String correctAnswer,
    String questionType,
  ) {
    // Phân tích các lựa chọn
    final optionsList = options.split(';');
    final userAnswers = userAnswer.split(',');
    final correctAnswers = correctAnswer.split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: optionsList.map((option) {
        // Lấy ký tự lựa chọn (A, B, C, ...)
        final optionKey = option.split('.').first.trim();
        final optionText = option.split('.').length > 1 ? option.substring(option.indexOf('.') + 1).trim() : option;

        // Xác định trạng thái của lựa chọn này
        final isUserSelected = userAnswers.contains(optionKey);
        final isCorrectOption = correctAnswers.contains(optionKey);

        // Quyết định màu sắc và icon cho lựa chọn
        Color optionColor = Colors.grey;
        IconData? trailingIcon;

        if (isUserSelected && isCorrectOption) {
          // Người dùng chọn đúng
          optionColor = Colors.green;
          trailingIcon = Icons.check_circle;
        } else if (isUserSelected && !isCorrectOption) {
          // Người dùng chọn sai
          optionColor = Colors.red;
          trailingIcon = Icons.cancel;
        } else if (!isUserSelected && isCorrectOption) {
          // Đáp án đúng mà người dùng không chọn
          optionColor = Colors.green;
          trailingIcon = Icons.check_circle_outline;
        }

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: optionColor.withOpacity(0.5),
              width: 1,
            ),
            color: optionColor.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Text(
                '$optionKey.',
                style: styleSmall.copyWith(color: optionColor),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  optionText,
                  style: styleSmall.copyWith(color: black),
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon, color: optionColor, size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }
}
