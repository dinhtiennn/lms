import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/group_model.dart';
import 'package:lms/src/presentation/widgets/widget_image_network.dart';
import 'package:lms/src/utils/app_utils.dart';

class ResultTestDetailTeacherScreen extends StatefulWidget {
  const ResultTestDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ResultTestDetailTeacherScreen> createState() =>
      _ResultTestDetailTeacherScreenState();
}

class _ResultTestDetailTeacherScreenState
    extends State<ResultTestDetailTeacherScreen> {
  late ResultTestDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ResultTestDetailTeacherViewModel>(
        viewModel: ResultTestDetailTeacherViewModel(),
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
                'Chi tiết bài làm',
                style: styleLargeBold.copyWith(color: white),
              ),
              backgroundColor: primary2,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Get.back(),
              ),
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<TestResultModel?>(
      valueListenable: _viewModel.testResult,
      builder: (context, testResult, child) {
        if (testResult == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentInfo(testResult),
              const SizedBox(height: 20),
              _buildTestSummary(testResult),
              const SizedBox(height: 20),
              _buildAnswers(testResult),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentInfo(TestResultModel testResult) {
    final studentName = testResult.student?.fullName ?? 'Không có tên';
    final studentMajor = testResult.student?.major?.name ?? 'Chưa có ngành';
    final studentEmail = testResult.student?.email ?? 'Không có email';
    final studentAvatar = testResult.student?.avatar;

    return Card(
      elevation: 2,
      color: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin sinh viên',
              style: styleLargeBold.copyWith(color: primary2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Avatar sinh viên
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: primary2.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: WidgetImageNetwork(
                      url: studentAvatar,
                      fit: BoxFit.cover,
                      radiusAll: 33,
                      widgetError: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: primary2.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: primary2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Thông tin sinh viên
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: styleMediumBold.copyWith(color: primary2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school, size: 16, color: grey3),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              studentMajor,
                              style: styleSmall.copyWith(color: grey3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: grey3),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              studentEmail,
                              style: styleSmall.copyWith(color: grey2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  Widget _buildTestSummary(TestResultModel testResult) {
    final score = testResult.score?.toString() ?? '0';
    final totalCorrect = testResult.totalCorrect?.toString() ?? '0';
    final startTime = testResult.startedAt != null
        ? '${testResult.startedAt!.day}/${testResult.startedAt!.month}/${testResult.startedAt!.year} ${testResult.startedAt!.hour}:${testResult.startedAt!.minute < 10 ? '0${testResult.startedAt!.minute}' : testResult.startedAt!.minute}'
        : 'N/A';
    final submitTime = testResult.submittedAt != null
        ? '${testResult.submittedAt!.day}/${testResult.submittedAt!.month}/${testResult.submittedAt!.year} ${testResult.submittedAt!.hour}:${testResult.submittedAt!.minute < 10 ? '0${testResult.submittedAt!.minute}' : testResult.submittedAt!.minute}'
        : 'N/A';
    final duration = testResult.startedAt != null &&
            testResult.submittedAt != null
        ? testResult.submittedAt!.difference(testResult.startedAt!).inMinutes
        : 0;

    return Card(
      elevation: 2,
      color: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kết quả bài làm',
              style: styleLargeBold.copyWith(color: primary2),
            ),
            const SizedBox(height: 16),
            // Thông tin điểm số
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticItem(
                    'Điểm số', score, primary2.withOpacity(0.1), primary2),
                _buildStatisticItem('Số câu đúng', totalCorrect,
                    Colors.green.withOpacity(0.1), Colors.green),
                _buildStatisticItem('Thời gian làm', '$duration phút',
                    Colors.orange.withOpacity(0.1), Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: grey5),
            const SizedBox(height: 16),
            // Thời gian bắt đầu và kết thúc
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline,
                              size: 18, color: primary2),
                          const SizedBox(width: 4),
                          Text(
                            'Bắt đầu làm:',
                            style: styleSmallBold.copyWith(color: grey3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startTime,
                        style: styleSmall.copyWith(color: grey2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Nộp bài:',
                            style: styleSmallBold.copyWith(color: grey3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        submitTime,
                        style: styleSmall.copyWith(color: grey2),
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

  Widget _buildStatisticItem(
      String label, String value, Color bgColor, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: styleSmallBold.copyWith(color: grey3),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: styleMediumBold.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswers(TestResultModel testResult) {
    if (testResult.testStudentAnswer == null ||
        testResult.testStudentAnswer!.isEmpty) {
      return Center(
        child: Text(
          'Không có câu trả lời nào',
          style: styleMedium.copyWith(color: grey3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết các câu trả lời',
          style: styleLargeBold.copyWith(color: primary2),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          testResult.testStudentAnswer!.length,
          (index) =>
              _buildAnswerItem(index + 1, testResult.testStudentAnswer![index]),
        ),
      ],
    );
  }

  Widget _buildAnswerItem(int index, TestStudentAnswer answer) {
    final question = answer.testQuestion;
    final isCorrect = answer.correct ?? false;
    final answerText = answer.answer ?? 'Không có câu trả lời';
    final correctAnswers = question?.correctAnswers ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCorrect
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Câu $index',
                        style: styleMediumBold.copyWith(color: primary2),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check : Icons.close,
                              size: 16,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCorrect ? 'Đúng' : 'Sai',
                              style: styleSmall.copyWith(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${question?.point} điểm',
                      style: styleSmall.copyWith(color: primary2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question?.content ?? 'Không có nội dung',
                style: styleMedium.copyWith(color: grey),
              ),
              const SizedBox(height: 12),
              Text(
                'Loại câu hỏi: ${AppUtils.getQuestionTypeText(question?.type?.toUpperCase() ?? '')}',
                style: styleSmall.copyWith(color: grey3),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: grey5),
              const SizedBox(height: 16),
              if (question?.type != 'text') ...[
                Text(
                  'Các lựa chọn:',
                  style: styleSmallBold.copyWith(color: grey3),
                ),
                const SizedBox(height: 8),
                ..._buildOptions(
                    question?.options ?? '', correctAnswers, answerText),
              ] else ...[
                Text(
                  'Câu trả lời của sinh viên:',
                  style: styleSmallBold.copyWith(color: grey3),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.05)
                        : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    answerText,
                    style: styleSmall.copyWith(
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đáp án đúng:',
                  style: styleSmallBold.copyWith(color: grey3),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    correctAnswers,
                    style: styleSmall.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(
      String options, String correctAnswers, String studentAnswer) {
    final List<String> optionsList = options.split(';');
    final List<String> correctList = correctAnswers.split(',');
    final List<String> studentAnswerList = studentAnswer.split(',');

    return optionsList.map((option) {
      final String optionLetter = option.split('.').first.trim();
      final bool isCorrect = correctList.contains(optionLetter);
      final bool isSelected = studentAnswerList.contains(optionLetter);

      Color textColor = grey2;
      Color iconColor = grey3;
      IconData iconData = Icons.circle_outlined;
      FontWeight fontWeight = FontWeight.normal;

      if (isSelected && isCorrect) {
        // Đáp án đúng và sinh viên đã chọn
        textColor = Colors.green;
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        fontWeight = FontWeight.bold;
      } else if (isSelected && !isCorrect) {
        // Đáp án sai và sinh viên đã chọn
        textColor = Colors.red;
        iconColor = Colors.red;
        iconData = Icons.cancel;
        fontWeight = FontWeight.bold;
      } else if (!isSelected && isCorrect) {
        // Đáp án đúng nhưng sinh viên không chọn
        textColor = Colors.green;
        iconColor = Colors.green;
        iconData = Icons.check_circle_outline;
        fontWeight = FontWeight.bold;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option,
                style: styleSmall.copyWith(
                  color: textColor,
                  fontWeight: fontWeight,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
