import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class GroupDetailTeacherViewModel extends BaseViewModel with StompListener {
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
  ValueNotifier<PostModel?> postSelected = ValueNotifier(null);
  late StompService stompService;
  ValueNotifier<CommentModel?> commentSelected = ValueNotifier(null);
  ValueNotifier<List<CommentModel>?> comments = ValueNotifier(null);

  // Controller cho chức năng chỉnh sửa bài kiểm tra
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController expiredAtDateController = TextEditingController();
  TextEditingController expiredAtTimeController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  ValueNotifier<String?> animatedCommentId = ValueNotifier(null);
  ValueNotifier<String?> animatedReplyId = ValueNotifier(null);

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

  bool _isSocketConnected = false;

  bool hasMoreComments = true;
  bool isLoadingComments = false;
  int commentPageSize = 10;

  init() async {
    teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    group.value = Get.arguments['group'];

    refreshPost();
    refreshTest();
    refreshStudent();

    postScrollController.addListener(_onScrollPost);
    testScrollController.addListener(_onScrollTest);
    studentScrollController.addListener(_onScrollStudent);

    setupSocket();
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

      logger.i("Bắt đầu đăng ký các listener cho socket");

      try {
        stompService.registerListener(type: StompListenType.commentPost, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.comment");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.comment: $e");
      }

      try {
        stompService.registerListener(type: StompListenType.editCommentPost, listener: this);
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
        postScrollController.position.pixels >= postScrollController.position.maxScrollExtent - 300) {
      _loadPost();
    }
  }

  void _onScrollTest() {
    if (!isLoadingTest &&
        hasMoreTest &&
        testScrollController.position.pixels >= testScrollController.position.maxScrollExtent - 300) {
      _loadTest();
    }
  }

  void _onScrollStudent() {
    if (!isLoadingStudent &&
        hasMoreStudent &&
        studentScrollController.position.pixels >= studentScrollController.position.maxScrollExtent - 300) {
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
        groupId: group.value?.id ?? '', text: descriptionPost.text, filesPicker: filesPicker.value);
    //todo lỗi server nên tạm thời không kiểm tra điều kiện
    if (resultPost.isSuccess && resultPost.result != null) {
      filesPicker.value = [];
      descriptionPost.text = '';
      pageNumberPost = 0;
      hasMorePost = true;
      posts.value = [];
      await _loadPost();
      showToast(title: 'Thêm bài đăng thành công!', type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: 'Lỗi ${resultPost.message}', type: ToastificationType.error);
    }
  }

  void updatePost(
      String postId, String description, List<FileElement> keptOldFiles, List<File> newlyPickedFiles) async {
    if (group.value?.id == null) {
      showToast(title: 'Lỗi: Không tìm thấy thông tin nhóm.', type: ToastificationType.error);
      return;
    }
    if (postId.isEmpty) {
      showToast(title: 'Lỗi: Không tìm thấy thông tin bài đăng.', type: ToastificationType.error);
      return;
    }

    NetworkState<PostModel> resultPost = await groupRepository.updatePost(
      groupId: group.value!.id,
      text: description,
      newFilesPicker: newlyPickedFiles,
      postId: postId,
      removeFilesIds: keptOldFiles.map((e) => e.id!).where((id) => id.isNotEmpty).toList(),
    );

    if (resultPost.isSuccess && resultPost.result != null) {
      descriptionPost.text = '';
      pageNumberPost = 0;
      hasMorePost = true;
      posts.value = [];
      await _loadPost();
      showToast(title: 'Cập nhật bài đăng thành công!', type: ToastificationType.success);

      filesPicker.value = [];

      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: 'Lỗi cập nhật bài đăng: ${resultPost.message}', type: ToastificationType.error);
    }
  }

  Future<void> _loadPost() async {
    if (isLoadingPost || !hasMorePost) return;

    isLoadingPost = true;

    try {
      NetworkState<List<PostModel>> resultPosts = await groupRepository.getPosts(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberPost);

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
      NetworkState<List<TestModel>> resultTests = await groupRepository.getTests(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberTest);

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
      NetworkState<List<StudentModel>> resultStudents = await groupRepository.getStudents(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberStudent);

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
      showToast(title: 'Lỗi ${resultPosts.message}', type: ToastificationType.error);
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
    selectedStudents.value = selectedStudents.value.where((s) => s.id != student.id).toList();
    selectedStudents.notifyListeners();
  }

  Future<void> searchStudentNotInGroup({String? keyword}) async {
    if (keyword == null || keyword.isEmpty) {
      studentsSearch.value = null;
      studentsSearch.notifyListeners();
      return;
    }

    NetworkState<List<StudentModel>> resultSearchStudent =
        await studentRepository.searchStudentNotInGroup(groupId: group.value?.id ?? '', keyword: keyword);
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

  void addAllStudentToGroup(BuildContext context, List<StudentModel> students) async {
    NetworkState resultAddStudents =
        await groupRepository.addStudents(groupId: group.value?.id ?? '', students: students);
    if (resultAddStudents.isSuccess) {
      await refreshStudent();
      showToast(title: 'Thêm sinh viên vào nhóm thành công', type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: resultAddStudents.message ?? '', type: ToastificationType.error);
    }
  }

  void removeStudent({String? studentId, required BuildContext context}) async {
    setLoading(true);
    NetworkState resultRemoveStudent =
        await groupRepository.removeStudent(groupId: group.value?.id, studentId: studentId);
    if (resultRemoveStudent.isSuccess) {
      setLoading(false);
      await refreshStudent();
      if (context.mounted) {
        Navigator.pop(context);
      }
      showToast(title: 'Xóa sinh viên khỏi nhóm thành công', type: ToastificationType.success);
    } else {
      setLoading(false);
      showToast(title: resultRemoveStudent.message ?? '', type: ToastificationType.error);
    }
  }

  // todo các hàm liên quan tới comment
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

    if (postSelected.value == null) {
      logger.e("Không có nội dung hiện tại, hủy gửi tin nhắn");
      return;
    }

    if (comment == null) {
      logger.i('Đang gửi comment mới');
      logger.i('Student info: ${teacher}');
      try {
        final payload = {
          'postId': postSelected.value?.id,
          // 'courseId': courseDetail.value?.id ?? '',
          'username': teacher?.email ?? '',
          'detail': commentController.text,
          'createDateD': DateTime.now().toString(),
        };

        logger.i('Gửi tin nhắn đến /app/post-comment: ${jsonEncode(payload)}');
        stompService.send(
          StompListenType.commentPost,
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
          'replyUsername': teacher?.email,
          'ownerUsername': commentSelected.value?.username,
          'postId': postSelected.value?.id,
          // 'courseId': courseDetail.value?.id ?? '',
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
    if (postSelected.value == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editCommentPost,
        jsonEncode({
          'commentId': commentId,
          'usernameOwner': teacher?.email ?? '',
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
    if (postSelected.value == null) {
      return;
    }

    try {
      stompService.send(
        StompListenType.editReply,
        jsonEncode({
          'commentReplyId': replyId,
          'usernameReply': teacher?.email ?? '',
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
      final String? postId = postSelected.value?.id;

      if (postId == null) {
        logger.e("Không thể tải comments: courseId hoặc chapterId không tồn tại");
        isLoadingComments = false;
        notifyListeners();
        return;
      }

      // Sử dụng pageSize từ tham số nếu có, ngược lại dùng giá trị mặc định
      final int effectivePageSize = pageSize ?? commentPageSize;

      // Tính toán pageNumber dựa trên kích thước hiện tại của danh sách comments
      final int pageNumber = (comments.value?.length ?? 0);

      logger.i("Tải comments cho chapter: $postId, pageNumber: $pageNumber, pageSize: $effectivePageSize");

      final NetworkState<List<CommentModel>> result = await commentRepository.commentInPost(
        postId: postId,
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
  void onStompCommentPostReceived(dynamic body) {
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
        // Chỉ cập nhật số lượng phản hồi (countOfReply) mà không thêm reply vào danh sách
        // Điều này cho phép hiển thị nút "Xem thêm x phản hồi" với số lượng đúng
        // nhưng không tự động hiển thị reply mới
        final CommentModel updatedParentComment = parentComment.copyWith(
          countOfReply: newReply.replyCount,
          // Giữ nguyên danh sách replies hiện tại
          commentReplyResponses: existingReplies,
        );

        // Cập nhật comment trong danh sách
        currentComments[commentIndex] = updatedParentComment;
        comments.value = currentComments;
        comments.notifyListeners();

        logger.i("Đã cập nhật số lượng phản hồi cho comment $parentCommentId: ${newReply.replyCount}");
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

  void setPost(PostModel chapter) {
    postSelected.value = chapter;
  }
}
