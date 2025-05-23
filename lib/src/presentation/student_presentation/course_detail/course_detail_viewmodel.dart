import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/utils/chewie_helper.dart';
import 'package:toastification/toastification.dart';
import '../../../configs/configs.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class CourseDetailViewModel extends BaseViewModel {
  CourseModel? course;
  ValueNotifier<StudentModel?> student = ValueNotifier(null);
  ValueNotifier<CourseDetailModel?> courseDetail = ValueNotifier<CourseDetailModel?>(null);
  ValueNotifier<CurrentContent?> currentContent = ValueNotifier(null);
  ValueNotifier<LessonModel?> lessonCurrent = ValueNotifier(null);
  ValueNotifier<VideoPlayerHelper> videoPlayerHelper = ValueNotifier(VideoPlayerHelper());

  init() async {
    try {
      course = Get.arguments['course'];
      await refreshStudent();
      await _loadCourseDetail();
      log(courseDetail.toString());
      await _loadCurrentContent();
    } catch (e) {
      logger.e("Lỗi trong quá trình khởi tạo: $e");
    }
  }

  void safelyUpdateNotifier<T>(ValueNotifier<T> notifier, T value) {
    notifier.value = value;
    try {
      notifier.notifyListeners();
    } catch (e) {
      logger.e("Lỗi update ValueNotifier: $e");
    }
  }

  Future<void> refreshStudent() async {
    student.value = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    logger.w(student.value);
    student.notifyListeners();
  }

  Future<void> _loadCourseDetail() async {
    NetworkState<CourseDetailModel> resultCourseDetail = await courseRepository.getCourseDetail(courseId: course?.id);

    if (!resultCourseDetail.isSuccess || resultCourseDetail.result == null) return;

    courseDetail.value = resultCourseDetail.result;
    List<LessonModel> originalLessons = resultCourseDetail.result!.lesson ?? [];
    List<LessonModel> updatedLessons = <LessonModel>[];

    for (final lesson in originalLessons) {
      NetworkState<ProgressModel> progressResult = await courseRepository.getProgressLesson(lessonId: lesson.id);

      LessonModel updatedLesson = lesson;
      if (progressResult.isSuccess && progressResult.result != null) {
        updatedLesson = updatedLesson.copyWith(progress: progressResult.result);
      }

      // Xử lý thêm progress cho chapter
      List<ChapterModel> originalChapters = updatedLesson.chapters ?? [];
      List<ChapterModel> updatedChapters = <ChapterModel>[];

      for (final chapter in originalChapters) {
        NetworkState<ProgressModel> chapterProgressResult =
            await courseRepository.getProgressChapter(chapterId: chapter.id);
        ChapterModel updatedChapter = chapter;
        if (chapterProgressResult.isSuccess && chapterProgressResult.result != null) {
          updatedChapter = chapter.copyWith(progress: chapterProgressResult.result);
        }
        updatedChapters.add(updatedChapter);
      }

      updatedLesson = updatedLesson.copyWith(chapters: updatedChapters);
      updatedLessons.add(updatedLesson);

      // Cập nhật courseDetail sau mỗi bài học (nếu cần)
      courseDetail.value = courseDetail.value!.copyWith(lesson: updatedLessons);
      courseDetail.notifyListeners();
    }
  }

  Future<void> _loadCurrentContent() async {
    final lessons = courseDetail.value?.lesson ?? [];
    LessonModel? lessonCurrent;

    // Tìm bài học đang học dở (progress.isCompleted == false)
    try {
      lessonCurrent = lessons.firstWhere(
        (lesson) => lesson.progress?.isCompleted == false,
      );
      this.lessonCurrent.value = lessonCurrent;
      this.lessonCurrent.notifyListeners();
    } catch (e) {
      // Không tìm thấy bài học đang học dở
      lessonCurrent = null;
    }

    // Nếu không có bài đang học dở, tìm bài đã học
    if (lessonCurrent == null) {
      try {
        lessonCurrent = lessons.lastWhere(
          (lesson) => lesson.progress?.isCompleted == true,
        );

        // Nếu bài học đã hoàn thành, chuyển sang bài kế tiếp
        if (lessonCurrent.progress?.isCompleted == true) {
          final currentIndex = lessons.indexOf(lessonCurrent);
          if (currentIndex < lessons.length - 1) {
            // Nếu còn bài kế tiếp, chuyển sang bài kế tiếp và tạo progress
            final nextLesson = lessons[currentIndex + 1];
            lessonCurrent = nextLesson;
            setLessonProgress(nextLesson);
            this.lessonCurrent.value = nextLesson;
            this.lessonCurrent.notifyListeners();
          }
        } else {
          this.lessonCurrent.value = lessonCurrent;
          this.lessonCurrent.notifyListeners();
        }
      } catch (e) {
        // Không tìm thấy bài học đã hoàn thành
        lessonCurrent = null;
      }
    }

    //Nếu không có progress nào -> lấy bài đầu tiên và tạo progress
    if (lessonCurrent == null && lessons.isNotEmpty) {
      final firstLesson = lessons.first;
      setLessonProgress(firstLesson);
      lessonCurrent = firstLesson;
      this.lessonCurrent.value = lessonCurrent;
      this.lessonCurrent.notifyListeners();
    }

    //Không tìm được gì thì thông báo
    if (lessonCurrent == null) {
      showToast(type: ToastificationType.warning, title: 'Không tìm thấy bài học');
      return;
    }

    final chapters = lessonCurrent.chapters ?? [];

    //Xử lý các chapter
    if (chapters.isNotEmpty) {
      //Kiểm tra nếu tất cả chapter có progress.isCompleted = true
      bool allCompleted = chapters.every((chapter) => chapter.progress?.isCompleted == true);
      if (allCompleted) {
        // Nếu tất cả chapter đã hoàn thành -> hiển thị quiz
        final quizzes = lessonCurrent.lessonQuizs ?? [];
        if (quizzes.isNotEmpty) {
          setQuizContent(quizzes, lessonCurrent);
          return;
        }
      }

      //Kiểm tra nếu tất cả chapter có progress = null
      bool allNull = chapters.every((chapter) => chapter.progress?.isCompleted == null);
      if (allNull) {
        // Nếu tất cả progress là null, hiển thị material nếu có
        final materials = lessonCurrent.lessonMaterials ?? [];
        if (materials.isNotEmpty) {
          setMaterialContent(materials.first, lessonCurrent);
          return;
        }
      }

      //Ưu tiên chapter với progress.isCompleted = false
      ChapterModel? chapterNotCompleted;
      try {
        chapterNotCompleted = chapters.firstWhere(
          (chapter) => chapter.progress?.isCompleted == false && chapter.id != null,
        );
      } catch (e) {
        chapterNotCompleted = null;
      }

      if (chapterNotCompleted != null) {
        setChapterContent(chapterNotCompleted, lessonCurrent);
        return;
      }

      //Nếu không có false, tìm chapter với progress.isCompleted = true
      ChapterModel? chapterCompleted;
      try {
        chapterCompleted = chapters.lastWhere(
          (chapter) => chapter.progress?.isCompleted == true && chapter.id != null,
        );
      } catch (e) {
        chapterCompleted = null;
      }

      if (chapterCompleted != null) {
        setChapterContent(chapterCompleted, lessonCurrent);
        return;
      }

      //Nếu không tìm được chapter phù hợp -> hiển thị chapter đầu tiên
      setChapterContent(chapters.first, lessonCurrent);
      return;
    }

    //Nếu không có chapter -> hiển thị material nếu có
    final materials = lessonCurrent.lessonMaterials ?? [];
    if (materials.isNotEmpty) {
      setMaterialContent(materials.first, lessonCurrent);
      return;
    }

    // Nếu không có chapter và material -> hiện quiz
    final quizzes = lessonCurrent.lessonQuizs ?? [];
    if (quizzes.isNotEmpty) {
      setQuizContent(quizzes, lessonCurrent);
      return;
    }

    // Không có gì thì báo lỗi
    showToast(type: ToastificationType.warning, title: 'Bài học không có nội dung');
  }

  void setMaterialContent(LessonMaterialModel material, LessonModel lesson) {
    //select lúc nào cũng được
    //set id lesson current
    lessonCurrent.value = lesson;
    lessonCurrent.notifyListeners();
    //set material
    currentContent.value = MaterialContent(material);
    currentContent.notifyListeners();
    disposeVideoPlayer();
  }

  void setQuizContent(List<LessonQuizModel> quizs, LessonModel lesson) {
    //sẽ không cho select quiz nếu chưa học xong chapters
    bool complete = lesson.chapters?.last.progress?.isCompleted ?? false;
    if (complete == false) {
      showToast(title: 'Vui lòng học xong các bài học!', type: ToastificationType.warning);
      return;
    }
    //set id lesson current
    lessonCurrent.value = lesson;
    lessonCurrent.notifyListeners();

    //set quiz
    currentContent.value = QuizContent(quizs);
    currentContent.notifyListeners();

    disposeVideoPlayer();
  }

  void setChapterContent(
    ChapterModel chapterSelected,
    LessonModel lessonSelected,
  ) async {
    final lessons = courseDetail.value?.lesson ?? [];
    final currentLessonId = lessonCurrent.value?.id;

    final currentLesson = lessons.firstWhere(
      (l) => l.id == currentLessonId,
      orElse: () => LessonModel(),
    );

    final chapters = lessonSelected.chapters ?? [];
    final selectedChapterOrder = chapterSelected.order ?? 0;

    //Cho phép học lại nếu lesson hoặc chapter đã hoàn thành
    final isLessonCompleted = lessonSelected.progress?.isCompleted == true;
    final isChapterCompleted = chapterSelected.progress?.isCompleted == true;
    if (isLessonCompleted || isChapterCompleted) {
      return _setChapter(chapterSelected, lessonSelected);
    }

    //Nếu trong cùng một bài học
    final isSameLesson = currentLesson.id == lessonSelected.id;

    if (isSameLesson) {
      final prevChapter = chapters.firstWhere(
        (c) => (c.order ?? 0) == selectedChapterOrder - 1,
        orElse: () => ChapterModel(),
      );

      final canAccess = prevChapter.id == null || prevChapter.progress?.isCompleted == true;
      if (canAccess) {
        return _setChapter(chapterSelected, lessonSelected);
      }

      return showToast(
        type: ToastificationType.warning,
        title: 'Vui lòng hoàn thành chương trước để tiếp tục!',
      );
    }

    // Nếu sang bài học mới
    final prevLesson = lessons.firstWhere(
      (l) => (l.order ?? 0) == (lessonSelected.order ?? 0) - 1,
      orElse: () => LessonModel(),
    );

    //Check lại sau khi có thể đã được đánh dấu complete
    if (prevLesson.progress?.isCompleted != true) {
      return showToast(
        type: ToastificationType.warning,
        title: 'Vui lòng hoàn thành bài học trước để tiếp tục!',
      );
    }

    final isFirstChapter = selectedChapterOrder == 1;
    final prevChapter = chapters.firstWhere(
      (c) => (c.order ?? 0) == selectedChapterOrder - 1,
      orElse: () => ChapterModel(),
    );

    final canAccess = isFirstChapter || prevChapter.progress?.isCompleted == true;
    if (!canAccess) {
      return showToast(
        type: ToastificationType.warning,
        title: 'Vui lòng học lần lượt các chương trong bài học mới!',
      );
    }

    setLessonProgress(lessonSelected);

    return _setChapter(chapterSelected, lessonSelected);
  }

