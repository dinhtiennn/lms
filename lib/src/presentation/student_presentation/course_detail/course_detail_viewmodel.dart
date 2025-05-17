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

class CourseDetailViewModel extends BaseViewModel with StompListener {
  CourseModel? course;
  ValueNotifier<StudentModel?> student = ValueNotifier(null);
  late StompService stompService;
  TextEditingController commentController = TextEditingController();
  ValueNotifier<CourseDetailModel?> courseDetail =
      ValueNotifier<CourseDetailModel?>(null);
  ValueNotifier<CurrentContent?> currentContent = ValueNotifier(null);
  ValueNotifier<LessonModel?> lessonCurrent = ValueNotifier(null);
  ValueNotifier<List<CommentModel>?> comments = ValueNotifier(null);
  ValueNotifier<CommentModel?> commentSelected = ValueNotifier(null);
  ValueNotifier<VideoPlayerHelper> videoPlayerHelper =
      ValueNotifier(VideoPlayerHelper());
  final ValueNotifier<String?> animatedCommentId = ValueNotifier(null);
  final ValueNotifier<String?> animatedReplyId = ValueNotifier(null);

  // Thêm ScrollController cho comments
  final ScrollController commentsScrollController = ScrollController();

  // Thêm flag để kiểm tra trạng thái socket
  bool _isSocketConnected = false;
  // Thêm flag để kiểm tra trạng thái đã dispose hay chưa
  bool _isDisposed = false;

  bool hasMoreComments = true;
  bool isLoadingComments = false;
  int commentPageSize = 10;

  init() async {
    try {
      course = Get.arguments['course'];
      await refreshStudent();
      await _loadCourseDetail();
      log(courseDetail.toString());
      await _loadCurrentContent();

      // Thiết lập kết nối socket
      await setupSocket();

    } catch (e) {
      logger.e("Lỗi trong quá trình khởi tạo: $e");
    }
  }

