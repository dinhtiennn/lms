import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

void showCreateQuizBottomSheet(BuildContext context, LessonModel lesson,
    CourseDetailTeacherViewModel viewModel) {
  viewModel.initQuiz();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    useSafeArea: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                    'Tạo bài kiểm tra mới',
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
                    viewModel.initQuiz();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh sách câu hỏi
                  ValueListenableBuilder<List<LessonQuizModel>?>(
                    valueListenable: viewModel.quizs,
                    builder: (context, quizs, child) {
                      if (quizs == null) {
                        return const SizedBox();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...quizs.asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final quiz = entry.value;
                              return Card(
                                color: white,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Câu hỏi ${index + 1}',
                                            style: styleSmallBold.copyWith(
                                                color: black),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                viewModel.removeQuiz(index),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Câu hỏi: ${quiz.question}',
                                        style:
                                            styleSmall.copyWith(color: grey2),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Các lựa chọn:',
                                        style: styleSmallBold.copyWith(
                                            color: primary2),
                                      ),
                                      const SizedBox(height: 4),
                                      ...(quiz.option ?? '')
                                          .split(';')
                                          .asMap()
                                          .entries
                                          .map(
                                        (entry) {
                                          final option = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Text(
                                              option,
                                              style: styleSmall.copyWith(
                                                  color: grey2),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Đáp án: ${quiz.answer}',
                                        style: styleSmall.copyWith(
                                            color: successLight),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Form thêm câu hỏi mới
                  Card(
                    color: white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thêm câu hỏi mới',
                            style: styleSmallBold.copyWith(color: black),
                          ),
                          const SizedBox(height: 16),
                          WidgetInput(
                            controller: viewModel.quizQuestionController,
                            titleText: 'Câu hỏi',
                            titleStyle: styleSmallBold.copyWith(color: grey2),
                            maxLines: 10,
                            borderRadius: BorderRadius.circular(12),
                            borderColor: grey5,
                            style: styleSmall.copyWith(color: grey2),
                          ),
                          const SizedBox(height: 16),
                          // options input động
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Các lựa chọn',
                                    style:
                                        styleSmallBold.copyWith(color: black),
                                  ),
                                  ValueListenableBuilder<
                                      List<TextEditingController>>(
                                    valueListenable:
                                        viewModel.quizOptionControllers,
                                    builder: (context, controllers, child) {
                                      if (controllers.length < 6) {
                                        return TextButton.icon(
                                          onPressed: () =>
                                              viewModel.addOption(),
                                          icon: const Icon(Icons.add,
                                              color: primary2),
                                          label: Text(
                                            'Thêm lựa chọn',
                                            style: styleSmall.copyWith(
                                                color: primary2),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<
                                  List<TextEditingController>>(
                                valueListenable:
                                    viewModel.quizOptionControllers,
                                builder: (context, controllers, child) {
                                  return Column(
                                    children: controllers.asMap().entries.map(
                                      (entry) {
                                        final index = entry.key;
                                        final controller = entry.value;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: primary2,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    String.fromCharCode(
                                                        65 + index),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: WidgetInput(
                                                  controller: controller,
                                                  hintText:
                                                      'Nhập lựa chọn ${String.fromCharCode(65 + index)}',
                                                  hintStyle: styleSmall
                                                      .copyWith(color: grey4),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  style: styleSmall.copyWith(
                                                      color: grey2),
                                                  borderColor: grey5,
                                                  maxLines: 5,
                                                ),
                                              ),
                                              if (controllers.length > 2)
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: Colors.red),
                                                  onPressed: () => viewModel
                                                      .removeOption(index),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<List<TextEditingController>>(
                            valueListenable: viewModel.quizOptionControllers,
                            builder: (context, controllers, child) {
                              return DropdownButtonFormField<String>(
                                dropdownColor: white,
                                decoration: InputDecoration(
                                  labelText: 'Đáp án đúng',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                value: viewModel.selectedAnswer,
                                items: controllers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final letter =
                                      String.fromCharCode(65 + index);
                                  return DropdownMenuItem<String>(
                                    value: letter,
                                    child: Text(letter),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  viewModel.selectedAnswer = value;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => viewModel.addQuiz(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary2,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Thêm câu hỏi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16).copyWith(
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => viewModel.saveQuiz(lesson, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu bài kiểm tra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