// Hàm xử lý logic gán nội dung chapter
  Future<void> _setChapter(ChapterModel chapter, LessonModel lesson) async {
    lessonCurrent.value = lesson;
    lessonCurrent.notifyListeners();

    currentContent.value = null;
    await Future.delayed(Duration.zero);
    currentContent.value = ChapterContent(chapter);

    final path = (chapter.path ?? '').toLowerCase();
    if (path.isNotEmpty && path.endsWith('.mp4')) {
      logger.e(chapter.progress?.isCompleted);
      final url = AppUtils.pathMediaToUrl("${AppEndpoint.baseImageUrl}${chapter.path}");
      try {
        final success = await videoPlayerHelper.value.initialize(url, !(chapter.progress?.isCompleted ?? false));
        if (!success) {
          showToast(
            type: ToastificationType.error,
            title: 'Lỗi tải video: ${videoPlayerHelper.value.errorMessage}',
          );
        } else {
          // Đăng ký các listener cho VideoPlayerHelper
          _setupVideoListeners(chapter);
          videoPlayerHelper.notifyListeners();
        }
      } catch (e) {
        logger.e('Lỗi khởi tạo video: $e');
        showToast(
          type: ToastificationType.error,
          title: 'Lỗi tải video: ${e.toString()}',
        );
      }
    } else {
      disposeVideoPlayer();
    }

    setChapterProgress(chapter);

    currentContent.notifyListeners();
  }

  void clearCurrentContent() {
    currentContent.value = null;
  }

  void courseReview() {
    videoPlayerHelper.value.pause();
    Get.toNamed(Routers.courseReview, arguments: {'course': course, 'review': true});
  }

  void _setupVideoListeners(ChapterModel chapter) {
    // Đăng ký listener cho sự kiện hoàn thành video
    bool check = true; // tạo cờ để check không bị gọi nhiều lần theo render

    videoPlayerHelper.value.addCompletionListener(() {
      logger.w("Video completed");

      if (check) {
        onViewedDone(chapterCompleted: chapter);
        check = false;
      }
    });

    // Đăng ký listener cho sự kiện fullscreen
    videoPlayerHelper.value.addFullscreenListener(() {
      logger.d("Fullscreen changed: ${videoPlayerHelper.value.isFullScreen}");
      // Xử lý khi trạng thái fullscreen thay đổi
    });
    videoPlayerHelper.notifyListeners();
  }

  Future<String?> convertDocxToPdfUrl(String docxUrl) async {
    try {
      // Gọi API chuyển đổi DOCX sang PDF
      final response = await http.post(
        Uri.parse('${AppEndpoint.baseUrl}/api/convert/docx-to-pdf'),
        headers: {
          'Authorization': 'Bearer ${AppPrefs.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'docxUrl': docxUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['pdfUrl'] as String;
      } else {
        throw 'Không thể chuyển đổi file: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('Error converting DOCX to PDF: $e');
      return null;
    }
  }

  void disposeVideoPlayer() {
    try {
      videoPlayerHelper.value.dispose();
      videoPlayerHelper.value = VideoPlayerHelper(); // reset nếu cần
    } catch (e) {
      logger.e("Dispose lỗi: $e");
    }
  }

  void onViewedDone({required ChapterModel chapterCompleted}) async {
    if (chapterCompleted.progress?.isCompleted == true) return;

    final lesson = lessonCurrent.value;
    final chapters = lesson?.chapters ?? [];

    if (lesson == null || chapters.isEmpty) return;

    final bool allCompletedExceptLast = chapters.length <= 1
        ? false
        : chapters.sublist(0, chapters.length - 1).every((c) => c.progress?.isCompleted == true);

    final bool isLastChapter = chapterCompleted.id == chapters.last.id;
    final bool lessonHasNoQuiz = lesson.lessonQuizs == null || lesson.lessonQuizs!.isEmpty;
    final bool lessonNotYetCompleted = lesson.progress?.isCompleted != true;

    if (isLastChapter && allCompletedExceptLast && lessonNotYetCompleted && lessonHasNoQuiz) {
      await setCompletedLesson(lesson, toast: false);
      await _loadCurrentContent();
    }

    await setCompletedChapter(chapterCompleted.id ?? '');
  }

  void setChapterProgress(ChapterModel chapterNew) async {
    NetworkState<ProgressModel> resultProgressChapter =
        await courseRepository.getProgressChapter(chapterId: chapterNew.id);

    final isCompleted = resultProgressChapter.result?.isCompleted;
    if (resultProgressChapter.isSuccess && isCompleted != null) {
      return;
    }

    // Lưu progress mới
    try {
      final result = await courseRepository.setChapterProgress(chapterId: chapterNew.id);

      if (result.isSuccess && result.result != null) {
        _loadCourseDetail();
      } else {
        showToast(title: 'Lỗi khi lưu tiến độ chương', type: ToastificationType.error);
      }
    } catch (e) {
      showToast(title: 'Lỗi hệ thống: ${e.toString()}', type: ToastificationType.error);
    }
  }

  Future<void> setCompletedChapter(String idChapter) async {
    NetworkState resultCompleteChapter = await courseRepository.setCompleteChapterProgress(chapterId: idChapter);
    if (resultCompleteChapter.isSuccess && resultCompleteChapter.result != null) {
      showToast(title: 'Bạn có thể chuyển qua bài học tiếp theo!', type: ToastificationType.success);
      _loadCourseDetail();
    }
  }

  void setLessonProgress(LessonModel lesson) async {
    if (lesson.progress?.isCompleted != null) {
      return;
    }
    await courseRepository.setLessonProgress(lessonId: lesson.id);
    _loadCourseDetail();
  }

  Future<void> setCompletedLesson(LessonModel lesson, {bool toast = true}) async {
    if (lesson.progress?.isCompleted == false) {
      NetworkState resultCompleteLesson = await courseRepository.setCompleteLessonProgress(lessonId: lesson.id);
      if (resultCompleteLesson.isSuccess && resultCompleteLesson.result != null) {
        toast ? showToast(title: 'Bạn có thể chuyển qua bài học tiếp theo!', type: ToastificationType.success) : null;
        _loadCourseDetail();
        if (Get.isRegistered<HomeViewModel>()) {
          Get.find<HomeViewModel>().getMyCourses();
        }
        if (Get.isRegistered<CourseViewModel>()) {
          Get.find<CourseViewModel>().getMyCourse();
        }
      }
    }
  }

  void toComment(ChapterContent content) {
    videoPlayerHelper.value.pause();
    Get.toNamed(Routers.courseComment, arguments: {'chapter': content.chapter, 'courseDetail': courseDetail.value});
  }

  @override
  void dispose() {
    logger.i("CourseDetailViewModel.dispose() được gọi");
    disposeVideoPlayer();
    videoPlayerHelper.dispose();
    super.dispose();
  }
}
