import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class CourseDetailTeacherViewModel extends BaseViewModel {
  CourseModel? course;
  ValueNotifier<CourseDetailModel?> courseDetail = ValueNotifier(null);

  //Các biến của chỉnh sửa khóa học
  var formKey = GlobalKey<FormState>();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  ValueNotifier<List<MajorModel>?> majors = ValueNotifier(null);
  ValueNotifier<StatusOption?> statusSelected = ValueNotifier(null);
  ValueNotifier<MajorModel?> majorSelected = ValueNotifier(null);

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
    LearningDurationTypeOption(LearningDurationType.LIMIT, 'Có thời hạn', 'LIMIT'),
    LearningDurationTypeOption(LearningDurationType.NOLIMIT, 'Không có thời hạn', 'NOLIMIT'),
  ];

  init() async {
    course = Get.arguments['course'];
    await _loadCourseDetail();
    isEndDate.value = endDateController.text.isNotEmpty;

    // Thêm listener cho ScrollController
    studentsScrollController.addListener(_onStudentsScroll);
    requestsScrollController.addListener(_onRequestsScroll);
  }

  @override
  void dispose() {
    // Dispose ScrollController khi đóng
    studentsScrollController.removeListener(_onStudentsScroll);
    requestsScrollController.removeListener(_onRequestsScroll);
    studentsScrollController.dispose();
    requestsScrollController.dispose();
    super.dispose();
  }

  void initBottomSheet() async {
    await _loadMajor();
    courseNameController.text = course?.name ?? '';
    courseDescriptionController.text = course?.description ?? '';
    endDateController.text = AppUtils.formatDateToDDMMYYYY(course?.endDate?.toString() ?? '');
    isEndDate.value = endDateController.text.isNotEmpty;
    isEndDate.notifyListeners();
    majorSelected.value = _getMajor(course?.major ?? '');
    statusSelected.value = statusOptions.firstWhere(
      (option) => option.apiValue == course?.status,
      orElse: () => statusOptions.first,
    );
    majorSelected.notifyListeners();
    statusSelected.notifyListeners();
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
    String learningDurationTypeString = getLearningDurationTypeLabel(
        endDateController.text.isEmpty ? LearningDurationType.NOLIMIT : LearningDurationType.LIMIT);
    setLoading(false);
    NetworkState<CourseModel> resultUpdateCourse = await courseRepository.updateCourse(
      courseId: course?.id,
      name: courseNameController.text,
      description: courseDescriptionController.text,
      status: statusSelected.value?.apiValue,
      endDate: AppUtils.formatDateToISO(endDateController.text),
      majorId: majorSelected.value?.id,
      learningDurationType: learningDurationTypeString,
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

  String getStatusLabel(Status status) => statusOptions.firstWhere((e) => e.value == status).label;

  String getLearningDurationTypeLabel(LearningDurationType type) =>
      learningDurationOptions.firstWhere((e) => e.value == type).label;

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

    NetworkState<LessonModel> resultAddLesson = await courseRepository.addLesson(
        description: lessonNameController.text, courseId: courseDetail.value?.id, order: countLessonLength + 1);

    if (resultAddLesson.isSuccess && resultAddLesson.result != null) {
      await _loadCourseDetail();
      showToast(title: 'Thêm bài học thành công', type: ToastificationType.success);
      lessonNameController.text = '';
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

    String? type;
    final extension = filePickerMaterial.value!.path.split('.').last.toLowerCase();

    // Kiểm tra nếu là file ảnh
    if (['mov', 'mp4'].contains(extension)) {
      type = 'video';
    } else {
      type = 'file';
    }

    NetworkState<LessonMaterialModel> resultAddMaterial = await courseRepository.addMaterial(
      id: lesson.id,
      file: filePickerMaterial.value,
      type: type,
    );

    if (resultAddMaterial.isSuccess && resultAddMaterial.result != null) {
      showToast(
        title: 'Thêm tài liệu thành công',
        type: ToastificationType.success,
      );
      await _loadCourseDetail();
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

    NetworkState<ChapterModel> resultAddChapter = await courseRepository.addMChapter(
      lessonId: lesson.id,
      name: chapterNameController.text,
      order: countChapterInLesson + 1,
      file: filePickerChapter.value,
      type: type,
    );

    if (resultAddChapter.isSuccess && resultAddChapter.result != null) {
      showToast(
        title: 'Thêm bài học thành công',
        type: ToastificationType.success,
      );
      await _loadCourseDetail();
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
    logger.e(quizs.value.toString());
    NetworkState<List<LessonQuizModel>> result = await courseRepository.addQuiz(
      lessonId: lesson.id,
      quizs: quizs.value!,
    );

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
      showToast(title: 'Thêm sinh viên vào khóa học không thành công', type: ToastificationType.error);
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
}
