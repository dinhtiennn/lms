import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/constanst/constants.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/group_model.dart';
import 'package:collection/collection.dart';
import 'package:lms/src/utils/app_utils.dart';

class TestDetailScreen extends StatefulWidget {
  const TestDetailScreen({Key? key}) : super(key: key);

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  late TestDetailViewModel _viewModel;
  bool _hasShownRules = false;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<TestDetailViewModel>(
        viewModel: TestDetailViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();

            // Hiển thị thông báo nội quy nếu chưa hiển thị
            if (!_hasShownRules) {
              _showTestRules(context);
              _hasShownRules = true;
            }
          });
        },
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () async {
              // Kiểm tra nếu bài kiểm tra đã hoàn thành thì cho phép thoát
              if (_viewModel.test.value?.isSuccess == true) {
                return true;
              }

              // Nếu chưa hoàn thành, hiển thị dialog xác nhận
              final shouldPop = await _showExitConfirmation(context);
              return shouldPop ?? false;
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: _viewModel.violationDetected,
              builder: (context, violationDetected, child) {
                if (violationDetected) {
                  // Nếu phát hiện vi phạm, hiển thị màn hình thông báo vi phạm
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      _showViolationDialog(context);
                    }
                  });
                }

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Làm bài kiểm tra',
                      style: styleLargeBold.copyWith(color: primary2),
                    ),
                    backgroundColor: white,
                    elevation: 0.5,
                    iconTheme: IconThemeData(color: primary2),
                    // Ghi đè hành vi nút back mặc định
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () async {
                        // Kiểm tra nếu bài kiểm tra đã hoàn thành thì cho phép thoát
                        if (_viewModel.test.value?.isSuccess == true) {
                          Navigator.of(context).pop();
                          return;
                        }

                        // Nếu chưa hoàn thành, hiển thị dialog xác nhận
                        final shouldPop = await _showExitConfirmation(context);
                        if (shouldPop == true) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  backgroundColor: white,
                  body: SafeArea(child: _buildBody()),
                  bottomNavigationBar: ValueListenableBuilder<TestModel?>(
                    valueListenable: _viewModel.test,
                    builder: (context, test, _) {
                      if (test?.isSuccess == true) {
                        return SizedBox();
                      }

                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showSubmitConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary2,
                            foregroundColor: white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Nộp bài',
                            style: styleMediumBold.copyWith(color: white),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        });
  }

  // Hiển thị dialog thông báo nội quy kiểm tra
  void _showTestRules(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: Text(
          'Nội quy làm bài kiểm tra',
          style: styleMediumBold.copyWith(color: primary2),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRuleItem(
                '1. Không được rời khỏi màn hình làm bài trong quá trình kiểm tra.',
                Icons.visibility_off_outlined,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '2. Không được chuyển sang ứng dụng khác hoặc đóng ứng dụng.',
                Icons.app_blocking_outlined,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '3. Vi phạm 2 lần sẽ bị khóa bài kiểm tra và không được tiếp tục làm bài.',
                Icons.warning_amber_outlined,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '4. Kiểm tra các câu hỏi và trả lời cẩn thận trước khi nộp bài.',
                Icons.check_circle_outline,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '5. Bài làm sẽ tự động nộp khi hết thời gian quy định.',
                Icons.timer_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tôi đã hiểu',
              style: styleMediumBold.copyWith(color: primary2),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Hiển thị dialog thông báo vi phạm quy định
  void _showViolationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WidgetDialogConfirm(
        title: 'Vi phạm quy định kiểm tra',
        content:
            'Bạn đã vi phạm quy định kiểm tra bằng cách rời khỏi ứng dụng quá lâu. Bài kiểm tra của bạn sẽ bị khóa.',
        colorButtonAccept: error,
        titleStyle: styleMediumBold.copyWith(color: error),
        acceptOnly: true,
        onTapConfirm: () {
          Navigator.of(context).pop(); // Đóng dialog
          if (Get.isRegistered<GroupDetailViewModel>()) {
            Get.find<GroupDetailViewModel>().refreshTest();
          }
          Navigator.of(context).pop(); // Quay lại màn hình trước
        },
      ),
    );
  }

  Widget _buildRuleItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary2, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: styleSmall.copyWith(color: grey2),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<TestDetailModel?>(
      valueListenable: _viewModel.testDetail,
      builder: (context, testDetail, _) {
        if (testDetail == null) {
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
              _buildTestInfoCard(testDetail),
              const SizedBox(height: 24),
              _buildQuestionsList(testDetail.questions ?? []),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestInfoCard(TestDetailModel testDetail) {
    return Card(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    testDetail.title ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary2,
                    ),
                  ),
                ),
                ValueListenableBuilder<TestModel?>(
                  valueListenable: _viewModel.test,
                  builder: (context, test, _) {
                    if (test?.isSuccess == true) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Đã hoàn thành',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              testDetail.description ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 12),
            if (testDetail.expiredAt != null && !AppUtils.isExpired(testDetail.expiredAt))
              _buildCountdownTimer(testDetail.expiredAt!),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: primary2),
                const SizedBox(width: 8),
                Text(
                  'Thời gian bắt đầu: ${_formatDateTime(testDetail.startedAt)}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_off, size: 18, color: primary2),
                const SizedBox(width: 8),
                Text(
                  'Thời gian kết thúc: ${_formatDateTime(testDetail.expiredAt)}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(DateTime expiredAt) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final difference = expiredAt.difference(now);

        if (difference.isNegative) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_off, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text(
                  'Đã hết thời gian',
                  style: styleMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        final hours = difference.inHours;
        final minutes = difference.inMinutes.remainder(60);
        final seconds = difference.inSeconds.remainder(60);

        final isWarning = difference.inMinutes < 5;
        final color = isWarning ? Colors.red : primary2;
        final bgColor = isWarning ? Colors.red.withOpacity(0.1) : primary2.withOpacity(0.1);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: color, size: 18),
              SizedBox(width: 8),
              Text(
                'Thời gian còn lại: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: styleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Widget _buildQuestionsList(List<TestQuestionRequestModel> questions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final question = questions[index];
        return _buildQuestionItem(question, index);
      },
    );
  }

  Widget _buildQuestionItem(TestQuestionRequestModel question, int index) {
    return Card(
      color: white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu hỏi: ${question.content ?? ''}',
                        style: styleMediumBold.copyWith(color: black),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Điểm: ${question.point ?? 0}',
                          style: TextStyle(
                            color: primary2,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuestionOptions(question, index),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionOptions(TestQuestionRequestModel question, int index) {
    final options = _parseOptions(question.options ?? '');
    final questionId = question.id;

    if (question.type == 'SINGLE_CHOICE') {
      return _buildSingleChoiceOptions(questionId: questionId, options: options);
    } else if (question.type == 'MULTIPLE_CHOICE') {
      return _buildMultipleChoiceOptions(questionId: questionId, options: options);
    }

    return const Text('Loại câu hỏi không được hỗ trợ');
  }

  List<String> _parseOptions(String optionsStr) {
    return optionsStr.split(';');
  }

  Widget _buildSingleChoiceOptions({String? questionId, required List<String> options}) {
    return ValueListenableBuilder<List<AnswerModel>?>(
        valueListenable: _viewModel.selectedAnswers,
        builder: (context, selectedAnswers, _) {
          final currentAnswer = selectedAnswers?.firstWhereOrNull((answer) => answer.questionId == questionId);
          final String? selectedOption = currentAnswer?.answer;

          return ValueListenableBuilder<TestModel?>(
              valueListenable: _viewModel.test,
              builder: (context, test, _) {
                // Kiểm tra xem bài kiểm tra đã được hoàn thành hay chưa
                final bool isCompleted = test?.isSuccess == true;

                return Column(
                  children: options.mapIndexed((index, option) {
                    final optionKey = option.split('.').first.trim();
                    final optionText =
                        option.split('.').length > 1 ? option.substring(option.indexOf('.') + 1).trim() : option;

                    final isSelected = selectedOption == optionKey;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primary2 : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        color: isSelected ? primary2.withOpacity(0.05) : white,
                      ),
                      child: RadioListTile<String>(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: optionKey + '. ',
                                style: TextStyle(
                                  color: isSelected ? primary2 : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: optionText,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        value: optionKey,
                        groupValue: selectedOption,
                        activeColor: primary2,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onChanged: isCompleted
                            ? null
                            : (value) {
                                if (value != null) {
                                  _viewModel.addAnswer(AnswerModel(
                                    questionId: questionId ?? '',
                                    answer: value,
                                  ));
                                }
                              },
                      ),
                    );
                  }).toList(),
                );
              });
        });
  }

  Widget _buildMultipleChoiceOptions({String? questionId, required List<String> options}) {
    return ValueListenableBuilder<List<AnswerModel>?>(
        valueListenable: _viewModel.selectedAnswers,
        builder: (context, selectedAnswers, _) {
          final currentAnswer = selectedAnswers?.firstWhereOrNull((answer) => answer.questionId == questionId);

          final List<String> selectedOptions = currentAnswer?.answer.split(',') ?? [];

          return ValueListenableBuilder<TestModel?>(
              valueListenable: _viewModel.test,
              builder: (context, test, _) {
                // Kiểm tra xem bài kiểm tra đã được hoàn thành hay chưa
                final bool isCompleted = test?.isSuccess == true;

                return Column(
                  children: options.mapIndexed((index, option) {
                    final optionKey = option.split('.').first.trim();
                    final optionText =
                        option.split('.').length > 1 ? option.substring(option.indexOf('.') + 1).trim() : option;

                    final isSelected = selectedOptions.contains(optionKey);

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primary2 : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        color: isSelected ? primary2.withOpacity(0.05) : white,
                      ),
                      child: CheckboxListTile(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: optionKey + '. ',
                                style: TextStyle(
                                  color: isSelected ? primary2 : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: optionText,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        value: selectedOptions.contains(optionKey),
                        activeColor: primary2,
                        checkColor: white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onChanged: isCompleted
                            ? null
                            : (bool? value) {
                                if (value == null) return;

                                List<String> newSelections = List.from(selectedOptions);

                                if (value) {
                                  if (!newSelections.contains(optionKey)) {
                                    newSelections.add(optionKey);
                                  }
                                } else {
                                  newSelections.remove(optionKey);
                                }

                                _viewModel.addAnswer(AnswerModel(
                                  questionId: questionId ?? '',
                                  answer: newSelections.join(','),
                                ));
                              },
                      ),
                    );
                  }).toList(),
                );
              });
        });
  }

  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WidgetDialogConfirm(
        title: 'Xác nhận nộp bài',
        content: 'Bạn chắc chắn muốn nộp bài kiểm tra? Hãy kiểm tra lại các câu trả lời trước khi nộp.',
        onTapConfirm: () {
          Navigator.of(context).pop();
          _viewModel.submitTest(context);
        },
        colorButtonAccept: success,
        onTapCancel: () => Navigator.of(context).pop(),
        titleStyle: styleMediumBold.copyWith(color: primary2),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => WidgetDialogConfirm(
        title: 'Xác nhận thoát',
        content: 'Bạn chưa hoàn thành bài kiểm tra. Nếu thoát bây giờ, quá trình làm bài sẽ không được lưu.',
        onTapConfirm: () {
          if (Get.isRegistered<GroupDetailViewModel>()) {
            Get.find<GroupDetailViewModel>().refreshTest();
          }
          Navigator.of(context).pop(true);
        },
        colorButtonAccept: error,
        onTapCancel: () => Navigator.of(context).pop(false),
        titleStyle: styleMediumBold.copyWith(color: primary2),
      ),
    );
  }
}