  void safelyUpdateNotifier<T>(ValueNotifier<T> notifier, T value) {
    if (_isDisposed) return;
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

  void selectComment({CommentModel? comment}) {
    commentSelected.value = comment;
    commentSelected.notifyListeners();
  }

  Future<void> setupSocket() async {
    try {
      // Khởi tạo hoặc lấy instance của StompService
      stompService = await StompService.instance();

      // Đăng ký listener cho từng loại kênh, xử lý lỗi riêng cho từng loại
      logger.i("Bắt đầu đăng ký các listener cho socket");

      try {
        stompService.registerListener(
            type: StompListenType.comment, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.comment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.comment: $e");
      }

      try {
        stompService.registerListener(
            type: StompListenType.editComment, listener: this);
        logger
            .i("✅ Đăng ký thành công listener cho StompListenType.editComment");
      } catch (e) {
        logger.e(
            "❌ Lỗi khi đăng ký listener cho StompListenType.editComment: $e");
      }

      try {
        stompService.registerListener(
            type: StompListenType.reply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.reply");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.reply: $e");
      }

      try {
        stompService.registerListener(
            type: StompListenType.editReply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.editReply");
      } catch (e) {
        logger
            .e("❌ Lỗi khi đăng ký listener cho StompListenType.editReply: $e");
      }

      _isSocketConnected = true;
      logger
          .i("🚀 Socket đã được kết nối và đăng ký tất cả listener thành công");
    } catch (e) {
      logger.e("⛔ Lỗi khi thiết lập kết nối socket: $e");
      _isSocketConnected = false;
    }
  }

  Future<void> _loadCourseDetail() async {
    NetworkState<CourseDetailModel> resultCourseDetail =
        await courseRepository.getCourseDetail(courseId: course?.id);

    if (!resultCourseDetail.isSuccess || resultCourseDetail.result == null)
      return;

    courseDetail.value = resultCourseDetail.result;
    List<LessonModel> originalLessons = resultCourseDetail.result!.lesson ?? [];
    List<LessonModel> updatedLessons = <LessonModel>[];

    for (final lesson in originalLessons) {
      NetworkState<ProgressModel> progressResult =
          await courseRepository.getProgressLesson(lessonId: lesson.id);

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
        if (chapterProgressResult.isSuccess &&
            chapterProgressResult.result != null) {
          updatedChapter =
              chapter.copyWith(progress: chapterProgressResult.result);
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
      showToast(
          type: ToastificationType.warning, title: 'Không tìm thấy bài học');
      return;
    }

    final chapters = lessonCurrent.chapters ?? [];

    //Xử lý các chapter
    if (chapters.isNotEmpty) {
      //Kiểm tra nếu tất cả chapter có progress.isCompleted = true
      bool allCompleted =
          chapters.every((chapter) => chapter.progress?.isCompleted == true);
      if (allCompleted) {
        // Nếu tất cả chapter đã hoàn thành -> hiển thị quiz
        final quizzes = lessonCurrent.lessonQuizs ?? [];
        if (quizzes.isNotEmpty) {
          setQuizContent(quizzes, lessonCurrent);
          return;
        }
      }

      //Kiểm tra nếu tất cả chapter có progress = null
      bool allNull =
          chapters.every((chapter) => chapter.progress?.isCompleted == null);
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
          (chapter) =>
              chapter.progress?.isCompleted == false && chapter.id != null,
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
          (chapter) =>
              chapter.progress?.isCompleted == true && chapter.id != null,
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
    showToast(
        type: ToastificationType.warning, title: 'Bài học không có nội dung');
  }

  void setMaterialContent(LessonMaterialModel material, LessonModel lesson) {
    //select lúc nào cũng được
    //set id lesson current
    lessonCurrent.value = lesson;
    lessonCurrent.notifyListeners();
    //set material
    currentContent.value = MaterialContent(material);
    currentContent.notifyListeners();
    //set comments = []
    comments.value = [];
    comments.notifyListeners();
    disposeVideoPlayer();
  }

  void setQuizContent(List<LessonQuizModel> quizs, LessonModel lesson) {
    //sẽ không cho select quiz nếu chưa học xong chapters
    bool complete = lesson.chapters?.last.progress?.isCompleted ?? false;
    if (complete == false) {
      showToast(
          title: 'Vui lòng học xong các bài học!',
          type: ToastificationType.warning);
      return;
    }
    //set id lesson current
    lessonCurrent.value = lesson;
    lessonCurrent.notifyListeners();

    //set quiz
    currentContent.value = QuizContent(quizs);
    currentContent.notifyListeners();

    //set comment = []
    comments.value = [];
    comments.notifyListeners();

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

      final canAccess =
          prevChapter.id == null || prevChapter.progress?.isCompleted == true;
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

    final canAccess =
        isFirstChapter || prevChapter.progress?.isCompleted == true;
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
      final url =
          AppUtils.pathMediaToUrl("${AppEndpoint.baseImageUrl}${chapter.path}");
      try {
        final success = await videoPlayerHelper.value
            .initialize(url, !(chapter.progress?.isCompleted ?? false));
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
    Get.toNamed(Routers.courseReview,
        arguments: {'course': course, 'review': true});
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
        : chapters
            .sublist(0, chapters.length - 1)
            .every((c) => c.progress?.isCompleted == true);

    final bool isLastChapter = chapterCompleted.id == chapters.last.id;
    final bool lessonHasNoQuiz =
        lesson.lessonQuizs == null || lesson.lessonQuizs!.isEmpty;
    final bool lessonNotYetCompleted = lesson.progress?.isCompleted != true;

    if (isLastChapter &&
        allCompletedExceptLast &&
        lessonNotYetCompleted &&
        lessonHasNoQuiz) {
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
      final result =
          await courseRepository.setChapterProgress(chapterId: chapterNew.id);

      if (result.isSuccess && result.result != null) {
        _loadCourseDetail();
      } else {
        showToast(
            title: 'Lỗi khi lưu tiến độ chương',
            type: ToastificationType.error);
      }
    } catch (e) {
      showToast(
          title: 'Lỗi hệ thống: ${e.toString()}',
          type: ToastificationType.error);
    }
  }

  Future<void> setCompletedChapter(String idChapter) async {
    NetworkState resultCompleteChapter =
        await courseRepository.setCompleteChapterProgress(chapterId: idChapter);
    if (resultCompleteChapter.isSuccess &&
        resultCompleteChapter.result != null) {
      showToast(
          title: 'Bạn có thể chuyển qua bài học tiếp theo!',
          type: ToastificationType.success);
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

  Future<void> setCompletedLesson(LessonModel lesson,
      {bool toast = true}) async {
    if (lesson.progress?.isCompleted == false) {
      NetworkState resultCompleteLesson =
          await courseRepository.setCompleteLessonProgress(lessonId: lesson.id);
      if (resultCompleteLesson.isSuccess &&
          resultCompleteLesson.result != null) {
        toast
            ? showToast(
                title: 'Bạn có thể chuyển qua bài học tiếp theo!',
                type: ToastificationType.success)
            : null;
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

  Future<void> send({CommentModel? comment}) async {
    // Đảm bảo STOMP đã được kết nối
    ChapterModel? currentChapter;
    CurrentContent? content = currentContent.value;
    if (content != null && content is ChapterContent) {
      currentChapter = content.chapter;
    }
    if (stompService == null || !_isSocketConnected) {
      logger.i("STOMP chưa kết nối, thiết lập kết nối...");
      await setupSocket();

      if (!_isSocketConnected) {
        logger.e("Không thể kết nối STOMP, hủy gửi tin nhắn");
        showToast(
            title: "Không thể kết nối đến máy chủ, vui lòng thử lại sau",
            type: ToastificationType.error);
        return;
      }
    }

    if (currentChapter == null) {
      logger.e("Không có nội dung hiện tại, hủy gửi tin nhắn");
      return;
    }

    if (comment == null) {
      logger.i('Đang gửi comment mới');
      logger.i('Student info: ${student.value}');
      try {
        final payload = {
          'chapterId': currentChapter.id,
          'courseId': courseDetail.value?.id ?? '',
          'username': student.value?.email ?? '',
          'detail': commentController.text,
        };

        stompService.send(
          StompListenType.comment,
          jsonEncode(payload),
        );
        commentController.clear();
      } catch (e) {
        logger.e("Lỗi khi gửi comment: $e");
        showToast(title: "Gửi thất bại!!!", type: ToastificationType.error);
      }
    } else {
      logger
          .i('Đang gửi reply cho comment: ${commentSelected.value?.username}');
      try {
        logger.i('Comment được chọn: ${commentSelected.value}');
        final payload = {
          'replyUsername': student.value?.email,
          'ownerUsername': commentSelected.value?.username,
          'chapterId': currentChapter.id,
          'courseId': courseDetail.value?.id ?? '',
          'detail': commentController.text,
          'parentCommentId': commentSelected.value?.commentId,
        };

        logger.i('Gửi reply đến /app/comment-reply: ${jsonEncode(payload)}');
        stompService.send(
          StompListenType.reply,
          jsonEncode(payload),
        );
        commentController.clear();
      } catch (e) {
        logger.e("Lỗi khi gửi reply: $e");
        showToast(
            title: "Gửi phản hồi thất bại!!!", type: ToastificationType.error);
      }
    }
    setCommentSelected();
  }

  // Hàm thiết lập comment được chọn để phản hồi
  void setCommentSelected({CommentModel? comment}) {
    commentSelected.value = comment;
    commentSelected.notifyListeners();
  }

  Future<void> loadComments({bool isReset = false, int? pageSize}) async {
    ChapterModel? currentChapter;
    CurrentContent? content = currentContent.value;
    if (content != null && content is ChapterContent) {
      currentChapter = content.chapter;
    }

    if (isReset) {
      hasMoreComments = true;
      comments.value = null;
    }

    if (!hasMoreComments || isLoadingComments) return;

    isLoadingComments = true;
    notifyListeners();

    try {
      final String? courseId = courseDetail.value?.id;
      final String? chapterId = currentChapter?.id;

      if (courseId == null || chapterId == null) {
        logger
            .e("Không thể tải comments: courseId hoặc chapterId không tồn tại");
        isLoadingComments = false;
        notifyListeners();
        return;
      }

      // Sử dụng pageSize từ tham số nếu có, ngược lại dùng giá trị mặc định
      final int effectivePageSize = pageSize ?? commentPageSize;

      // Tính toán pageNumber dựa trên kích thước hiện tại của danh sách comments
      final int pageNumber = (comments.value?.length ?? 0);

      logger.i(
          "Tải comments cho chapter: $chapterId, pageNumber: $pageNumber, pageSize: $effectivePageSize");

      final NetworkState<List<CommentModel>> result =
          await commentRepository.commentInChapter(
        chapterId: chapterId,
        pageSize: effectivePageSize,
        pageNumber: pageNumber,
      );

      if (result.isSuccess && result.result != null) {
        final List<CommentModel> newComments = result.result!;
        logger.i("Đã tải ${newComments.length} comments");

        if (isReset || comments.value == null) {
          comments.value = newComments;
        } else {
          final existingComments = List<CommentModel>.from(comments.value!);

          // Loại bỏ các comment trùng lặp
          final updatedComments = [...existingComments];
          for (final comment in newComments) {
            if (!existingComments
                .any((c) => c.commentId == comment.commentId)) {
              updatedComments.add(comment);
            }
          }

          comments.value = updatedComments;
        }

        // Kiểm tra xem còn comments để tải không
        hasMoreComments = newComments.length >= effectivePageSize;

        // Cập nhật UI
        comments.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi tải bình luận: $e");
    } finally {
      isLoadingComments = false;
      notifyListeners();
    }
  }

  // Hàm tải thêm comments
  Future<void> loadMoreComments() async {
    await loadComments();
  }

  // Hàm tải thêm replies cho một comment cụ thể
  Future<void> loadMoreReplies({required String commentId}) async {
    if (comments.value == null) return;

    try {
      // Tìm comment hiện tại
      final existingComments = List<CommentModel>.from(comments.value!);
      final commentIndex =
          existingComments.indexWhere((c) => c.commentId == commentId);

      if (commentIndex == -1) return;

      final comment = existingComments[commentIndex];

      // Sử dụng chính xác số lượng replies hiện tại làm pageNumber
      final int currentRepliesCount =
          comment.commentReplyResponses?.length ?? 0;

      logger.i(
          "Tải replies cho comment: $commentId, pageNumber: $currentRepliesCount");

      final NetworkState<List<ReplyModel>> result =
          await commentRepository.getReplies(
        commentId: commentId,
        replyPageSize: 5, // Số lượng replies mỗi lần tải
        pageNumber: currentRepliesCount,
      );

      if (result.isSuccess && result.result != null) {
        final List<ReplyModel> newReplies = result.result!;
        logger.i("Đã tải ${newReplies.length} replies");

        // Loại bỏ các reply trùng lặp
        final List<ReplyModel> uniqueNewReplies = [];
        for (final newReply in newReplies) {
          if (!(comment.commentReplyResponses ?? []).any((existingReply) =>
              existingReply.commentReplyId == newReply.commentReplyId)) {
            uniqueNewReplies.add(newReply);
          }
        }

        // Cập nhật comment với replies mới
        final updatedComment = comment.copyWith(
          commentReplyResponses: [
            ...(comment.commentReplyResponses ?? []),
            ...uniqueNewReplies,
          ],
        );

        // Cập nhật danh sách comments
        existingComments[commentIndex] = updatedComment;
        comments.value = existingComments;
        comments.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi tải phản hồi: $e");
    }
  }

  // Các hàm xử lý socket nhận comment, reply
  @override
  void onStompCommentReceived(dynamic body) {
    if (body == null) {
      if (!_isSocketConnected) {
        setupSocket();
      }
      return;
    }

    // Kiểm tra xem view model đã được dispose chưa
    if (_isDisposed) {
      logger.w("ViewModel đã bị dispose, bỏ qua xử lý comment từ socket");
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(body);
      logger.i("Phản hồi comment từ server: ${data.toString()}");

      // Khởi tạo biến comment
      CommentModel comment;

      // Kiểm tra cấu trúc JSON để xác định phương thức tạo CommentModel thích hợp
      if (data['result']['updateDate'] != null) {
        // Trường hợp chỉnh sửa comment (có updateDate - lastUpdate)
        comment = CommentModel(
          countOfReply: data['result']['countOfReply'],
          courseId: data['result']['courseId'],
          commentId: data['result']['commentId'],
          username: data['result']['usernameOwner'],
          avatar: data['result']['avatarOwner'],
          fullname: data['result']['fullnameOwner'],
          chapterId: data['result']['chapterId'],
          createdDate: data['result']["createdDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["createdDate"]),
          detail: data['result']['newDetail'],
          lastUpdate: data['result']["updateDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["updateDate"]),
        );

        // Tìm và cập nhật comment trong danh sách
        _updateExistingComment(comment);
      } else {
        // Trường hợp comment mới (không có updateDate)
        comment = CommentModel.fromJson(data['result']);
        // Thêm comment mới vào đầu danh sách
        _addNewComment(comment);
      }

      // Set animated comment ID cho hiệu ứng highlight
      if (!_isDisposed) {
        animatedCommentId.value = comment.commentId;
        Future.delayed(Duration(seconds: 2), () {
          if (!_isDisposed) {
            animatedCommentId.value = null;
          }
        });
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý comment từ socket: $e");
    }
  }

  @override
  void onStompReplyReceived(dynamic body) {
    if (body == null) {
      if (!_isSocketConnected) {
        setupSocket();
      }
      return;
    }

    // Kiểm tra xem view model đã được dispose chưa
    if (_isDisposed) {
      logger.w("ViewModel đã bị dispose, bỏ qua xử lý reply từ socket");
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(body);
      logger.i("Phản hồi reply từ server: ${data.toString()}");

      String actualParentCommentId = "";
      // Khởi tạo biến comment
      ReplyModel reply;

      // Kiểm tra cấu trúc JSON để xác định phương thức tạo CommentModel thích hợp
      if (data['result']['updateDate'] != null) {
        // Trường hợp chỉnh sửa reply (có updateDate - lastUpdate)
        // Lấy ID chính xác của comment cha từ comments hiện tại
        final String replyId = data['result']['commentReplyId'];

        // Tìm commentId chính xác từ comments hiện tại
        if (comments.value != null) {
          for (var comment in comments.value!) {
            final replies = comment.commentReplyResponses ?? [];
            for (var existingReply in replies) {
              if (existingReply.commentReplyId == replyId) {
                actualParentCommentId = comment.commentId ?? "";
                break;
              }
            }
            if (actualParentCommentId.isNotEmpty) break;
          }
        }

        reply = ReplyModel(
          commentReplyId: replyId,
          commentId: actualParentCommentId,
          detail: data['result']['newDetail'],
          createdDate: data['result']["createdDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["createdDate"]),
          avatarReply: data['result']['avatarReply'],
          fullnameOwner: data['result']['fullnameOwner'],
          fullnameReply: data['result']['fullnameReply'],
          replyCount: data['result']['replyCount'],
          usernameOwner: data['result']['usernameOwner'],
          usernameReply: data['result']['usernameReply'],
          lastUpdate: data['result']["updateDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["updateDate"]),
        );

        // Tìm và cập nhật reply trong danh sách
        _updateExistingReply(reply, actualParentCommentId);
      } else {
        // Trường hợp reply mới (không có updateDate)
        reply = ReplyModel.fromJson(data['result']);
        actualParentCommentId = data['result']['commentId'];

        // Thêm reply mới vào comment cha
        _addNewReply(reply, actualParentCommentId);
      }

      // Set animated reply ID cho hiệu ứng highlight
      if (!_isDisposed) {
        animatedReplyId.value = reply.commentReplyId;
        Future.delayed(Duration(seconds: 2), () {
          if (!_isDisposed) {
            animatedReplyId.value = null;
          }
        });
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý reply từ socket: $e");
    }
  }

  // Hàm hỗ trợ thêm comment mới vào danh sách
  void _addNewComment(CommentModel newComment) {
    if (_isDisposed || comments.value == null) {
      if (!_isDisposed) {
        comments.value = [newComment];
      }
    } else {
      // Kiểm tra xem comment đã tồn tại chưa
      final List<CommentModel> currentComments = List.from(comments.value!);
      final bool exists = currentComments
          .any((comment) => comment.commentId == newComment.commentId);

      if (!exists) {
        comments.value = [newComment, ...currentComments];
      }
    }
    if (!_isDisposed) {
      comments.notifyListeners();
    }
  }

  // Hàm hỗ trợ cập nhật comment đã tồn tại
  void _updateExistingComment(CommentModel updatedComment) {
    if (_isDisposed || comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int index = currentComments
        .indexWhere((comment) => comment.commentId == updatedComment.commentId);

    if (index != -1) {
      // Cập nhật nội dung comment nhưng giữ nguyên replies
      final CommentModel existingComment = currentComments[index];
      final updatedWithExistingReplies = updatedComment.copyWith(
        commentReplyResponses: existingComment.commentReplyResponses,
      );

      currentComments[index] = updatedWithExistingReplies;
      comments.value = currentComments;
      if (!_isDisposed) {
        comments.notifyListeners();
      }
    }
  }

  // Hàm hỗ trợ thêm reply mới vào comment cha
  void _addNewReply(ReplyModel newReply, String parentCommentId) {
    if (_isDisposed || comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments
        .indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];

      // Kiểm tra xem reply đã tồn tại chưa
      final List<ReplyModel> existingReplies =
          parentComment.commentReplyResponses ?? [];
      final bool replyExists = existingReplies
          .any((reply) => reply.commentReplyId == newReply.commentReplyId);

      if (!replyExists) {
        // Tạo bản sao của comment cha với danh sách replies đã cập nhật
        final CommentModel updatedParentComment = parentComment.copyWith(
          countOfReply: newReply.replyCount,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;
        if (!_isDisposed) {
          comments.notifyListeners();
        }
      }
    }
  }

  // Hàm hỗ trợ cập nhật reply đã tồn tại
  void _updateExistingReply(ReplyModel updatedReply, String parentCommentId) {
    if (_isDisposed || comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments
        .indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];
      final List<ReplyModel> replies =
          parentComment.commentReplyResponses ?? [];

      final int replyIndex = replies.indexWhere(
          (reply) => reply.commentReplyId == updatedReply.commentReplyId);

      if (replyIndex != -1) {
        // Tạo bản sao danh sách replies và cập nhật reply
        final List<ReplyModel> updatedReplies = List.from(replies);
        updatedReplies[replyIndex] = updatedReply;

        // Tạo bản sao của comment cha với danh sách replies đã cập nhật
        final CommentModel updatedParentComment = parentComment.copyWith(
          commentReplyResponses: updatedReplies,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;
        if (!_isDisposed) {
          comments.notifyListeners();
        }
      }
    }
  }

  // Hàm reset trạng thái của comment khi BottomSheet được đóng
  void resetCommentState() {
    logger.i("Reset trạng thái comment");
    hasMoreComments = true;
    isLoadingComments = false;
    comments.value = null;
    commentSelected.value = null;
    commentController.clear();

    // Đảm bảo UI được cập nhật
    comments.notifyListeners();
    commentSelected.notifyListeners();
  }

  Future<void> editComment(
      {required String commentId, required String detail}) async {
    ChapterModel? currentChapter;
    CurrentContent? content = currentContent.value;
    if (content != null && content is ChapterContent) {
      currentChapter = content.chapter;
    }

    await StompService.instance();
    if (currentChapter == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editComment,
        jsonEncode({
          'commentId': commentId,
          'usernameOwner': student.value?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(
          title: "Chỉnh sửa bình luận thất bại!",
          type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa comment: $e");
    }
  }

  Future<void> editReply(
      {required String replyId,
      required String parentCommentId,
      required String detail}) async {
    ChapterModel? currentChapter;
    CurrentContent? content = currentContent.value;
    if (content != null && content is ChapterContent) {
      currentChapter = content.chapter;
    }

    await StompService.instance();
    if (currentChapter == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editReply,
        jsonEncode({
          'commentReplyId': replyId,
          'usernameReply': student.value?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(
          title: "Chỉnh sửa phản hồi thất bại!",
          type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa reply: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Hủy đăng ký listener StompService
    if (_isSocketConnected && stompService != null) {
      try {
        logger.i("Hủy đăng ký listener khi thoát màn hình");
        stompService.unregisterListener(
            type: StompListenType.comment, listener: this);
        stompService.unregisterListener(
            type: StompListenType.editComment, listener: this);
        stompService.unregisterListener(
            type: StompListenType.reply, listener: this);
        stompService.unregisterListener(
            type: StompListenType.editReply, listener: this);
        _isSocketConnected = false;
      } catch (e) {
        logger.e("Lỗi khi hủy đăng ký listener trong dispose: $e");
      }
    }

    // Dispose controllers và listeners
    commentController.dispose();
    commentsScrollController.dispose();
    animatedCommentId.dispose();
    animatedReplyId.dispose();
    commentSelected.dispose();

    // Gọi super.dispose() để hoàn tất việc giải phóng tài nguyên
    super.dispose();
  }
}
