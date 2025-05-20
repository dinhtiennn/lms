import 'package:flutter/material.dart';
import 'package:lms/src/presentation/presentation.dart';

class Routers {
  //Endpoint for student
  static const String welcome = "/welcome";
  static const String login = "/login";
  static const String chooseRole = "/choose-role";
  static const String register = "/register";
  static const String navigation = "/navigation";
  static const String search = "/search";
  static const String course = "/course";
  static const String courseDetail = "/course-detail";
  static const String courseReview = "/course-review";
  static const String editProfile = "/edit-profile";
  static const String support = "/support";
  static const String changePassword = "/changer-password";
  static const String assignmentDetail = "/assignment-detail";
  static const String document = "/document";
  static const String documentDetail = "/document-detail";
  static const String notificationDetail = "/notification-detail";
  static const String newsBoardDetail = "/news-board-detail";
  static const String forgotPassword = "/forgot-password";
  static const String otp = "/otp";
  static const String groupDetail = "/group-detail";
  static const String socketChatBox = "/socket-chat-box";
  static const String allRequestJoinCourseByStudent =
      "/all-request-join-course-by-student";
  static const String testDetail = "/test-detail";
  static const String testResult = "/test-result";
  static const String chatDetail = "/chat-detail";
  static const String chatInfo = "/chat-info";
  static const String paymentWebView = "/payment-webview";

