import 'dart:convert';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class CourseDetailTeacherViewModel extends BaseViewModel with StompListener {
  CourseModel? course;
  ValueNotifier<CourseDetailModel?> courseDetail = ValueNotifier(null);
  ValueNotifier<TeacherModel?> teacher = ValueNotifier(null);
  ValueNotifier<ChapterModel?> chapterSelected = ValueNotifier(null);

  //Các biến của chỉnh sửa khóa học
  var formKey = GlobalKey<FormState>();
  TextEditingController materialNameController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  ValueNotifier<List<MajorModel>?> majors = ValueNotifier(null);
  ValueNotifier<StatusOption?> statusSelected = ValueNotifier(null);
  ValueNotifier<MajorModel?> majorSelected = ValueNotifier(null);
  ValueNotifier<FeeStatusOption?> feeTypeSelected = ValueNotifier(null);

  //biến quản lý danh sách comment
  ValueNotifier<List<CommentModel>?> comments = ValueNotifier(null);
  ValueNotifier<CommentModel?> commentSelected = ValueNotifier(null);
  TextEditingController commentController = TextEditingController();
  ValueNotifier<String?> animatedCommentId = ValueNotifier(null);
  ValueNotifier<String?> animatedReplyId = ValueNotifier(null);
  bool hasMoreComments = true;
  bool isLoadingComments = false;
  int commentPageSize = 10;

  // Thêm ScrollController cho comments
  final ScrollController commentsScrollController = ScrollController();

  //biến quản lý danh sách sinh viên của khóa học
  ValueNotifier<List<StudentModel>?> studentsOfCourse = ValueNotifier(null);
  int currentPageStudents = 0;
  bool hasMoreStudents = true;
  bool isLoadingStudents = false;
  int pageSize = 20;

  //biến quản lý danh sách yêu cầu vào khóa học của sinh viên
  ValueNotifier<List<RequestModel>?> listRequestToCourse = ValueNotifier(null);
  int currentPageRequests = 0;
  bool hasMoreRequests = true;
  bool isLoadingRequests = false;

  // Thêm ScrollController để xử lý loadmore
  final ScrollController studentsScrollController = ScrollController();
  final ScrollController requestsScrollController = ScrollController();

  //biến quản lý danh sách sinh viên của tìm kiếm
  ValueNotifier<List<StudentModel>?> studentsSearch = ValueNotifier(null);
  TextEditingController keywordController = TextEditingController();

  //biến quản lý có show x ra hay không
  ValueNotifier<bool> isEndDate = ValueNotifier(false);

  //biến quản lý picker image
  ImagePicker pickerImage = ImagePicker();
  ValueNotifier<XFile?> imageCoursePicker = ValueNotifier(null);

  //biến quản lý picker file của material
  ValueNotifier<XFile?> filePickerMaterial = ValueNotifier(null);

  //biến quản lý picker file của chapter
  ValueNotifier<XFile?> filePickerChapter = ValueNotifier(null);
  TextEditingController chapterNameController = TextEditingController();

  //biến quản lý tạo bài học:
  TextEditingController lessonNameController = TextEditingController();

  //biến quản lý tạo quiz trong lesson:
  ValueNotifier<List<LessonQuizModel>?> quizs = ValueNotifier(null);
  TextEditingController quizQuestionController = TextEditingController();
  final ValueNotifier<List<TextEditingController>> quizOptionControllers = ValueNotifier<List<TextEditingController>>([
    TextEditingController(),
    TextEditingController(),
  ]);
  String? selectedAnswer;

  // Danh sách sinh viên đã chọn để thêm vào lớp
  ValueNotifier<List<StudentModel>> selectedStudents = ValueNotifier([]);
  bool _isSocketConnected = false;

  late StompService stompService;

  void _onStudentsScroll() {
    if (!studentsScrollController.hasClients) return;

    if (studentsScrollController.position.pixels >= studentsScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingStudents && hasMoreStudents) {
        getStudentsOfCourse(isLoadMore: true);
      }
    }
  }

  void _onRequestsScroll() {
    if (!requestsScrollController.hasClients) return;

    if (requestsScrollController.position.pixels >= requestsScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingRequests && hasMoreRequests) {
        getAllRequestToCourse(isLoadMore: true);
      }
    }
  }

  void pickCourseImage() async {
    imageCoursePicker.value = await pickerImage.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  Future<void> pickFile(ValueNotifier<XFile?> fileNotify) async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'mp4',
          'mov', //định dạng video của Apple
        ],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final extension = file.extension?.toLowerCase();

        // Kiểm tra loại file
        if (extension != null) {
          final allowedExtensions = [
            'pdf',
            'doc',
            'docx',
            'txt',
            'mp4',
            'mov',
          ];

          if (!allowedExtensions.contains(extension)) {
            showToast(
              title: 'Định dạng file không được hỗ trợ',
              type: ToastificationType.error,
            );
            return;
          }
        }

        fileNotify.value = XFile(file.path!);
        notifyListeners();
      }
    } catch (e) {
      showToast(
        title: 'Không thể chọn file. Vui lòng thử lại!',
        type: ToastificationType.error,
      );
    }
  }

  void setPickerEmpty() async {
    imageCoursePicker.value = null;
  }

  List<StatusOption> statusOptions = [
    StatusOption(Status.PUBLIC, 'Công khai', 'PUBLIC'),
    StatusOption(Status.PRIVATE, 'Riêng tư', 'PRIVATE'),
    StatusOption(Status.REQUEST, 'Yêu cầu tham gia', 'REQUEST'),
  ];

  List<LearningDurationTypeOption> learningDurationOptions = [
    LearningDurationTypeOption(LearningDurationType.LIMITED, 'Có thời hạn', 'LIMITED'),
    LearningDurationTypeOption(LearningDurationType.UNLIMITED, 'Không có thời hạn', 'UNLIMITED'),
  ];

  List<FeeStatusOption> freeStatusOptions = [
    FeeStatusOption(FeeStatusType.CHARGEABLE, 'Tính phí', 'CHARGEABLE'),
    FeeStatusOption(FeeStatusType.NON_CHARGEABLE, 'Không tính phí', 'NON_CHARGEABLE'),
  ];

  init() async {
    course = Get.arguments['course'];
    await _loadCourseDetail();
    teacher.value = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    isEndDate.value = endDateController.text.isNotEmpty;

    // Thêm listener cho ScrollController
    studentsScrollController.addListener(_onStudentsScroll);
    requestsScrollController.addListener(_onRequestsScroll);
    setupSocket();
  }

  @override
  void dispose() {
    // Hủy đăng ký listener StompService
    if (_isSocketConnected && stompService != null) {
      try {
        logger.i("Hủy đăng ký listener khi thoát màn hình");
        stompService.unregisterListener(type: StompListenType.comment, listener: this);
        stompService.unregisterListener(type: StompListenType.editComment, listener: this);
        stompService.unregisterListener(type: StompListenType.reply, listener: this);
        stompService.unregisterListener(type: StompListenType.editReply, listener: this);
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

    // Dispose ScrollController khi đóng
    studentsScrollController.removeListener(_onStudentsScroll);
    requestsScrollController.removeListener(_onRequestsScroll);
    studentsScrollController.dispose();
    requestsScrollController.dispose();

    // Gọi super.dispose() để hoàn tất việc giải phóng tài nguyên
    super.dispose();
  }

  void initBottomSheet() async {
    await _loadMajor();
    courseNameController.text = courseDetail.value?.name ?? '';
    courseDescriptionController.text = courseDetail.value?.description ?? '';
    final price = courseDetail.value?.price;
    priceController.text = price != null ? price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2) : '';
    startDateController.text = AppUtils.formatDateToDDMMYYYY(courseDetail.value?.startDate?.toString() ?? '');
    endDateController.text = AppUtils.formatDateToDDMMYYYY(courseDetail.value?.endDate?.toString() ?? '');
    isEndDate.value = endDateController.text.isNotEmpty;
    isEndDate.notifyListeners();
    majorSelected.value = _getMajor(courseDetail.value?.major ?? '');
    statusSelected.value = statusOptions.firstWhere(
      (option) => option.apiValue == courseDetail.value?.status,
      orElse: () => statusOptions.first,
    );

    // Khởi tạo giá trị cho feeTypeSelected dựa trên feeType của khóa học
    String? courseFeeType = courseDetail.value?.feeType;
    feeTypeSelected.value = freeStatusOptions.firstWhere(
      (option) => option.apiValue == courseFeeType,
      orElse: () => price != null && price > 0
          ? freeStatusOptions.firstWhere((e) => e.value == FeeStatusType.CHARGEABLE)
          : freeStatusOptions.firstWhere((e) => e.value == FeeStatusType.NON_CHARGEABLE),
    );

    majorSelected.notifyListeners();
    statusSelected.notifyListeners();
    feeTypeSelected.notifyListeners();
  }

  Future<void> _loadCourseDetail() async {
    NetworkState<CourseDetailModel> resultCourseDetail = await courseRepository.getCourseDetail(courseId: course?.id);
    if (resultCourseDetail.isSuccess && resultCourseDetail.result != null) {
      courseDetail.value = resultCourseDetail.result;
      courseDetail.notifyListeners();
    }
  }

  //Các hàm chình sửa khóa học
  void updateCourse() async {
    if (statusSelected.value == null && priceController.text.isEmpty) {
      showToast(title: 'Vui lòng chọn trạng thái khóa học', type: ToastificationType.warning);
      return;
    }

    String learningDurationTypeString = getLearningDurationTypeLabel(
        endDateController.text.isEmpty ? LearningDurationType.UNLIMITED : LearningDurationType.LIMITED);

    // Sử dụng feeTypeSelected để xác định loại phí
    String feeTypeString = feeTypeSelected.value?.apiValue ??
        getFeeTypeAPIValue(priceController.text.isEmpty ? FeeStatusType.NON_CHARGEABLE : FeeStatusType.CHARGEABLE);

    String? price = priceController.text.trim().replaceAll(',', '.');
    if (price.isNotEmpty) statusSelected.value = StatusOption(Status.REQUEST, 'Yêu cầu tham gia', 'REQUEST');

    setLoading(false);
    NetworkState<CourseModel> resultUpdateCourse = await courseRepository.updateCourse(
      courseId: course?.id,
      name: courseNameController.text,
      description: courseDescriptionController.text,
      status: statusSelected.value?.apiValue ?? StatusOption(Status.REQUEST, 'Yêu cầu tham gia', 'REQUEST').apiValue,
      startDate: AppUtils.formatDateToISO(startDateController.text),
      endDate: AppUtils.formatDateToISO(endDateController.text),
      majorId: majorSelected.value?.id,
      learningDurationType: learningDurationTypeString,
      feeType: feeTypeString,
      price: price,
    );
    setLoading(false);
    if (resultUpdateCourse.isSuccess && resultUpdateCourse.result != null) {
      if (imageCoursePicker.value != null) {
        NetworkState resultUploadImage =
            await courseRepository.uploadImage(id: resultUpdateCourse.result?.id, image: imageCoursePicker.value);
        if (resultUploadImage.isError) {
          showToast(title: 'Cập nhật ảnh thất bại, vui lòng thử lại sau!', type: ToastificationType.error);
          course?.copyWith(image: resultUploadImage.result);
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      showToast(title: 'Chỉnh sửa khóa học thành công!');
      await Future.delayed(const Duration(seconds: 2));
      await _loadCourseDetail();

      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
      Get.back();
    } else {
      showToast(title: resultUpdateCourse.message ?? '', type: ToastificationType.error);
    }
  }

  String getFeeTypeAPIValue(FeeStatusType type) => freeStatusOptions.firstWhere((e) => e.value == type).apiValue;

  String getStatusLabel(Status status) => statusOptions.firstWhere((e) => e.value == status).label;

  String getLearningDurationTypeLabel(LearningDurationType type) =>
      learningDurationOptions.firstWhere((e) => e.value == type).apiValue;

  Future<void> _loadMajor() async {
    NetworkState<List<MajorModel>> resultMajor = await majorRepository.getAllMajor();
    setLoading(false);
    if (resultMajor.isSuccess && resultMajor.result != null) {
      majors.value = resultMajor.result ?? [];
      majors.notifyListeners();
    }
  }

  Future<void> addLesson() async {
    int? countLessonLength = courseDetail.value?.lesson?.length;

    if (countLessonLength == null) {
      showToast(title: 'Lỗi hệ thống, vui lòng thử lại sau!', type: ToastificationType.warning);
      return;
    }
    setLoading(true);

    NetworkState<LessonModel> resultAddLesson = await courseRepository.addLesson(
        description: lessonNameController.text, courseId: courseDetail.value?.id, order: countLessonLength + 1);
    setLoading(false);

    if (resultAddLesson.isSuccess && resultAddLesson.result != null) {
      await _loadCourseDetail();
      showToast(title: 'Thêm bài học thành công', type: ToastificationType.success);
      lessonNameController.text = '';
      Get.back();
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      showToast(title: resultAddLesson.message ?? '', type: ToastificationType.success);
    }
  }

  Future<void> addMaterial({required LessonModel lesson}) async {
    if (filePickerMaterial.value == null) {
      showToast(
        title: 'Vui lòng chọn file',
        type: ToastificationType.error,
      );
      return;
    }

    setLoading(true);

    NetworkState<LessonMaterialModel> resultAddMaterial = await courseRepository.addMaterial(
      id: lesson.id,
      name: materialNameController.text,
      file: filePickerMaterial.value,
      type: 'file',
    );
    setLoading(false);

    if (resultAddMaterial.isSuccess && resultAddMaterial.result != null) {
      showToast(
        title: 'Thêm tài liệu thành công',
        type: ToastificationType.success,
      );
      await _loadCourseDetail();
      materialNameController.clear();
      Get.back();
      filePickerMaterial.value = null;
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      showToast(
        title: resultAddMaterial.message ?? '',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> addChapter({required LessonModel lesson}) async {
    int? countChapterInLesson = lesson.chapters?.length;

    if (countChapterInLesson == null) {
      showToast(
        title: 'Lỗi hệ thống, vui lòng thử lại sau!',
        type: ToastificationType.error,
      );
      return;
    }

    if (filePickerChapter.value == null) {
      showToast(
        title: 'Vui lòng chọn file',
        type: ToastificationType.error,
      );
      return;
    }

    String? type;
    final extension = filePickerChapter.value?.path.split('.').last.toLowerCase();

    // Kiểm tra nếu là file ảnh
    if (['mov', 'mp4'].contains(extension)) {
      type = 'video';
    } else {
      type = 'file';
    }
    setLoading(true);
    NetworkState<ChapterModel> resultAddChapter = await courseRepository.addMChapter(
      lessonId: lesson.id,
      name: chapterNameController.text,
      order: countChapterInLesson + 1,
      file: filePickerChapter.value,
      type: type,
    );
    setLoading(false);

    if (resultAddChapter.isSuccess && resultAddChapter.result != null) {
      showToast(
        title: 'Thêm bài học thành công',
        type: ToastificationType.success,
      );
      await _loadCourseDetail();
      Get.back();
      chapterNameController.text = '';
      filePickerChapter.value = null;
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      showToast(
        title: resultAddChapter.message ?? '',
        type: ToastificationType.error,
      );
    }
  }

  MajorModel? _getMajor(String majorName) {
    if (majorName.isEmpty) return null;
    for (var e in majors.value ?? []) {
      if (e.name?.contains(majorName) ?? false) {
        return e;
      }
    }
    return null;
  }

  void setMajor(MajorModel major) {
    majorSelected.value = major;
    majorSelected.notifyListeners();
  }

  //Các hàm quản lý cho việc tạo quiz
  void initQuiz() {
    quizs.value = [];
    quizQuestionController.clear();
    quizOptionControllers.value = [
      TextEditingController(),
      TextEditingController(),
    ];
    selectedAnswer = null;
  }

  void addOption() {
    if (quizOptionControllers.value.length < 6) {
      final newControllers = List<TextEditingController>.from(quizOptionControllers.value);
      newControllers.add(TextEditingController());
      quizOptionControllers.value = newControllers;
    }
  }

  void removeOption(int index) {
    if (quizOptionControllers.value.length > 2) {
      final newControllers = List<TextEditingController>.from(quizOptionControllers.value);
      newControllers.removeAt(index);
      quizOptionControllers.value = newControllers;

      if (selectedAnswer == _getOptionLetter(index)) {
        selectedAnswer = null;
      }
    }
  }

  String _getOptionLetter(int index) {
    return String.fromCharCode(65 + index); // A, B, C, D, E, F
  }

  void addQuiz() {
    if (quizQuestionController.text.isEmpty) {
      showToast(
        title: 'Vui lòng nhập câu hỏi',
        type: ToastificationType.error,
      );
      return;
    }

    // Kiểm tra các lựa chọn
    final options = quizOptionControllers.value;
    if (options.any((controller) => controller.text.isEmpty)) {
      showToast(
        title: 'Vui lòng nhập đầy đủ các lựa chọn',
        type: ToastificationType.error,
      );
      return;
    }

    if (selectedAnswer == null) {
      showToast(
        title: 'Vui lòng chọn đáp án đúng',
        type: ToastificationType.error,
      );
      return;
    }

    // Format options với chữ cái
    final formattedOptions = options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value.text;
      return '${String.fromCharCode(65 + index)}. $option';
    }).join('; ');

    final newQuiz = LessonQuizModel(
      question: quizQuestionController.text,
      option: formattedOptions,
      answer: selectedAnswer,
    );

    final currentQuizs = quizs.value ?? [];
    quizs.value = [...currentQuizs, newQuiz];

    // Reset form
    quizQuestionController.clear();
    for (var controller in quizOptionControllers.value) {
      controller.clear();
    }
    selectedAnswer = null;
  }

  void removeQuiz(int index) {
    if (quizs.value != null) {
      quizs.value!.removeAt(index);
      quizs.notifyListeners();
    }
  }

  Future<void> saveQuiz(LessonModel lesson, BuildContext context) async {
    if (quizs.value == null || quizs.value!.isEmpty) {
      showToast(
        title: 'Vui lòng thêm ít nhất một câu hỏi',
        type: ToastificationType.error,
      );
      return;
    }
    setLoading(true);

    NetworkState<List<LessonQuizModel>> result = await courseRepository.addQuiz(
      lessonId: lesson.id,
      quizs: quizs.value!,
    );
    setLoading(false);

    if (result.isSuccess && result.result != null) {
      await _loadCourseDetail();
      initQuiz();
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
      showToast(
        title: 'Thêm bài kiểm tra thành công',
        type: ToastificationType.success,
      );
    } else {
      showToast(
        title: result.message ?? '',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> getStudentsOfCourse({bool isLoadMore = false}) async {
    if (isLoadingStudents) return;

    try {
      isLoadingStudents = true;

      if (!isLoadMore) {
        currentPageStudents = 0;
        hasMoreStudents = true;
        studentsOfCourse.value = [];
      }

      if (!hasMoreStudents) {
        isLoadingStudents = false;
        return;
      }

      NetworkState<List<StudentModel>> resultStudentsOfCourse = await courseRepository.getAllStudentOfCourse(
          courseId: courseDetail.value?.id, pageSize: pageSize, pageNumber: currentPageStudents);

      if (resultStudentsOfCourse.isSuccess && resultStudentsOfCourse.result != null) {
        final newStudents = resultStudentsOfCourse.result ?? [];

        if (newStudents.length < pageSize) {
          hasMoreStudents = false;
        }

        if (isLoadMore) {
          studentsOfCourse.value = [...(studentsOfCourse.value ?? []), ...newStudents];
        } else {
          studentsOfCourse.value = newStudents;
        }

        currentPageStudents++;
        studentsOfCourse.notifyListeners();
      } else {
        showToast(title: resultStudentsOfCourse.message ?? '', type: ToastificationType.error);
      }
    } catch (e) {
      showToast(
        title: 'Không thể tải danh sách sinh viên',
        type: ToastificationType.error,
      );
    } finally {
      isLoadingStudents = false;
    }
  }

  Future<void> removeStudentOfCourse({String? studentId, required BuildContext context}) async {
    NetworkState resultRemoveStudentsOfCourse =
        await courseRepository.removeStudent(courseId: courseDetail.value?.id, studentId: studentId);
    if (resultRemoveStudentsOfCourse.isSuccess) {
      await getStudentsOfCourse();
      await _loadCourseDetail();
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
      showToast(title: 'Xóa sinh viên khỏi khóa học thành công', type: ToastificationType.success);
    } else {
      showToast(title: resultRemoveStudentsOfCourse.message ?? '', type: ToastificationType.error);
    }
  }

  Future<void> searchStudentNotInCourse({String? keyword}) async {
    if (keyword == null || keyword.isEmpty) {
      studentsSearch.value = null;
      studentsSearch.notifyListeners();
      return;
    }

    NetworkState resultSearchStudent =
        await studentRepository.searchStudentNotInCourse(courseId: courseDetail.value?.id ?? '', keyword: keyword);
    if (resultSearchStudent.isSuccess && resultSearchStudent.result != null) {
      studentsSearch.value = resultSearchStudent.result;
      studentsSearch.notifyListeners();
    }
  }

  void addSelectedStudent(StudentModel student) {
    if (!selectedStudents.value.any((s) => s.id == student.id)) {
      selectedStudents.value = [...selectedStudents.value, student];
      selectedStudents.notifyListeners();
      keywordController.text = '';
    }
  }

  void cleanListStudentSearch() {
    studentsSearch.value = null;
  }

  void cleanStudentsSelected() {
    selectedStudents.value = [];
  }

  void removeSelectedStudent(StudentModel student) {
    selectedStudents.value = selectedStudents.value.where((s) => s.id != student.id).toList();
    selectedStudents.notifyListeners();
  }

  void addAllStudentToCourse(BuildContext context, List<StudentModel> students) async {
    NetworkState resultAddStudents =
        await courseRepository.addStudents(courseId: courseDetail.value?.id ?? '', students: students);
    if (resultAddStudents.isSuccess) {
      showToast(title: 'Thêm sinh viên vào khóa học thành công', type: ToastificationType.success);
      await _loadCourseDetail();
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: resultAddStudents.message ?? 'N/A ADD STUDENT', type: ToastificationType.error);
    }
  }

  Future<void> getAllRequestToCourse({bool isLoadMore = false}) async {
    if (isLoadingRequests) return;
    isLoadingRequests = true;

    if (!isLoadMore) {
      currentPageRequests = 0;
      hasMoreRequests = true;
      listRequestToCourse.value = [];
    }

    if (!hasMoreRequests) {
      isLoadingRequests = false;
      return;
    }

    NetworkState<List<RequestModel>> resultListRequestToCourse = await courseRepository.getAllRequestToCourse(
        courseId: courseDetail.value?.id ?? '', pageSize: pageSize, pageNumber: currentPageRequests);

    if (resultListRequestToCourse.isSuccess && resultListRequestToCourse.result != null) {
      final newRequests = resultListRequestToCourse.result ?? [];

      if (newRequests.length < pageSize) {
        hasMoreRequests = false;
      }

      if (isLoadMore) {
        listRequestToCourse.value = [...(listRequestToCourse.value ?? []), ...newRequests];
      } else {
        listRequestToCourse.value = newRequests;
      }

      currentPageRequests++;
      listRequestToCourse.notifyListeners();
      isLoadingRequests = false;
    } else {
      showToast(
        title: resultListRequestToCourse.message ?? '',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> rejectedRequest(String studentId, BuildContext context) async {
    NetworkState resultReject =
        await courseRepository.rejectedRequest(courseId: courseDetail.value?.id ?? '', studentId: studentId);
    if (resultReject.isSuccess) {
      showToast(title: 'Từ chối yêu cầu thành công', type: ToastificationType.success);
      getAllRequestToCourse();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: 'Từ chối yêu cầu thất bại, ${resultReject.message}', type: ToastificationType.error);
    }
  }

  Future<void> approvedRequest(String studentId, BuildContext context) async {
    NetworkState resultApproved =
        await courseRepository.approvedRequest(courseId: courseDetail.value?.id ?? '', studentId: studentId);
    if (resultApproved.isSuccess) {
      showToast(title: 'Chấp nhận yêu cầu thành công', type: ToastificationType.success);
      getAllRequestToCourse();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: 'Chấp nhận yêu cầu thất bại, ${resultApproved.message}', type: ToastificationType.error);
    }
  }

  void safelyUpdateNotifier<T>(ValueNotifier<T> notifier, T value) {
    // Kiểm tra trùng lặp dữ liệu trước khi cập nhật
    if (notifier.value == value) {
      logger.i("Dữ liệu không thay đổi, bỏ qua cập nhật ValueNotifier");
      return;
    }

    notifier.value = value;
    try {
      notifier.notifyListeners();
      logger.i("Đã cập nhật ValueNotifier thành công");
    } catch (e) {
      logger.e("Lỗi update ValueNotifier: $e");
    }
  }

  Future<void> setupSocket() async {
    try {
      // Kiểm tra kết nối đã được thiết lập chưa
      if (_isSocketConnected && stompService != null) {
        logger.i("Kết nối socket đã tồn tại, không cần thiết lập lại");
        return;
      }

      logger.i("Đang thiết lập kết nối socket...");

      // Khởi tạo hoặc lấy instance của StompService
      stompService = await StompService.instance();

      // Hủy đăng ký listener cũ nếu có
      try {
        stompService.unregisterListener(type: StompListenType.comment, listener: this);
        stompService.unregisterListener(type: StompListenType.editComment, listener: this);
        stompService.unregisterListener(type: StompListenType.reply, listener: this);
        stompService.unregisterListener(type: StompListenType.editReply, listener: this);
      } catch (e) {
        logger.w("Không thể hủy đăng ký listener cũ: $e");
      }

      // Đăng ký listener cho từng loại kênh, xử lý lỗi riêng cho từng loại
      logger.i("Bắt đầu đăng ký các listener cho socket");

      try {
        stompService.registerListener(type: StompListenType.comment, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.comment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.comment: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.editComment, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.editComment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.editComment: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.reply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.reply");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.reply: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.editReply, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.editReply");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.editReply: $e");
      }

      _isSocketConnected = true;
      logger.i("Socket đã được kết nối và đăng ký listener thành công");

      // Tải comments ban đầu
      loadComments();
    } catch (e) {
      logger.e("Lỗi trong quá trình khởi tạo: $e");
      _isSocketConnected = false;
    }
  }

  Future<void> send({CommentModel? comment}) async {
    // Đảm bảo STOMP đã được kết nối
    if (stompService == null || !_isSocketConnected) {
      logger.i("STOMP chưa kết nối, thiết lập kết nối...");
      await setupSocket();

      if (!_isSocketConnected) {
        logger.e("Không thể kết nối STOMP, hủy gửi tin nhắn");
        showToast(title: "Không thể kết nối đến máy chủ, vui lòng thử lại sau", type: ToastificationType.error);
        return;
      }
    }

    if (chapterSelected.value == null) {
      logger.e("Không có nội dung hiện tại, hủy gửi tin nhắn");
      return;
    }

    if (comment == null) {
      logger.i('Đang gửi comment mới');
      logger.i('Student info: ${teacher.value}');
      try {
        final payload = {
          'chapterId': chapterSelected.value?.id,
          'courseId': courseDetail.value?.id ?? '',
          'username': teacher.value?.email ?? '',
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
      logger.i('Đang gửi reply cho comment: ${commentSelected.value?.username}');
      try {
        logger.i('Comment được chọn: ${commentSelected.value}');
        final payload = {
          'replyUsername': teacher.value?.email,
          'ownerUsername': commentSelected.value?.username,
          'chapterId': chapterSelected.value?.id,
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
        showToast(title: "Gửi phản hồi thất bại!!!", type: ToastificationType.error);
      }
    }
    setCommentSelected();
  }

  Future<void> editComment({required String commentId, required String detail}) async {
    await StompService.instance();
    if (chapterSelected.value == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editComment,
        jsonEncode({
          'commentId': commentId,
          'usernameOwner': teacher.value?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(title: "Chỉnh sửa bình luận thất bại!", type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa comment: $e");
    }
  }

  Future<void> editReply({required String replyId, required String parentCommentId, required String detail}) async {
    await StompService.instance();
    if (chapterSelected.value == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editReply,
        jsonEncode({
          'commentReplyId': replyId,
          'usernameReply': teacher.value?.email ?? '',
          'newDetail': detail,
        }),
      );
    } catch (e) {
      showToast(title: "Chỉnh sửa phản hồi thất bại!", type: ToastificationType.error);
      logger.e("Lỗi khi chỉnh sửa reply: $e");
    }
  }

  // Hàm thiết lập comment được chọn để phản hồi
  void setCommentSelected({CommentModel? comment}) {
    commentSelected.value = comment;
    commentSelected.notifyListeners();
  }

  // Hàm tải comments của khóa học
  Future<void> loadComments({bool isReset = false, int? pageSize}) async {
    if (isReset) {
      hasMoreComments = true;
      comments.value = null;
    }

    if (!hasMoreComments || isLoadingComments) return;

    isLoadingComments = true;
    notifyListeners();

    try {
      final String? courseId = courseDetail.value?.id;
      final String? chapterId = chapterSelected.value?.id;

      if (courseId == null || chapterId == null) {
        logger.e("Không thể tải comments: courseId hoặc chapterId không tồn tại");
        isLoadingComments = false;
        notifyListeners();
        return;
      }

      // Sử dụng pageSize từ tham số nếu có, ngược lại dùng giá trị mặc định
      final int effectivePageSize = pageSize ?? commentPageSize;

      // Tính toán pageNumber dựa trên kích thước hiện tại của danh sách comments
      final int pageNumber = (comments.value?.length ?? 0);

      logger.i("Tải comments cho chapter: $chapterId, pageNumber: $pageNumber, pageSize: $effectivePageSize");

      final NetworkState<List<CommentModel>> result = await commentRepository.commentInChapter(
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
            if (!existingComments.any((c) => c.commentId == comment.commentId)) {
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
      final commentIndex = existingComments.indexWhere((c) => c.commentId == commentId);

      if (commentIndex == -1) return;

      final comment = existingComments[commentIndex];

      // Sử dụng chính xác số lượng replies hiện tại làm pageNumber
      final int currentRepliesCount = comment.commentReplyResponses?.length ?? 0;

      logger.i("Tải replies cho comment: $commentId, pageNumber: $currentRepliesCount");

      final NetworkState<List<ReplyModel>> result = await commentRepository.getReplies(
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
          if (!(comment.commentReplyResponses ?? [])
              .any((existingReply) => existingReply.commentReplyId == newReply.commentReplyId)) {
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
      animatedCommentId.value = comment.commentId;
      Future.delayed(Duration(seconds: 2), () {
        animatedCommentId.value = null;
      });
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
      animatedReplyId.value = reply.commentReplyId;
      Future.delayed(Duration(seconds: 2), () {
        animatedReplyId.value = null;
      });
    } catch (e) {
      logger.e("Lỗi khi xử lý reply từ socket: $e");
    }
  }

  // Hàm hỗ trợ thêm comment mới vào danh sách
  void _addNewComment(CommentModel newComment) {
    if (comments.value == null) {
      comments.value = [newComment];
    } else {
      // Kiểm tra xem comment đã tồn tại chưa
      final List<CommentModel> currentComments = List.from(comments.value!);
      final bool exists = currentComments.any((comment) => comment.commentId == newComment.commentId);

      if (!exists) {
        comments.value = [newComment, ...currentComments];
      }
    }
    comments.notifyListeners();
  }

  // Hàm hỗ trợ cập nhật comment đã tồn tại
  void _updateExistingComment(CommentModel updatedComment) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int index = currentComments.indexWhere((comment) => comment.commentId == updatedComment.commentId);

    if (index != -1) {
      // Cập nhật nội dung comment nhưng giữ nguyên replies
      final CommentModel existingComment = currentComments[index];
      final updatedWithExistingReplies = updatedComment.copyWith(
        commentReplyResponses: existingComment.commentReplyResponses,
      );

      currentComments[index] = updatedWithExistingReplies;
      comments.value = currentComments;
      comments.notifyListeners();
    }
  }

  // Hàm hỗ trợ thêm reply mới vào comment cha
  void _addNewReply(ReplyModel newReply, String parentCommentId) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments.indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];

      // Kiểm tra xem reply đã tồn tại chưa
      final List<ReplyModel> existingReplies = parentComment.commentReplyResponses ?? [];
      final bool replyExists = existingReplies.any((reply) => reply.commentReplyId == newReply.commentReplyId);

      if (!replyExists) {
        // Tạo bản sao của comment cha với danh sách replies đã cập nhật
        final CommentModel updatedParentComment = parentComment.copyWith(
          countOfReply: newReply.replyCount,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;
        comments.notifyListeners();
      }
    }
  }

  // Hàm hỗ trợ cập nhật reply đã tồn tại
  void _updateExistingReply(ReplyModel updatedReply, String parentCommentId) {
    if (comments.value == null) return;

    final List<CommentModel> currentComments = List.from(comments.value!);
    final int commentIndex = currentComments.indexWhere((comment) => comment.commentId == parentCommentId);

    if (commentIndex != -1) {
      final CommentModel parentComment = currentComments[commentIndex];
      final List<ReplyModel> replies = parentComment.commentReplyResponses ?? [];

      final int replyIndex = replies.indexWhere((reply) => reply.commentReplyId == updatedReply.commentReplyId);

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
        comments.notifyListeners();
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

  void setChapter(ChapterModel chapter) {
    chapterSelected.value = chapter;
  }

  void removeCourse() async {
    NetworkState resultRemoveCourse = await courseRepository.removeCourse(course?.id);
    if (resultRemoveCourse.isSuccess) {
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        showToast(title: 'Xóa khóa học thành công', type: ToastificationType.success);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      Get.back();
    }
  }

  void updateLesson(LessonModel? lesson) async {
    NetworkState resultUpdateLesson = await courseRepository.updateLesson(lesson: lesson);
    if (resultUpdateLesson.isSuccess) {
      _loadCourseDetail();
      showToast(
        title: 'Cập nhật bài học thành công',
        type: ToastificationType.success,
      );
    }
  }

  void updateChapter(ChapterModel? chapter) {
    logger.w('Update chapter: ${chapter.toString()}');
  }

  void deleteLesson(LessonModel? lesson) async {
    NetworkState resultDeleteLesson = await courseRepository.deleteLesson(lessonId: lesson?.id ?? '');
    if (resultDeleteLesson.isSuccess) {
      _loadCourseDetail();
      showToast(
        title: 'Xóa bài học thành công',
        type: ToastificationType.success,
      );
    }
  }

  void deleteChapter(ChapterModel? chapter) async {
    NetworkState resultDeleteChapter = await courseRepository.deleteChapter(chapterId: chapter?.id ?? '');
    if (resultDeleteChapter.isSuccess) {
      _loadCourseDetail();
      showToast(
        title: 'Xóa chương thành công',
        type: ToastificationType.success,
      );
    }
  }

  void deleteMaterial(LessonMaterialModel? material) async {
    NetworkState resultDeleteMaterial = await courseRepository.deleteMaterial(materialId: material?.id ?? '');
    if (resultDeleteMaterial.isSuccess) {
      _loadCourseDetail();
      showToast(
        title: 'Xóa chương tài liệu thành công',
        type: ToastificationType.success,
      );
    }
  }

  void deleteQuiz(LessonQuizModel? quiz) async {
    NetworkState resultDeleteMaterial = await courseRepository.deleteQuiz(quizId: quiz?.id ?? '');
    if (resultDeleteMaterial.isSuccess) {
      _loadCourseDetail();
      showToast(
        title: 'Xóa chương bài kiểm tra thành công',
        type: ToastificationType.success,
      );
    }
  }
}
