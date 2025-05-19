import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:toastification/toastification.dart';

class GroupDetailTeacherViewModel extends BaseViewModel {
  TeacherModel? teacher;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ValueNotifier<GroupModel?> group = ValueNotifier(null);
  TextEditingController descriptionPost = TextEditingController();
  ValueNotifier<List<File>> filesPicker = ValueNotifier([]);
  ValueNotifier<List<PostModel>?> posts = ValueNotifier(null);
  ValueNotifier<List<TestModel>?> tests = ValueNotifier(null);
  ValueNotifier<List<StudentModel>> selectedStudents = ValueNotifier([]);
  ValueNotifier<List<StudentModel>?> students = ValueNotifier(null);
  ScrollController postScrollController = ScrollController();
  ScrollController testScrollController = ScrollController();
  ScrollController studentScrollController = ScrollController();
  TextEditingController keywordController = TextEditingController();
  ValueNotifier<List<StudentModel>?> studentsSearch = ValueNotifier(null);

  // Controller cho chức năng chỉnh sửa bài kiểm tra
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController expiredAtDateController = TextEditingController();
  TextEditingController expiredAtTimeController = TextEditingController();

  final int pageSize = 20;

  int pageNumberPost = 0;
  bool isLoadingPost = false;
  bool hasMorePost = true;

  int pageNumberTest = 0;
  bool isLoadingTest = false;
  bool hasMoreTest = true;

  int pageNumberStudent = 0;
  bool isLoadingStudent = false;
  bool hasMoreStudent = true;

  init() async {
    teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    group.value = Get.arguments['group'];

    refreshPost();
    refreshTest();
    refreshStudent();

    postScrollController.addListener(_onScrollPost);
    testScrollController.addListener(_onScrollTest);
    studentScrollController.addListener(_onScrollStudent);
  }

  void refreshPost() async {
    pageNumberPost = 0;
    hasMorePost = true;
    posts.value = [];
    await _loadPost();
  }

  void refreshTest() async {
    pageNumberTest = 0;
    hasMoreTest = true;
    tests.value = [];
    await _loadTest();
  }

  Future<void> refreshStudent() async {
    pageNumberStudent = 0;
    hasMoreStudent = true;
    students.value = [];
    await _loadStudent();
  }

  void _onScrollPost() {
    if (!isLoadingPost &&
        hasMorePost &&
        postScrollController.position.pixels >=
            postScrollController.position.maxScrollExtent - 300) {
      _loadPost();
    }
  }

  void _onScrollTest() {
    if (!isLoadingTest &&
        hasMoreTest &&
        testScrollController.position.pixels >=
            testScrollController.position.maxScrollExtent - 300) {
      _loadTest();
    }
  }

  void _onScrollStudent() {
    if (!isLoadingStudent &&
        hasMoreStudent &&
        studentScrollController.position.pixels >=
            studentScrollController.position.maxScrollExtent - 300) {
      _loadStudent();
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      filesPicker.value = result.paths.map((path) => File(path!)).toList();
    }
  }

  void removeFile(File file) {
    filesPicker.value = List<File>.from(filesPicker.value)..remove(file);
  }

