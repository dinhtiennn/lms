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

  // Thêm flag để kiểm tra trạng thái socket
  bool _isSocketConnected = false;

  bool _isDisposed = false;

  init() async {
    try {
      _isDisposed = false; // Reset trạng thái disposed mỗi khi init

      course = Get.arguments['course'];
      await refreshStudent();
      await _loadCourseDetail();
      log(courseDetail.toString());
      await _loadCurrentContent();

      // Thiết lập kết nối socket
      await setupSocket();

      // Kiểm tra trạng thái kết nối và thiết lập lại nếu cần
      if (!_isSocketConnected) {
        logger.w("Kết nối socket chưa được thiết lập, đang thử lại...");
        await Future.delayed(Duration(seconds: 1));
        setupSocket();
      }
    } catch (e) {
      logger.e("Lỗi trong quá trình khởi tạo: $e");
    }
  }

  void safelyUpdateNotifier<T>(ValueNotifier<T> notifier, T value) {
    if (!_isDisposed) {
      notifier.value = value;
      try {
        notifier.notifyListeners();
      } catch (e) {
        logger.e("Lỗi update ValueNotifier: $e");
      }
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
      if (_isDisposed) {
        logger.w("Không thể thiết lập socket vì ViewModel đã bị hủy");
        return;
      }

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

      // Thử kết nối lại sau một khoảng thời gian nếu việc thiết lập thất bại
      if (!_isDisposed) {
        Future.delayed(Duration(seconds: 3), () {
          if (!_isDisposed && !_isSocketConnected) {
            logger.i("🔄 Đang thử kết nối lại socket sau khi thất bại");
            setupSocket();
          }
        });
      }
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

    //load comment
    loadComment(chapter: chapter);

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

  void loadComment(
      {required ChapterModel chapter,
      int pageSize = 10,
      int pageNumber = 0}) async {
    if (_isDisposed) return;

    NetworkState<List<CommentModel>> resultCommentChapter =
        await commentRepository.commentInChapter(
            chapterId: chapter.id ?? '',
            pageSize: pageSize,
            pageNumber: pageNumber);
    if (resultCommentChapter.isSuccess && resultCommentChapter.result != null) {
      if (pageNumber > 0 && comments.value != null) {
        final currentComments = List<CommentModel>.from(comments.value!);
        currentComments.addAll(resultCommentChapter.result ?? []);
        safelyUpdateNotifier(comments, currentComments);
      } else {
        safelyUpdateNotifier(comments, resultCommentChapter.result ?? []);
      }
    }
  }

  @override
  void onStompCommentReceived(dynamic body) {
    logger.i('↩️ STOMP COMMENT RECEIVED: $body');

    if (body == null || _isDisposed) return;

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
      } else {
        // Trường hợp comment mới (không có updateDate)
        comment = CommentModel.fromJson(data['result']);
      }

      final String? chapterId = comment.chapterId;
      final String? courseId = comment.courseId;
      final String? commentId = comment.commentId;
      final dynamic lastUpdate = comment.lastUpdate;

      if (currentContent.value != null) {
        CurrentContent content = currentContent.value!;
        ChapterModel? chapter;

        if (content is ChapterContent) {
          chapter = content.chapter;
        }

        if (courseDetail.value?.id == courseId && chapter?.id == chapterId) {
          // Kiểm tra xem danh sách hiện tại có null không
          if (comments.value == null) {
            // Nếu danh sách rỗng, thêm mới comment vào danh sách
            safelyUpdateNotifier(comments, [comment]);
            return;
          }

          // Tạo bản sao của danh sách comments hiện tại
          List<CommentModel> currentComments = List.from(comments.value ?? []);

          // Kiểm tra dựa vào lastUpdate
          if (lastUpdate != null) {
            // Comment đã được chỉnh sửa
            logger.i("Comment đã được chỉnh sửa với lastUpdate: $lastUpdate");

            // Tìm comment cũ trong danh sách để cập nhật
            int existingIndex =
                currentComments.indexWhere((c) => c.commentId == commentId);

            if (existingIndex != -1) {
              // Lấy comment cũ
              CommentModel oldComment = currentComments[existingIndex];

              // Cập nhật comment cũ với detail và lastUpdate từ comment mới
              // nhưng giữ nguyên các thông tin khác (bao gồm cả replies)
              currentComments[existingIndex] = oldComment.copyWith(
                detail: comment.detail,
                lastUpdate: comment.lastUpdate,
              );

              logger.i("Đã cập nhật comment có ID: $commentId");

              // Cập nhật danh sách comments
              safelyUpdateNotifier(comments, currentComments);
            } else {
              logger.w("Không tìm thấy comment có ID: $commentId để cập nhật");
            }
          } else {
            // Comment mới (lastUpdate == null)
            logger.i("Thêm comment mới: ${comment.detail}");

            // Thêm comment mới vào đầu danh sách
            currentComments.insert(0, comment);

            // Cập nhật danh sách comments
            safelyUpdateNotifier(comments, currentComments);
          }
        }
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý onStompCommentReceived: $e");
    }
  }

  @override
  void onStompReplyReceived(dynamic body) {
    logger.i('↩️ STOMP REPLY RECEIVED: $body');

    if (body == null || _isDisposed) return;

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
          createdDate: data['result']["createdDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["createdDate"]),
          detail: data['result']['newDetail'],
          lastUpdate: data['result']["updateDate"] == null
              ? null
              : AppUtils.fromUtcStringToVnTime(data['result']["updateDate"]),
        );
      } else {
        // Trường hợp comment mới (không có updateDate)
        reply = ReplyModel.fromJson(data['result']);
      }

      final String? parentCommentId = reply.commentId ?? actualParentCommentId;
      final String? replyId = reply.commentReplyId;
      final DateTime? lastUpdate = reply.lastUpdate;

      if (parentCommentId == null || parentCommentId.isEmpty) {
        logger.w("Không tìm thấy ID comment cha cho reply này");
        return;
      }

      // Kiểm tra xem comments có null không
      if (comments.value == null) {
        logger.e("Comments là null, không thể thêm hoặc cập nhật reply");
        return;
      }

      // Tạo bản sao của comments.value hiện tại để làm việc
      final commentsList = List<CommentModel>.from(comments.value!);
      bool updated = false;

      for (var i = 0; i < commentsList.length; i++) {
        if (commentsList[i].commentId == parentCommentId) {
          // Tìm thấy comment cha
          CommentModel parentComment = commentsList[i];
          List<ReplyModel> currentReplies =
              List<ReplyModel>.from(parentComment.commentReplyResponses ?? []);

          if (lastUpdate != null) {
            // Reply đã được chỉnh sửa
            logger.i("Reply đã được chỉnh sửa với lastUpdate: $lastUpdate");

            // Tìm reply cũ trong danh sách để cập nhật
            int existingReplyIndex =
                currentReplies.indexWhere((r) => r.commentReplyId == replyId);

            if (existingReplyIndex != -1) {
              // Lấy reply cũ
              ReplyModel oldReply = currentReplies[existingReplyIndex];

              // Cập nhật reply cũ với detail và lastUpdate từ reply mới
              // nhưng giữ nguyên các thông tin khác
              currentReplies[existingReplyIndex] = oldReply.copyWith(
                detail: reply.detail,
                lastUpdate: reply.lastUpdate,
              );

              // Cập nhật comment với danh sách replies mới
              commentsList[i] =
                  parentComment.copyWith(commentReplyResponses: currentReplies);

              updated = true;
              logger.i("Đã cập nhật reply có ID: $replyId");
            } else {
              logger.w("Không tìm thấy reply có ID: $replyId để cập nhật");
            }
          } else {
            // Reply mới (lastUpdate == null)
            logger.i("Thêm reply mới: ${reply.detail}");

            // Chỉ cập nhật số lượng tổng reply, không thêm reply mới vào danh sách hiển thị
            // Người dùng sẽ nhấn vào nút "Xem thêm replies" để tải thêm
            int newCount = (parentComment.countOfReply ?? 0) + 1;
            commentsList[i] = parentComment.copyWith(countOfReply: newCount);

            updated = true;
            logger.i(
                "Đã cập nhật số lượng replies cho comment có ID: $parentCommentId");
          }

          break;
        }
      }

      if (updated) {
        safelyUpdateNotifier(comments, commentsList);
        logger.i(
            "Đã cập nhật/thêm mới reply cho comment có ID: $parentCommentId");
      } else {
        logger.w("Không tìm thấy comment cha có ID: $parentCommentId");
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý onStompReplyReceived: $e");
    }
  }

  void loadReply(
      {required String commentId, int pageSize = 3, int pageNumber = 0}) async {
    if (_isDisposed) return;

    logger.w(currentContent.value.toString());
    logger.w(courseDetail.value.toString());

    NetworkState<List<ReplyModel>> resultReply =
        await commentRepository.getReplies(
            commentId: commentId,
            replyPageSize: pageSize,
            pageNumber: pageNumber);
    if (resultReply.isSuccess && resultReply.result != null) {
      if (comments.value != null) {
        final currentComments = List<CommentModel>.from(comments.value!);
        for (var i = 0; i < currentComments.length; i++) {
          if (currentComments[i].commentId == commentId) {
            // Nếu là lần load đầu tiên (pageNumber = 0)
            if (pageNumber == 0) {
              currentComments[i] = currentComments[i].copyWith(
                commentReplyResponses: resultReply.result,
              );
            } else {
              // Nếu là loadMore, thêm replies mới vào danh sách hiện có
              final currentReplies =
                  currentComments[i].commentReplyResponses ?? [];
              currentComments[i] = currentComments[i].copyWith(
                commentReplyResponses: [
                  ...currentReplies,
                  ...resultReply.result!
                ],
              );
            }
            break;
          }
        }
        safelyUpdateNotifier(comments, currentComments);
      }
    }
  }

  Future<void> send({CommentModel? comment}) async {
    if (_isDisposed) return;

    // Đảm bảo STOMP đã được kết nối
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

    if (currentContent.value == null) {
      logger.e("Không có nội dung hiện tại, hủy gửi tin nhắn");
      return;
    }

    CurrentContent content = currentContent.value!;

    if (content is ChapterContent) {
      if (comment == null) {
        logger.i('Đang gửi comment mới');
        logger.i('Student info: ${student.value}');
        try {
          final payload = {
            'chapterId': content.chapter.id,
            'courseId': courseDetail.value?.id ?? '',
            'username': student.value?.email ?? '',
            'detail': commentController.text,
            'createDateD': DateTime.now().toString(),
          };

          logger.i('Gửi tin nhắn đến /app/comment: ${jsonEncode(payload)}');
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
        logger.i(
            'Đang gửi reply cho comment: ${commentSelected.value?.username}');
        try {
          logger.i('Comment được chọn: ${commentSelected.value}');
          final payload = {
            'replyUsername': student.value?.email,
            'ownerUsername': commentSelected.value?.username,
            'chapterId': content.chapter.id,
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
              title: "Gửi phản hồi thất bại!!!",
              type: ToastificationType.error);
        }
      }
    }
    setCommentSelected();
  }

  Future<void> editComment(
      {required String commentId, required String detail}) async {
    if (_isDisposed) return;

    await StompService.instance();
    if (currentContent.value == null) {
      return;
    }

    CurrentContent content = currentContent.value!;

    if (content is ChapterContent) {
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
  }

  Future<void> editReply(
      {required String replyId,
      required String parentCommentId,
      required String detail}) async {
    if (_isDisposed) return;

    await StompService.instance();
    if (currentContent.value == null) {
      return;
    }

    CurrentContent content = currentContent.value!;

    if (content is ChapterContent) {
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
  }

  setCommentSelected({CommentModel? comment}) {
    if (_isDisposed) return;

    safelyUpdateNotifier(commentSelected, comment);
    logger.w(commentSelected.value.toString());
  }

  @override
  void dispose() async {
    _isDisposed = true;

    // Dispose VideoPlayer
    disposeVideoPlayer();

    // Hủy đăng ký listener StompService
    if (_isSocketConnected) {
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

    // Dispose TextEditingController
    commentController.dispose();

    // Dispose các ValueNotifier inside try-catch to prevent errors
    try {
      student.dispose();
      courseDetail.dispose();
      currentContent.dispose();
      lessonCurrent.dispose();
      comments.dispose();
      commentSelected.dispose();
      videoPlayerHelper.dispose();
      animatedCommentId.dispose();
      animatedReplyId.dispose();
    } catch (e) {
      logger.e("Error disposing ValueNotifiers: $e");
    }

    logger.i("CourseDetailViewModel đã được dispose hoàn toàn");
    super.dispose();
  }
}
