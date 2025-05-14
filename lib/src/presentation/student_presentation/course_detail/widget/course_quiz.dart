import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/model/lesson_model.dart';
import 'package:toastification/toastification.dart';

class CourseQuiz extends StatefulWidget {
  final List<LessonQuizModel> quizs;
  final Function(LessonModel lesson) onComplete;
  final LessonModel? lesson;

  const CourseQuiz({Key? key, required this.quizs, required this.onComplete, required this.lesson}) : super(key: key);

  @override
  _CourseQuizState createState() => _CourseQuizState();
}

class _CourseQuizState extends State<CourseQuiz> {
  Map<int, String> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: selectedAnswers.length / widget.quizs.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          // Đếm câu trả lời
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Trả lời: ${selectedAnswers.length}/${widget.quizs.length}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${((selectedAnswers.length / widget.quizs.length) * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quiz list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.quizs.length,
              itemBuilder: (context, index) {
                return _buildQuizItem(widget.quizs[index], index);
              },
            ),
          ),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildQuizItem(LessonQuizModel quiz, int quizIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${quizIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quiz.question ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: grey4),
                  ),
                ),
              ],
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                quiz.getOptions().length,
                (optionIndex) {
                  final option = quiz.getOptions()[optionIndex];
                  final optionLetter = option.substring(0, 1);
                  final optionText = option.substring(3); // Skip "A. " part
                  final isSelected = selectedAnswers[quizIndex] == optionLetter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAnswers[quizIndex] = optionLetter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade500 : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue.shade500 : Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                optionLetter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(
                                color: isSelected ? Colors.blue.shade800 : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    bool allAnswered = selectedAnswers.length == widget.quizs.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!allAnswered)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Hoàn thành tất cả các câu hỏi để hoàn thành bài quiz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 13,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: allAnswered ? _submitQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Hoàn thành',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: allAnswered ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitQuiz() {
    int correctAnswers = 0;

    // Calculate score
    for (int i = 0; i < widget.quizs.length; i++) {
      final quiz = widget.quizs[i];
      final selectedAnswer = selectedAnswers[i];

      if (selectedAnswer == quiz.answer) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / widget.quizs.length) * 100;

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Kết quả bài tập',
          textAlign: TextAlign.center,
          style: styleVeryLargeBold.copyWith(color: grey3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: score == 100 ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: score >= 70 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn đã hoàn thành $correctAnswers/${widget.quizs.length} câu hỏi!',
              textAlign: TextAlign.center,
              style: styleMedium.copyWith(color: grey3),
            ),
            const SizedBox(height: 24),
            Text(
              score == 100 ? 'Chúc mừng bạn đã vượt qua bài quiz!' : 'Bạn chưa vượt qua bài quiz, hãy làm lại!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: score == 100 ? Colors.green.shade700 : Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset selections
                setState(() {
                  if (score == 100 && widget.lesson != null) {
                    widget.onComplete(widget.lesson!);
                  } else {
                    toastification.show(
                        title: Text('Lỗi hoàn thành bài tập, vui lòng thử lại sau!'), type: ToastificationType.warning);
                  }
                  selectedAnswers.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}