  void createPost(BuildContext context) async {
    NetworkState<PostModel> resultPost = await groupRepository.createPost(
        groupId: group.value?.id,
        text: descriptionPost.text,
        filesPicker: filesPicker.value);
    if (resultPost.isSuccess && resultPost.result != null) {
      filesPicker.value = [];
      descriptionPost.text = '';
      pageNumberPost = 0;
      hasMorePost = true;
      posts.value = [];
      await _loadPost();
      showToast(
          title: 'Thêm bài đăng thành công!', type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(
          title: 'Lỗi ${resultPost.message}', type: ToastificationType.error);
    }
  }

  Future<void> _loadPost() async {
    if (isLoadingPost || !hasMorePost) return;

    isLoadingPost = true;

    try {
      NetworkState<List<PostModel>> resultPosts =
          await groupRepository.getPosts(
              groupId: group.value?.id ?? '',
              pageSize: pageSize,
              pageNumber: pageNumberPost);

      if (resultPosts.isSuccess && resultPosts.result != null) {
        if (resultPosts.result!.isEmpty) {
          hasMorePost = false;
        } else {
          final currentPosts = posts.value ?? [];
          posts.value = [...currentPosts, ...resultPosts.result!];
          pageNumberPost += 1;
        }
      } else {
        hasMorePost = false;
      }
    } catch (e) {
      hasMorePost = false;
    } finally {
      isLoadingPost = false;
    }
  }

  Future<void> _loadTest() async {
    if (isLoadingTest || !hasMoreTest) return;

    isLoadingTest = true;

    try {
      NetworkState<List<TestModel>> resultTests =
          await groupRepository.getTests(
              groupId: group.value?.id ?? '',
              pageSize: pageSize,
              pageNumber: pageNumberTest);

      if (resultTests.isSuccess && resultTests.result != null) {
        if (resultTests.result!.isEmpty) {
          hasMoreTest = false;
        } else {
          final currentTests = tests.value ?? [];
          tests.value = [...currentTests, ...resultTests.result!];
          pageNumberTest += 1;
        }
      } else {
        hasMoreTest = false;
      }
    } catch (e) {
      hasMoreTest = false;
    } finally {
      isLoadingTest = false;
    }
  }

  Future<void> _loadStudent() async {
    if (isLoadingStudent || !hasMoreStudent) return;

    isLoadingStudent = true;

    try {
      NetworkState<List<StudentModel>> resultStudents =
          await groupRepository.getStudents(
              groupId: group.value?.id ?? '',
              pageSize: pageSize,
              pageNumber: pageNumberStudent);

      if (resultStudents.isSuccess && resultStudents.result != null) {
        if (resultStudents.result!.isEmpty) {
          hasMoreStudent = false;
        } else {
          final currentStudents = students.value ?? [];
          students.value = [...currentStudents, ...resultStudents.result!];
          pageNumberStudent += 1;
        }
      } else {
        hasMoreStudent = false;
      }
    } catch (e) {
      hasMoreStudent = false;
    } finally {
      isLoadingStudent = false;
    }
  }

  Future<void> delete(String postId) async {
    NetworkState resultPosts = await groupRepository.deletePost(postId);
    if (resultPosts.isSuccess) {
      showToast(title: 'Xóa post thành công', type: ToastificationType.success);
      refreshPost();
    } else {
      showToast(
          title: 'Lỗi ${resultPosts.message}', type: ToastificationType.error);
    }
  }

  void createTest() {
    Get.toNamed(Routers.createTest, arguments: {'group': group.value});
  }

  void testDetail(TestModel test) {
    Get.toNamed(Routers.testDetailTeacher, arguments: {'test': test});
  }

  void cleanListStudentSearch() {
    studentsSearch.value = null;
  }

  void removeSelectedStudent(StudentModel student) {
    selectedStudents.value =
        selectedStudents.value.where((s) => s.id != student.id).toList();
    selectedStudents.notifyListeners();
  }

  Future<void> searchStudentNotInGroup({String? keyword}) async {
    if (keyword == null || keyword.isEmpty) {
      studentsSearch.value = null;
      studentsSearch.notifyListeners();
      return;
    }

    NetworkState<List<StudentModel>> resultSearchStudent =
        await studentRepository.searchStudentNotInGroup(
            groupId: group.value?.id ?? '', keyword: keyword);
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

  void cleanStudentsSelected() {
    selectedStudents.value = [];
  }

  void addAllStudentToGroup(
      BuildContext context, List<StudentModel> students) async {
    NetworkState resultAddStudents = await groupRepository.addStudents(
        groupId: group.value?.id ?? '', students: students);
    if (resultAddStudents.isSuccess) {
      await refreshStudent();
      showToast(
          title: 'Thêm sinh viên vào nhóm thành công',
          type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(
          title: resultAddStudents.message ?? '',
          type: ToastificationType.error);
    }
  }

  void removeStudent({String? studentId, required BuildContext context}) async {
    setLoading(true);
    NetworkState resultRemoveStudent = await groupRepository.removeStudent(
        groupId: group.value?.id, studentId: studentId);
    if (resultRemoveStudent.isSuccess) {
      setLoading(false);
      await refreshStudent();
      if (context.mounted) {
        Navigator.pop(context);
      }
      showToast(
          title: 'Xóa sinh viên khỏi nhóm thành công',
          type: ToastificationType.success);
    } else {
      setLoading(false);
      showToast(
          title: resultRemoveStudent.message ?? '',
          type: ToastificationType.error);
    }
  }
}
