import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/widgets/date_picker/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';

class EditTestScreen extends StatefulWidget {
  const EditTestScreen({Key? key}) : super(key: key);

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late EditTestViewModel _viewModel;
  int _maxScore = 100; // Mặc định là thang điểm 100
  int _totalScore = 0;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<EditTestViewModel>(
        viewModel: EditTestViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
            // Tính toán tổng điểm ban đầu sau khi câu hỏi được tải
            _viewModel.questions.addListener(() {
              _updateTotalScore();
            });
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: ValueListenableBuilder(
                valueListenable: _viewModel.test,
                builder: (context, test, child) => Text(
                  'Chỉnh sửa bài kiểm tra',
                  style: styleLargeBold.copyWith(color: white),
                ),
              ),
              backgroundColor: primary2,
              actions: [
                IconButton(
                    onPressed: _showAddQuestionDialog,
                    icon: Icon(
                      Icons.add,
                      color: white,
                    ))
              ],
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return Form(
      key: _viewModel.formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.titleTest,
                      titleText: 'Tiêu đề',
                      borderRadius: BorderRadius.circular(12),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      style: styleSmall.copyWith(color: grey2),
                      validator: AppValid.validateRequireEnter(
                          titleValid: 'Vui lòng nhập tiêu đề'),
                    ),
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.descriptionTest,
                      titleText: 'Mô tả',
                      borderRadius: BorderRadius.circular(12),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      style: styleSmall.copyWith(color: grey2),
                      maxLines: 3,
                      validator: AppValid.validateRequireEnter(
                          titleValid: 'Vui lòng nhập mô tả'),
                    ),
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.startDateController,
                      titleText: 'Ngày bắt đầu',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Chọn ngày bắt đầu',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      readOnly: true,
                      onTap: () => _buildBottomSheetSelectDate(
                          _viewModel.startDateController),
                      suffix: _viewModel.startDateController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: grey2),
                              onPressed: () {
                                setState(() {
                                  _viewModel.startDateController.clear();
                                });
                              },
                            )
                          : null,
                      validator: (value) => AppValid.validateEndDate(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.startTimeController,
                      titleText: 'Thời điểm bắt đầu',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Thời điểm bắt đầu',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      readOnly: true,
                      onTap: () => _buildBottomSheetSelectTime(
                          _viewModel.startTimeController),
                      suffix: _viewModel.startTimeController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: grey2),
                              onPressed: () {
                                setState(() {
                                  _viewModel.startTimeController.clear();
                                });
                              },
                            )
                          : null,
                      validator: (value) => AppValid.validateStartTime(
                        _viewModel.startDateController.text,
                        value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.expiredAtDateController,
                      titleText: 'Ngày hết hạn',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Chọn ngày hết hạn',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      readOnly: true,
                      onTap: () => _buildBottomSheetSelectDate(
                          _viewModel.expiredAtDateController),
                      suffix: _viewModel.expiredAtDateController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: grey2),
                              onPressed: () {
                                setState(() {
                                  _viewModel.expiredAtDateController.clear();
                                });
                              },
                            )
                          : null,
                      validator: (value) => AppValid.validateEndDate(
                        _viewModel.startDateController.text,
                        value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WidgetInput(
                      controller: _viewModel.expiredAtTimeController,
                      titleText: 'Thời điểm hết hạn',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Thời điểm hết hạn',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      readOnly: true,
                      onTap: () => _buildBottomSheetSelectTime(
                          _viewModel.expiredAtTimeController),
                      suffix: _viewModel.expiredAtTimeController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: grey2),
                              onPressed: () {
                                setState(() {
                                  _viewModel.expiredAtTimeController.clear();
                                });
                              },
                            )
                          : null,
                      validator: (value) => AppValid.validateEndTime(
                        _viewModel.startDateController.text,
                        _viewModel.startTimeController.text,
                        _viewModel.expiredAtDateController.text,
                        value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScoreTypeSelector(),
                    const SizedBox(height: 16),
                    _buildQuestionList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                      valueListenable: _viewModel.isUpdating,
                      builder: (context, isUpdating, _) {
                        return ElevatedButton(
                          onPressed: isUpdating
                              ? null
                              : () {
                                  if (_viewModel.formKey.currentState
                                          ?.validate() ??
                                      false) {
                                    if (_viewModel.questions.value.isEmpty) {
                                      _viewModel.showToast(
                                          title: 'Vui lòng thêm câu hỏi',
                                          type: ToastificationType.warning);
                                    } else if (_totalScore < _maxScore) {
                                      _viewModel.showToast(
                                          title:
                                              'Chưa đạt điểm tối đa, vui lòng thêm câu hỏi',
                                          type: ToastificationType.warning);
                                    } else if (_totalScore > _maxScore) {
                                      _viewModel.showToast(
                                          title:
                                              'Điểm hiện tại lớn hơn điểm tối đa!',
                                          type: ToastificationType.warning);
                                    } else {
                                      // Kiểm tra thời gian hiện tại so với thời gian bắt đầu ban đầu của bài kiểm tra
                                      if (_viewModel.test.value?.startedAt !=
                                          null) {
                                        final DateTime now = DateTime.now();
                                        final DateTime originalStartTime =
                                            _viewModel.test.value!.startedAt!;

                                        if (now.isAfter(originalStartTime)) {
                                          _viewModel.showToast(
                                              title:
                                                  'Đã hết thời hạn cập nhật bài kiểm tra',
                                              type: ToastificationType.error);
                                          return;
                                        }
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            WidgetDialogConfirm(
                                          titleStyle: styleMediumBold.copyWith(
                                              color: primary3),
                                          colorButtonAccept: primary3,
                                          title: 'Xác nhận thay đổi',
                                          onTapConfirm: () {
                                            Navigator.pop(context);
                                            _viewModel.updateTest(context);
                                          },
                                          content: '',
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primary2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(vertical: 16)),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(white),
                                  ),
                                )
                              : Text('Lưu thay đổi',
                                  style:
                                      styleMediumBold.copyWith(color: white)),
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateTotalScore() {
    setState(() {
      _totalScore = _viewModel.questions.value.fold(
          0,
          (sum, question) =>
              question.point != null ? sum + question.point! : sum);
    });
  }

  void _buildBottomSheetSelectDate(TextEditingController controller) {
    List<String> date = controller.text.isNotEmpty
        ? controller.text.split('/')
        : [
            '${DateTime.now().day}',
            '${DateTime.now().month}',
            '${DateTime.now().year}'
          ];
    picker.DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(DateTime.now().year + 5),
        theme: picker.DatePickerTheme(
            header: Text(
              'Chọn ngày',
              style: styleLargeBold.copyWith(color: Colors.black),
            ),
            headerColor: Colors.white,
            backgroundColor: Colors.white,
            itemStyle: const TextStyle(
                color: grey2, fontWeight: FontWeight.w500, fontSize: 18),
            doneStyle: const TextStyle(color: Colors.black, fontSize: 16)),
        onConfirm: (date) {
      setState(() {
        controller.text =
            '${date.day < 10 ? '0${date.day}' : date.day}/${date.month < 10 ? '0${date.month}' : date.month}/${date.year < 10 ? '0${date.year}' : date.year}';
      });
    },
        currentTime: DateTime(
            int.parse(date[2]), int.parse(date[1]), int.parse(date[0])),
        locale: picker.LocaleType.vi);
  }

  void _buildBottomSheetSelectTime(TextEditingController controller) {
    List<String> time = controller.text.isNotEmpty
        ? controller.text.split(':')
        : ['${DateTime.now().hour}', '${DateTime.now().minute}'];

    picker.DatePicker.showTimePicker(context,
        showTitleActions: true, showSecondsColumn: false, onConfirm: (date) {
      controller.text =
          '${(date.hour < 10) ? '0${date.hour}' : date.hour}:${(date.minute < 10) ? '0${date.minute}' : date.minute}';
    },
        currentTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(time[0]),
          int.parse(time[1]),
        ));
  }

  Widget _buildScoreTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Loại điểm', style: styleSmall.copyWith(color: grey2)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _maxScore = 100;
                    _updateTotalScore();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _maxScore == 100
                        ? primary2.withAlpha((255 * 0.1).round())
                        : Colors.transparent,
                    border: Border.all(
                      color: _maxScore == 100 ? primary2 : grey4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Thang điểm 100',
                      style: styleSmall.copyWith(
                        color: _maxScore == 100 ? primary2 : grey2,
                        fontWeight: _maxScore == 100
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _maxScore = 10;
                    _updateTotalScore();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _maxScore == 10
                        ? primary2.withAlpha((255 * 0.1).round())
                        : Colors.transparent,
                    border: Border.all(
                      color: _maxScore == 10 ? primary2 : grey4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Thang điểm 10',
                      style: styleSmall.copyWith(
                        color: _maxScore == 10 ? primary2 : grey2,
                        fontWeight: _maxScore == 10
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Tổng điểm: $_totalScore/$_maxScore',
          style: styleSmall.copyWith(
            color: _totalScore > _maxScore ? Colors.red : grey2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionList() {
    return ValueListenableBuilder<List<TestQuestionRequestModel>>(
        valueListenable: _viewModel.questions,
        builder: (context, questions, child) {
          if (questions.isEmpty) {
            return Center(
              child: Text(
                'Chưa có câu hỏi. Hãy thêm câu hỏi bằng cách nhấn vào nút (+) ở thanh tiêu đề',
                style: styleSmall.copyWith(color: grey2),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh sách câu hỏi',
                  style: styleLargeBold.copyWith(color: primary2)),
              const SizedBox(height: 12),
              ...List.generate(questions.length, (index) {
                final question = questions[index];
                return Card(
                  color: white,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Câu ${index + 1}',
                                style: styleMediumBold.copyWith(color: grey2)),
                            Row(
                              children: [
                                Text(
                                  '${question.point} điểm',
                                  style: styleSmall.copyWith(
                                    color: _totalScore > _maxScore
                                        ? Colors.red
                                        : grey2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.edit, color: primary2),
                                  onPressed: () {
                                    _showEditQuestionDialog(index, question);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteQuestionDialog(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text('Nội dung: ${question.content}',
                            style: styleSmall.copyWith(color: grey3)),
                        Text(
                            'Loại: ${AppUtils.getQuestionTypeText(question.type ?? '')}',
                            style: styleSmall.copyWith(color: grey3)),
                        if (question.type != 'text') ...[
                          Text('Đáp án: ${question.correctAnswers}',
                              style: styleSmall.copyWith(color: grey3)),
                          SizedBox(height: 8),
                          Text('Các lựa chọn:',
                              style: styleSmall.copyWith(color: grey3)),
                          ...(question.options ?? '')
                              .split(';')
                              .map((option) => Padding(
                                    padding: EdgeInsets.only(left: 16, top: 4),
                                    child: Text(option,
                                        style:
                                            styleSmall.copyWith(color: grey3)),
                                  ))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        });
  }

  void _showDeleteQuestionDialog(int index) {
    // Kiểm tra thời gian hiện tại so với thời gian bắt đầu ban đầu của bài kiểm tra
    if (_viewModel.test.value?.startedAt != null) {
      final DateTime now = DateTime.now();
      final DateTime originalStartTime = _viewModel.test.value!.startedAt!;

      if (now.isAfter(originalStartTime)) {
        _viewModel.showToast(
            title: 'Đã hết thời hạn cập nhật bài kiểm tra',
            type: ToastificationType.error);
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title:
            Text('Xóa câu hỏi', style: styleMediumBold.copyWith(color: grey2)),
        content: Text(
          'Bạn có chắc chắn muốn xóa câu hỏi này?',
          style: styleSmall.copyWith(color: grey3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: styleSmall.copyWith(color: grey2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _viewModel.removeQuestion(index);
              _updateTotalScore();
              Navigator.pop(context);
            },
            child: Text('Xóa', style: styleSmall.copyWith(color: white)),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionDialog() {
    // Kiểm tra thời gian hiện tại so với thời gian bắt đầu ban đầu của bài kiểm tra
    if (_viewModel.test.value?.startedAt != null) {
      final DateTime now = DateTime.now();
      final DateTime originalStartTime = _viewModel.test.value!.startedAt!;

      if (now.isAfter(originalStartTime)) {
        _viewModel.showToast(
            title: 'Đã hết thời hạn cập nhật bài kiểm tra',
            type: ToastificationType.error);
        return;
      }
    }

    final TextEditingController contentController = TextEditingController();
    final TextEditingController pointController = TextEditingController();
    String selectedType = 'SINGLE_CHOICE';
    List<String> options = ['A', 'B'];
    List<String> correctAnswers = [];
    List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Thêm câu hỏi mới',
                        style: styleMediumBold.copyWith(color: grey2)),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      backgroundColor: white,
                      builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 40,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                titleTextStyle:
                                    styleSmall.copyWith(color: grey2),
                                title: Text('Chọn một đáp án'),
                                onTap: () {
                                  setState(() {
                                    selectedType = 'SINGLE_CHOICE';
                                    if (options.isEmpty) {
                                      options = ['A', 'B'];
                                      optionControllers = [
                                        TextEditingController(),
                                        TextEditingController(),
                                      ];
                                    }
                                    correctAnswers = [];
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                titleTextStyle:
                                    styleSmall.copyWith(color: grey2),
                                title: Text('Chọn nhiều đáp án'),
                                onTap: () {
                                  setState(() {
                                    selectedType = 'MULTIPLE_CHOICE';
                                    if (options.isEmpty) {
                                      options = ['A', 'B'];
                                      optionControllers = [
                                        TextEditingController(),
                                        TextEditingController(),
                                      ];
                                    }
                                    correctAnswers = [];
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: grey5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppUtils.getQuestionTypeText(selectedType),
                          style: styleSmall.copyWith(color: grey2),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: grey3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                WidgetInput(
                  titleStyle: styleSmall.copyWith(color: grey2),
                  hintStyle: styleVerySmall.copyWith(color: grey4),
                  borderColor: grey5,
                  style: styleSmall.copyWith(color: grey2),
                  controller: contentController,
                  titleText: 'Nội dung câu hỏi',
                  borderRadius: BorderRadius.circular(12),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                WidgetInput(
                  controller: pointController,
                  titleStyle: styleSmall.copyWith(color: grey2),
                  hintStyle: styleVerySmall.copyWith(color: grey4),
                  borderColor: grey5,
                  style: styleSmall.copyWith(color: grey2),
                  titleText: 'Điểm (tối đa: ${_maxScore - _totalScore})',
                  borderRadius: BorderRadius.circular(12),
                  textInputType: TextInputType.number,
                ),
                if (selectedType != 'text') ...[
                  SizedBox(height: 16),
                  ...List.generate(options.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: WidgetInput(
                              titleStyle: styleSmall.copyWith(color: grey2),
                              hintStyle: styleVerySmall.copyWith(color: grey4),
                              borderColor: grey5,
                              style: styleSmall.copyWith(color: grey2),
                              controller: optionControllers[index],
                              titleText: 'Lựa chọn ${options[index]}',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          if (index >= 2)
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  // Lưu lại đáp án đúng trước khi xóa
                                  List<String> oldCorrectAnswers =
                                      List.from(correctAnswers);

                                  // Xóa lựa chọn và controller
                                  String removedOption =
                                      options.removeAt(index);
                                  optionControllers.removeAt(index);

                                  // Xóa đáp án khỏi danh sách các đáp án đúng nếu có
                                  correctAnswers.remove(removedOption);

                                  // Cập nhật lại các chữ cái từ A đến Z cho các lựa chọn
                                  List<String> newOptions = List.generate(
                                      options.length,
                                      (i) => String.fromCharCode(
                                          65 + i) // A=65, B=66, ...
                                      );

                                  // Cập nhật lại danh sách đáp án đúng với các chữ cái mới
                                  List<String> newCorrectAnswers = [];
                                  for (int i = 0;
                                      i < oldCorrectAnswers.length;
                                      i++) {
                                    if (oldCorrectAnswers[i] != removedOption) {
                                      // Tìm vị trí của đáp án cũ trong options ban đầu
                                      // để map sang vị trí mới
                                      int oldIndex =
                                          options.indexOf(oldCorrectAnswers[i]);
                                      if (oldIndex != -1 &&
                                          oldIndex < newOptions.length) {
                                        newCorrectAnswers
                                            .add(newOptions[oldIndex]);
                                      }
                                    }
                                  }

                                  // Cập nhật options và correctAnswers
                                  options = newOptions;
                                  correctAnswers = newCorrectAnswers;
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  if (options.length < 10)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          options.add(String.fromCharCode(65 + options.length));
                          optionControllers.add(TextEditingController());
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: primary,
                      ),
                      label: Text(
                        'Thêm lựa chọn',
                        style: styleSmall.copyWith(color: primary),
                      ),
                    ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: options.map((option) {
                      return FilterChip(
                        label: Text(option,
                            style: styleSmall.copyWith(color: grey2)),
                        backgroundColor: white,
                        selectedColor: success,
                        side: BorderSide(color: grey5),
                        selected: correctAnswers.contains(option),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (selectedType == 'SINGLE_CHOICE') {
                                correctAnswers = [option];
                              } else {
                                correctAnswers.add(option);
                              }
                            } else {
                              correctAnswers.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (contentController.text.isEmpty ||
                              pointController.text.isEmpty) {
                            _viewModel.showToast(
                                title: 'Vui lòng điền đầy đủ thông tin',
                                type: ToastificationType.warning);
                            return;
                          }

                          if (selectedType != 'text' &&
                              correctAnswers.isEmpty) {
                            _viewModel.showToast(
                                title: 'Vui lòng chọn ít nhất một đáp án đúng',
                                type: ToastificationType.warning);
                            return;
                          }

                          if (selectedType != 'text') {
                            for (var controller in optionControllers) {
                              if (controller.text.isEmpty) {
                                _viewModel.showToast(
                                    title:
                                        'Vui lòng điền đầy đủ nội dung các lựa chọn',
                                    type: ToastificationType.warning);
                                return;
                              }
                            }
                          }

                          int point;
                          try {
                            point = int.parse(pointController.text);
                            if (point <= 0) {
                              _viewModel.showToast(
                                  title: 'Điểm phải lớn hơn 0',
                                  type: ToastificationType.warning);
                              return;
                            }
                          } catch (e) {
                            _viewModel.showToast(
                                title: 'Điểm phải là số nguyên',
                                type: ToastificationType.warning);
                            return;
                          }

                          if (_totalScore + point > _maxScore) {
                            _viewModel.showToast(
                                title:
                                    'Tổng điểm không được vượt quá $_maxScore',
                                type: ToastificationType.warning);
                            return;
                          }

                          TestQuestionRequestModel newQuestion =
                              TestQuestionRequestModel(
                            content: contentController.text,
                            point: point,
                            type: selectedType,
                            options: selectedType == 'text'
                                ? ''
                                : options
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        '${e.value}. ${optionControllers[e.key].text}')
                                    .join(';'),
                            correctAnswers: selectedType == 'text'
                                ? ''
                                : correctAnswers.join(','),
                          );

                          _viewModel.addQuestion(newQuestion);
                          _updateTotalScore();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Thêm',
                            style: styleMediumBold.copyWith(color: white)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditQuestionDialog(int index, TestQuestionRequestModel question) {
    // Kiểm tra thời gian hiện tại so với thời gian bắt đầu ban đầu của bài kiểm tra
    if (_viewModel.test.value?.startedAt != null) {
      final DateTime now = DateTime.now();
      final DateTime originalStartTime = _viewModel.test.value!.startedAt!;

      if (now.isAfter(originalStartTime)) {
        _viewModel.showToast(
            title: 'Đã hết thời hạn cập nhật bài kiểm tra',
            type: ToastificationType.error);
        return;
      }
    }

    final TextEditingController contentController =
        TextEditingController(text: question.content);
    final TextEditingController pointController =
        TextEditingController(text: question.point?.toString());
    String selectedType = question.type ?? 'SINGLE_CHOICE';

    // Lấy danh sách lựa chọn từ options string
    List<String> optionsText = selectedType != 'text' &&
            question.options != null &&
            question.options!.isNotEmpty
        ? question.options!.split(';')
        : [];

    // Tạo danh sách các chữ cái cho các lựa chọn (A, B, C, ...)
    List<String> options = optionsText.isNotEmpty
        ? optionsText.map((opt) => opt.split('.').first.trim()).toList()
        : ['A', 'B'];

    // Nếu không có lựa chọn nào, tạo mặc định
    if (options.isEmpty && selectedType != 'text') {
      options = ['A', 'B'];
    }

    // Tạo danh sách các controller cho các lựa chọn
    List<TextEditingController> optionControllers = [];

    if (selectedType != 'text') {
      if (optionsText.isNotEmpty) {
        // Nếu có lựa chọn, lấy nội dung sau dấu '.'
        optionControllers = optionsText.map((opt) {
          final parts = opt.split('.');
          return TextEditingController(
              text: parts.length > 1 ? parts.sublist(1).join('.').trim() : '');
        }).toList();
      } else {
        // Nếu không có lựa chọn, tạo controllers rỗng
        optionControllers =
            List.generate(options.length, (_) => TextEditingController());
      }
    }

    // Lấy danh sách các đáp án đúng
    List<String> correctAnswers =
        selectedType != 'text' && question.correctAnswers != null
            ? question.correctAnswers!.split(',')
            : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chỉnh sửa câu hỏi',
                        style: styleMediumBold.copyWith(color: grey2)),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Hiển thị loại câu hỏi (không cho phép thay đổi)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: grey5),
                    borderRadius: BorderRadius.circular(12),
                    color: grey5.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loại câu hỏi: ${AppUtils.getQuestionTypeText(selectedType)}',
                        style: styleSmall.copyWith(color: grey2),
                      ),
                      Icon(
                        Icons.lock,
                        color: grey3,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                WidgetInput(
                  titleStyle: styleSmall.copyWith(color: grey2),
                  hintStyle: styleVerySmall.copyWith(color: grey4),
                  borderColor: grey5,
                  style: styleSmall.copyWith(color: grey2),
                  controller: contentController,
                  titleText: 'Nội dung câu hỏi',
                  borderRadius: BorderRadius.circular(12),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                WidgetInput(
                  controller: pointController,
                  titleStyle: styleSmall.copyWith(color: grey2),
                  hintStyle: styleVerySmall.copyWith(color: grey4),
                  borderColor: grey5,
                  style: styleSmall.copyWith(color: grey2),
                  titleText:
                      'Điểm (tối đa: ${_maxScore - _totalScore + (question.point ?? 0)})',
                  borderRadius: BorderRadius.circular(12),
                  textInputType: TextInputType.number,
                ),
                if (selectedType != 'text') ...[
                  SizedBox(height: 16),
                  Text(
                    'Các lựa chọn',
                    style: styleMediumBold.copyWith(color: grey2),
                  ),
                  SizedBox(height: 8),
                  ...List.generate(options.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: WidgetInput(
                              titleStyle: styleSmall.copyWith(color: grey2),
                              hintStyle: styleVerySmall.copyWith(color: grey4),
                              borderColor: grey5,
                              style: styleSmall.copyWith(color: grey2),
                              controller: index < optionControllers.length
                                  ? optionControllers[index]
                                  : TextEditingController(),
                              titleText: 'Lựa chọn ${options[index]}',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          if (index >= 2)
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  // Lưu lại đáp án đúng trước khi xóa
                                  List<String> oldCorrectAnswers =
                                      List.from(correctAnswers);
                                  Map<String, int> oldOptionsIndex = {};

                                  // Lưu index của các options cũ
                                  for (int i = 0; i < options.length; i++) {
                                    oldOptionsIndex[options[i]] = i;
                                  }

                                  // Xóa lựa chọn và controller
                                  String removedOption =
                                      options.removeAt(index);
                                  optionControllers.removeAt(index);

                                  // Xóa đáp án khỏi danh sách các đáp án đúng nếu có
                                  correctAnswers.remove(removedOption);

                                  // Cập nhật lại các chữ cái từ A đến Z cho các lựa chọn
                                  List<String> newOptions = List.generate(
                                      options.length,
                                      (i) => String.fromCharCode(
                                          65 + i) // A=65, B=66, ...
                                      );

                                  // Tạo map từ option cũ sang option mới
                                  Map<String, String> optionMapping = {};
                                  for (int i = 0; i < options.length; i++) {
                                    String oldOption = options[i];
                                    String newOption = newOptions[i];
                                    optionMapping[oldOption] = newOption;
                                  }

                                  // Cập nhật lại danh sách đáp án đúng
                                  List<String> newCorrectAnswers = [];
                                  for (String answer in oldCorrectAnswers) {
                                    if (answer != removedOption &&
                                        optionMapping.containsKey(answer)) {
                                      newCorrectAnswers
                                          .add(optionMapping[answer]!);
                                    }
                                  }

                                  // Cập nhật options và correctAnswers
                                  options = newOptions;
                                  correctAnswers = newCorrectAnswers;
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  if (options.length < 10)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          options.add(String.fromCharCode(65 + options.length));
                          optionControllers.add(TextEditingController());
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: primary,
                      ),
                      label: Text(
                        'Thêm lựa chọn',
                        style: styleSmall.copyWith(color: primary),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Đáp án đúng',
                    style: styleMediumBold.copyWith(color: grey2),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: options.map((option) {
                      return FilterChip(
                        label: Text(option,
                            style: styleSmall.copyWith(color: grey2)),
                        backgroundColor: white,
                        selectedColor: success,
                        side: BorderSide(color: grey5),
                        selected: correctAnswers.contains(option),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (selectedType == 'SINGLE_CHOICE') {
                                correctAnswers = [option];
                              } else {
                                correctAnswers.add(option);
                              }
                            } else {
                              correctAnswers.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Kiểm tra thông tin không được rỗng (giống với thêm câu hỏi)
                          if (contentController.text.isEmpty ||
                              pointController.text.isEmpty) {
                            _viewModel.showToast(
                                title: 'Vui lòng điền đầy đủ thông tin',
                                type: ToastificationType.warning);
                            return;
                          }

                          // Kiểm tra đáp án đúng được chọn (giống với thêm câu hỏi)
                          if (selectedType != 'text' &&
                              correctAnswers.isEmpty) {
                            _viewModel.showToast(
                                title: 'Vui lòng chọn ít nhất một đáp án đúng',
                                type: ToastificationType.warning);
                            return;
                          }

                          // Kiểm tra nội dung các lựa chọn (giống với thêm câu hỏi)
                          if (selectedType != 'text') {
                            for (var controller in optionControllers) {
                              if (controller.text.isEmpty) {
                                _viewModel.showToast(
                                    title:
                                        'Vui lòng điền đầy đủ nội dung các lựa chọn',
                                    type: ToastificationType.warning);
                                return;
                              }
                            }
                          }

                          // Kiểm tra điểm hợp lệ (giống với thêm câu hỏi)
                          int point;
                          try {
                            point = int.parse(pointController.text);
                            if (point <= 0) {
                              _viewModel.showToast(
                                  title: 'Điểm phải lớn hơn 0',
                                  type: ToastificationType.warning);
                              return;
                            }
                          } catch (e) {
                            _viewModel.showToast(
                                title: 'Điểm phải là số nguyên',
                                type: ToastificationType.warning);
                            return;
                          }

                          // Tính lại tổng điểm trừ đi điểm ban đầu của câu hỏi
                          int newTotalScore =
                              _totalScore - (question.point ?? 0) + point;
                          if (newTotalScore > _maxScore) {
                            _viewModel.showToast(
                                title:
                                    'Tổng điểm không được vượt quá $_maxScore',
                                type: ToastificationType.warning);
                            return;
                          }

                          // Tạo câu hỏi mới với thông tin đã cập nhật
                          TestQuestionRequestModel updatedQuestion =
                              TestQuestionRequestModel(
                            id: question.id,
                            content: contentController.text,
                            point: point,
                            type: selectedType,
                            options: selectedType == 'text'
                                ? ''
                                : options
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        '${e.value}. ${optionControllers[e.key].text}')
                                    .join(';'),
                            correctAnswers: selectedType == 'text'
                                ? ''
                                : correctAnswers.join(','),
                          );

                          if (updatedQuestion.type != 'text') {
                            if (updatedQuestion.options != null) {
                              updatedQuestion.options!
                                  .split(';')
                                  .forEach((option) => print('  - $option'));
                            }
                          }
                          // Cập nhật mềm câu hỏi vào danh sách
                          _viewModel.updateQuestion(index, updatedQuestion);

                          // Cập nhật lại tổng điểm hiển thị
                          _updateTotalScore();

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Lưu thay đổi',
                            style: styleMediumBold.copyWith(color: white)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: styleSmallBold.copyWith(color: grey2),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: styleSmall.copyWith(color: black),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllQuestionsDialog(List<TestQuestionRequestModel> questions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chi tiết tất cả câu hỏi',
          style: styleMediumBold.copyWith(color: primary2),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < questions.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: grey5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Câu ${i + 1}',
                              style: styleMediumBold.copyWith(color: primary2),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${questions[i].point} điểm',
                                style: styleSmall.copyWith(
                                  color: primary2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nội dung: ${questions[i].content}',
                          style: styleSmall.copyWith(color: black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loại: ${_viewModel.getQuestionTypeText(questions[i].type ?? '')}',
                          style: styleSmall.copyWith(color: grey2),
                        ),
                        if (questions[i].type != 'text') ...[
                          const SizedBox(height: 4),
                          Text(
                            'Đáp án đúng: ${questions[i].correctAnswers}',
                            style: styleSmall.copyWith(
                              color: success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Các lựa chọn:',
                            style: styleSmall.copyWith(color: grey2),
                          ),
                          const SizedBox(height: 4),
                          if (questions[i].options != null &&
                              questions[i].options!.isNotEmpty)
                            ...questions[i].options!.split(';').map((option) {
                              bool isCorrect = questions[i].correctAnswers !=
                                      null &&
                                  questions[i]
                                      .correctAnswers!
                                      .split(',')
                                      .contains(option.split('.').first.trim());

                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 16,
                                      color: isCorrect ? success : grey3,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: styleSmall.copyWith(
                                          color: isCorrect ? success : grey2,
                                          fontWeight: isCorrect
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: styleSmall.copyWith(color: primary2),
            ),
          ),
        ],
      ),
    );
  }

  void _showApiLogDialog(Map<String, dynamic> testInfo) {
    // Tạo chuỗi JSON dễ đọc
    String apiLog = '''
THÔNG TIN REQUEST API:

URL: /api/tests/${testInfo['testId']}
METHOD: PUT
HEADERS: {
  "Content-Type": "application/json",
  "Authorization": "Bearer [token]"
}

BODY: {
  "title": "${testInfo['title']}",
  "description": "${testInfo['description']}",
  "startedAt": "${DateFormat('yyyy-MM-dd HH:mm:ss').format(testInfo['startedAt'])}",
  "expiredAt": "${DateFormat('yyyy-MM-dd HH:mm:ss').format(testInfo['expiredAt'])}",
  "questions": [
''';

    for (int i = 0; i < testInfo['questions'].length; i++) {
      final question = testInfo['questions'][i];
      apiLog += '''    {
      "id": "${question.id ?? ''}",
      "content": "${question.content}",
      "point": ${question.point},
      "type": "${question.type}",
      "options": "${question.options?.replaceAll('"', '\\"')}",
      "correctAnswers": "${question.correctAnswers}"
    }${i < testInfo['questions'].length - 1 ? ',' : ''}
''';
    }

    apiLog += '''  ]
}''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.code, color: primary2),
            SizedBox(width: 8),
            Text(
              'Log API',
              style: styleMediumBold.copyWith(color: primary2),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              apiLog,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Sao chép vào clipboard
              // Không sử dụng được trong code ví dụ này, nhưng trong ứng dụng thực tế sẽ dùng:
              // Clipboard.setData(ClipboardData(text: apiLog));
              _viewModel.showToast(
                  title: 'Đã sao chép log vào clipboard',
                  type: ToastificationType.success);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 16, color: primary),
                SizedBox(width: 4),
                Text(
                  'Sao chép',
                  style: styleSmall.copyWith(color: primary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: styleSmall.copyWith(color: white),
            ),
          ),
        ],
      ),
    );
  }
}
