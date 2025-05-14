import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/group_model.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/presentation/widgets/widget_image_network.dart';

class TestDetailTeacherScreen extends StatefulWidget {
  const TestDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<TestDetailTeacherScreen> createState() => _TestDetailTeacherScreenState();
}

class _TestDetailTeacherScreenState extends State<TestDetailTeacherScreen> {
  late TestDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<TestDetailTeacherViewModel>(
        viewModel: TestDetailTeacherViewModel(),
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
                'Chi tiết bài kiểm tra',
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
    return ValueListenableBuilder<TestDetailModel?>(
      valueListenable: _viewModel.testDetail,
      builder: (context, testDetail, child) {
        if (testDetail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          controller: _viewModel.scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTestHeader(testDetail),
              const SizedBox(height: 20),
              _buildQuestionsList(testDetail),
              const SizedBox(height: 20),
              _buildStudentSubmissions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestHeader(TestDetailModel testDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary2.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            testDetail.title ?? 'Không có tiêu đề',
            style: styleLargeBold.copyWith(color: primary2),
          ),

          const Divider(height: 24, color: grey5),

          // Mô tả
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              testDetail.description ?? 'Không có mô tả',
              style: styleSmall.copyWith(color: grey2),
            ),
          ),

          const SizedBox(height: 16),

          // Thời gian
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin thời gian',
                  style: styleMediumBold.copyWith(color: primary2),
                ),
                const SizedBox(height: 12),

                // Ngày tạo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.calendar_today, size: 18, color: primary2),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày tạo',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        Text(
                          testDetail.createdAt != null
                              ? '${testDetail.createdAt!.day}/${testDetail.createdAt!.month}/${testDetail.createdAt!.year}'
                              : 'N/A',
                          style: styleMedium.copyWith(color: grey2),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ngày bắt đầu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.start, size: 18, color: primary2),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày bắt đầu',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        Text(
                          testDetail.startedAt != null
                              ? '${testDetail.startedAt!.day}/${testDetail.startedAt!.month}/${testDetail.startedAt!.year} ${testDetail.startedAt!.hour}:${testDetail.startedAt!.minute < 10 ? '0${testDetail.startedAt!.minute}' : testDetail.startedAt!.minute}'
                              : 'N/A',
                          style: styleMedium.copyWith(
                            color: AppUtils.isExpired(testDetail.startedAt) ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Hạn nộp
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.timer, size: 18, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hạn nộp',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        Text(
                          testDetail.expiredAt != null
                              ? '${testDetail.expiredAt!.day}/${testDetail.expiredAt!.month}/${testDetail.expiredAt!.year} ${testDetail.expiredAt!.hour}:${testDetail.expiredAt!.minute < 10 ? '0${testDetail.expiredAt!.minute}' : testDetail.expiredAt!.minute}'
                              : 'N/A',
                          style: styleMedium.copyWith(
                            color: AppUtils.isExpired(testDetail.expiredAt) ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Thống kê
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Số câu hỏi',
                        style: styleSmallBold.copyWith(color: grey3),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primary2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${testDetail.questions?.length ?? 0}',
                          style: styleLargeBold.copyWith(color: primary2),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: grey5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tổng điểm',
                        style: styleSmallBold.copyWith(color: grey3),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_calculateTotalPoints(testDetail)}',
                          style: styleLargeBold.copyWith(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalPoints(TestDetailModel testDetail) {
    if (testDetail.questions == null) return 0;
    return testDetail.questions!.fold(0, (sum, question) => sum + (question.point ?? 0));
  }

  Widget _buildQuestionsList(TestDetailModel testDetail) {
    if (testDetail.questions == null || testDetail.questions!.isEmpty) {
      return Center(
        child: Text(
          'Không có câu hỏi nào',
          style: styleMedium.copyWith(color: grey3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách câu hỏi',
          style: styleLargeBold.copyWith(color: primary2),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          testDetail.questions!.length,
          (index) => _buildQuestionItem(index + 1, testDetail.questions![index]),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(int index, TestQuestionRequestModel question) {
    return Card(
      color: white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu $index',
                  style: styleMediumBold.copyWith(color: primary2),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${question.point} điểm',
                    style: styleSmall.copyWith(color: primary2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.content ?? 'Không có nội dung',
              style: styleMedium.copyWith(color: grey2),
            ),
            const SizedBox(height: 12),
            Text(
              'Loại câu hỏi: ${AppUtils.getQuestionTypeText(question.type?.toUpperCase() ?? '')}',
              style: styleSmall.copyWith(color: grey3),
            ),
            if (question.type != 'text') ...[
              const SizedBox(height: 12),
              Text(
                'Các lựa chọn:',
                style: styleSmallBold.copyWith(color: grey3),
              ),
              const SizedBox(height: 8),
              ..._buildOptions(question.options ?? '', question.correctAnswers ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(String options, String correctAnswers) {
    final List<String> optionsList = options.split(';');
    final List<String> correctList = correctAnswers.split(',');

    return optionsList.map((option) {
      final String optionLetter = option.split('.').first.trim();
      final bool isCorrect = correctList.contains(optionLetter);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.circle_outlined,
              color: isCorrect ? Colors.green : grey3,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option,
                style: styleSmall.copyWith(
                  color: isCorrect ? Colors.green : grey2,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStudentSubmissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách sinh viên đã nộp bài',
          style: styleLargeBold.copyWith(color: primary2),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<TestResultView>?>(
          valueListenable: _viewModel.testResults,
          builder: (context, testResults, _) {
            if (testResults == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (testResults.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Chưa có sinh viên nộp bài',
                    style: styleMedium.copyWith(color: grey3),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testResults.length,
              itemBuilder: (context, index) {
                final result = testResults[index];
                return _buildStudentResultItem(result, index);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentResultItem(TestResultView result, int index) {
    final studentName = result.student?.fullName ?? 'Không có tên';
    final studentMajor = result.student?.major?.name ?? 'Chưa có ngành';
    final studentEmail = result.student?.email ?? 'Không có email';
    final studentAvatar = result.student?.avatar;
    final score = result.score?.toString() ?? '0';
    final totalCorrect = result.totalCorrect?.toString() ?? '0';

    // Thời gian nộp và làm bài
    final startTime = result.startedAt != null
        ? '${result.startedAt!.hour}:${result.startedAt!.minute < 10 ? '0${result.startedAt!.minute}' : result.startedAt!.minute}'
        : '--:--';
    final submitTime = result.submittedAt != null
        ? '${result.submittedAt!.hour}:${result.submittedAt!.minute < 10 ? '0${result.submittedAt!.minute}' : result.submittedAt!.minute}'
        : '--:--';

    // Tính thời gian làm bài (phút)
    final duration = result.startedAt != null && result.submittedAt != null
        ? result.submittedAt!.difference(result.startedAt!).inMinutes
        : 0;

    return InkWell(
      onTap: () {
        _viewModel.resultTestDetail(result);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar sinh viên
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: primary2.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: WidgetImageNetwork(
                        url: studentAvatar,
                        fit: BoxFit.cover,
                        radiusAll: 28,
                        widgetError: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: primary2.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
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
                        Text(
                          studentMajor,
                          style: styleSmall.copyWith(color: grey3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          studentEmail,
                          style: styleSmall.copyWith(color: grey2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: grey5),
              const SizedBox(height: 12),
              // Thông tin điểm số
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Điểm số
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Điểm số',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            score,
                            style: styleMediumBold.copyWith(color: primary2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Số câu đúng
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Câu đúng',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            totalCorrect,
                            style: styleMediumBold.copyWith(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Thời gian làm bài
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Thời gian',
                          style: styleSmallBold.copyWith(color: grey3),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$duration phút',
                            style: styleMediumBold.copyWith(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Thời gian bắt đầu và kết thúc
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 18, color: primary2),
                      const SizedBox(width: 4),
                      Text(
                        'Bắt đầu: $startTime',
                        style: styleSmall.copyWith(color: grey2),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Nộp: $submitTime',
                        style: styleSmall.copyWith(color: grey2),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
