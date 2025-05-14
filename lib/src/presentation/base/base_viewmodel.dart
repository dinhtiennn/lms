import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/repo/comment_repository.dart';
import 'package:lms/src/resource/repo/course_repository.dart';
import 'package:lms/src/resource/repo/group_repository.dart';
import 'package:lms/src/resource/repo/major_repository.dart';
import 'package:lms/src/resource/repo/teacher_repository.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';

abstract class BaseViewModel extends ChangeNotifier {
  BuildContext? _context;

  BuildContext get context => _context!;

  setContext(BuildContext value) {
    _context = value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseDetailViewModel;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  final AuthRepository authRepository = AuthRepository();
  final OtherRepository otherRepository = OtherRepository();
  final FirebaseRepository firebaseRepository = FirebaseRepository();
  final ChatAiService chatAiService = ChatAiService();
  final StudentRepository studentRepository = StudentRepository();
  final TeacherRepository teacherRepository = TeacherRepository();
  final CourseRepository courseRepository = CourseRepository();
  final CommentRepository commentRepository = CommentRepository();
  final MajorRepository majorRepository = MajorRepository();
  final GroupRepository groupRepository = GroupRepository();

  Logger logger = Logger();

  void unFocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> setLoading(bool loading) async {
    if (loading) {
      Get.dialog(const Center(child: MyLoading()), barrierDismissible: false);
    } else {
      if (Get.isDialogOpen != null && Get.isDialogOpen!) {
        Get.back();
      }
    }
  }

  Future<void> showToast({
    String title = 'Default title',
    ToastificationType type = ToastificationType.success,
    BuildContext? context,
  }) async {
    toastification.show(
      context: context ?? this.context,
      type: type,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      showIcon: true,
      applyBlurEffect: true,
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    );
  }
}