  //Endpoint for teacher
  static const String loginTeacher = "/login-teacher";
  static const String registerTeacher = "/register-teacher";
  static const String navigationTeacher = "/navigation-teacher";
  static const String homeTeacher = "/home-teacher";
  static const String documentTeacher = "/document-teacher";
  static const String documentDetailTeacher = "/document-detail-teacher";
  static const String searchTeacher = "/search-teacher";
  static const String notificationDetailTeacher =
      "/notification-detail-teacher";
  static const String editProfileTeacher = "/edit-profile-teacher";
  static const String changePasswordTeacher = "/change-password-teacher";
  static const String createCourse = "/create-course";
  static const String courseDetailTeacher = "/course-detail-teacher";
  static const String courseFileDetailTeacher = "/course-file-detail-teacher";
  static const String courseMaterialDetailTeacher =
      "/course-material-detail-teacher";
  static const String courseQuizsDetailTeacher = "/course-quizs-detail-teacher";
  static const String groupDetailTeacher = "/group-detail-teacher";
  static const String createTest = "/create-test";
  static const String editTest = "/edit-test";
  static const String testDetailTeacher = "/test-detail-teacher";
  static const String resultTestDetailTeacher = "/result-test-detail-teacher";
  static const String chatBoxDetailTeacher = "/chat-box-detail-teacher";
  static const String chatBoxInfoTeacher = "/chat-box-info-teacher";
  static const String chatBoxMemberTeacher = "/chat-box-member-teacher";
  static const String chatBoxSearchTeacher = "/chat-box-search-teacher";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var arguments = settings.arguments;
    switch (settings.name) {
      case navigation:
        return animRoute(const NavigationScreen(),
            name: navigation, beginOffset: _right, arguments: arguments);
      case welcome:
        return animRoute(const WelcomeScreen(),
            name: welcome, beginOffset: _right, arguments: arguments);
      case chooseRole:
        return animRoute(const ChooseRoleScreen(),
            name: chooseRole, beginOffset: _right, arguments: arguments);
      case login:
        return animRoute(const LoginScreen(),
            name: login, beginOffset: _right, arguments: arguments);
      case register:
        return animRoute(const RegisterScreen(),
            name: register, beginOffset: _right, arguments: arguments);
      case course:
        return animRoute(const CourseScreen(),
            name: course, beginOffset: _right, arguments: arguments);
      case search:
        return animRoute(const SearchScreen(),
            name: search, beginOffset: _right, arguments: arguments);
      case courseReview:
        return animRoute(const CourseReviewScreen(),
            name: courseReview, beginOffset: _right, arguments: arguments);
      case courseDetail:
        return animRoute(const CourseDetailScreen(),
            name: courseDetail, beginOffset: _right, arguments: arguments);
      case editProfile:
        return animRoute(const ProfileScreen(),
            name: editProfile, beginOffset: _right, arguments: arguments);
      case support:
        return animRoute(const SupportScreen(),
            name: support, beginOffset: _right, arguments: arguments);
      case changePassword:
        return animRoute(const ChangePasswordScreen(),
            name: changePassword, beginOffset: _right, arguments: arguments);
      case forgotPassword:
        return animRoute(const ForgotPasswordScreen(),
            name: forgotPassword, beginOffset: _right, arguments: arguments);
      case assignmentDetail:
        return animRoute(const AssignmentDetailScreen(),
            name: assignmentDetail, beginOffset: _right, arguments: arguments);
      case document:
        return animRoute(const DocumentScreen(),
            name: document, beginOffset: _right, arguments: arguments);
      case documentDetail:
        return animRoute(const DocumentDetailScreen(),
            name: documentDetail, beginOffset: _right, arguments: arguments);
      case notificationDetail:
        return animRoute(const NotificationDetailScreen(),
            name: notificationDetail,
            beginOffset: _right,
            arguments: arguments);
      case newsBoardDetail:
        return animRoute(const NewsBoardDetailScreen(),
            name: newsBoardDetail, beginOffset: _right, arguments: arguments);
      case otp:
        return animRoute(const OtpScreen(),
            name: otp, beginOffset: _right, arguments: arguments);
      case groupDetail:
        return animRoute(const GroupDetailScreen(),
            name: groupDetail, beginOffset: _right, arguments: arguments);
      case socketChatBox:
        return animRoute(const SocketChatBoxScreen(),
            name: socketChatBox, beginOffset: _right, arguments: arguments);
      case allRequestJoinCourseByStudent:
        return animRoute(const AllRequestJoinCourseScreen(),
            name: allRequestJoinCourseByStudent,
            beginOffset: _right,
            arguments: arguments);
      case testDetail:
        return animRoute(const TestDetailScreen(),
            name: testDetail, beginOffset: _right, arguments: arguments);
      case testResult:
        return animRoute(const TestResultScreen(),
            name: testResult, beginOffset: _right, arguments: arguments);
      case chatDetail:
        return animRoute(const ChatDetailScreen(),
            name: chatDetail, beginOffset: _right, arguments: arguments);
      case chatInfo:
        return animRoute(const ChatBoxInfoScreen(),
            name: chatInfo, beginOffset: _right, arguments: arguments);
      case paymentWebView:
        return animRoute(const PaymentWebViewScreen(),
            name: paymentWebView, beginOffset: _right, arguments: arguments);

      //case for teacher
      case homeTeacher:
        return animRoute(const HomeTeacherScreen(),
            name: homeTeacher, beginOffset: _right, arguments: arguments);
      case documentTeacher:
        return animRoute(const DocumentTeacherScreen(),
            name: documentTeacher, beginOffset: _right, arguments: arguments);
      case documentDetailTeacher:
        return animRoute(const DocumentDetailTeacherScreen(),
            name: documentDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case searchTeacher:
        return animRoute(const SearchTeacherScreen(),
            name: searchTeacher, beginOffset: _right, arguments: arguments);
      case navigationTeacher:
        return animRoute(const NavigationTeacherScreen(),
            name: navigationTeacher, beginOffset: _right, arguments: arguments);
      case loginTeacher:
        return animRoute(const LoginTeacherScreen(),
            name: loginTeacher, beginOffset: _right, arguments: arguments);
      case registerTeacher:
        return animRoute(const RegisterTeacherScreen(),
            name: registerTeacher, beginOffset: _right, arguments: arguments);
      case notificationDetailTeacher:
        return animRoute(const NotificationDetailTeacherScreen(),
            name: notificationDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case editProfileTeacher:
        return animRoute(const EditProfileTeacherScreen(),
            name: editProfileTeacher,
            beginOffset: _right,
            arguments: arguments);
      case changePasswordTeacher:
        return animRoute(const ChangePasswordTeacherScreen(),
            name: changePasswordTeacher,
            beginOffset: _right,
            arguments: arguments);
      case createCourse:
        return animRoute(const CreateCourseScreen(),
            name: createCourse, beginOffset: _right, arguments: arguments);
      case courseDetailTeacher:
        return animRoute(const CourseDetailTeacherScreen(),
            name: courseDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case courseFileDetailTeacher:
        return animRoute(const CourseFileDetailTeacherScreen(),
            name: courseFileDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case courseMaterialDetailTeacher:
        return animRoute(const CourseMaterialDetailTeacherScreen(),
            name: courseMaterialDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case courseQuizsDetailTeacher:
        return animRoute(const CourseQuizDetailTeacherScreen(),
            name: courseQuizsDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case groupDetailTeacher:
        return animRoute(const GroupDetailTeacherScreen(),
            name: groupDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case createTest:
        return animRoute(const CreateTestScreen(),
            name: createTest, beginOffset: _right, arguments: arguments);
      case editTest:
        return animRoute(const EditTestScreen(),
            name: editTest, beginOffset: _right, arguments: arguments);
      case testDetailTeacher:
        return animRoute(const TestDetailTeacherScreen(),
            name: testDetailTeacher, beginOffset: _right, arguments: arguments);
      case resultTestDetailTeacher:
        return animRoute(const ResultTestDetailTeacherScreen(),
            name: resultTestDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case chatBoxDetailTeacher:
        return animRoute(const ChatBoxTeacherDetailScreen(),
            name: chatBoxDetailTeacher,
            beginOffset: _right,
            arguments: arguments);
      case chatBoxInfoTeacher:
        return animRoute(const ChatBoxInfoTeacherScreen(),
            name: chatBoxInfoTeacher,
            beginOffset: _right,
            arguments: arguments);
      case chatBoxMemberTeacher:
        return animRoute(const ChatBoxMemberTeacherScreen(),
            name: chatBoxMemberTeacher,
            beginOffset: _right,
            arguments: arguments);
      case chatBoxSearchTeacher:
        return animRoute(const ChatBoxSearchTeacherScreen(),
            name: chatBoxSearchTeacher,
            beginOffset: _right,
            arguments: arguments);
      //case default
      default:
        return animRoute(
            Center(child: Text('No route defined for ${settings.name}')),
            name: "/error");
    }
  }

  static Route animRoute(Widget page,
      {Offset? beginOffset, required String name, Object? arguments}) {
    return PageRouteBuilder(
      settings: RouteSettings(name: name, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = beginOffset ?? const Offset(0.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static const Offset _center = Offset(0.0, 0.0);
  static const Offset _top = Offset(0.0, 1.0);
  static const Offset _bottom = Offset(0.0, -1.0);
  static const Offset _left = Offset(-1.0, 0.0);
  static const Offset _right = Offset(1.0, 0.0);
}
