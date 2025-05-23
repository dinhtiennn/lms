import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class PostCommentTeacher extends StatefulWidget {
  final ValueNotifier<List<CommentModel>?> comments;
  final ValueNotifier<CommentModel?> commentSelected;
  final TextEditingController commentController;
  final Function({CommentModel? comment}) onSendComment;
  final Function({CommentModel? comment}) setCommentSelected;
  final Function({required PostModel post, int pageSize, int pageNumber})
      onLoadMoreComments;
  final Function({required String commentId}) onLoadMoreReplies;
  final Function({required String commentId, required String detail})
      onEditComment;
  final Function(
      {required String replyId,
      required String parentCommentId,
      required String detail}) onEditReply;
  final ValueNotifier<String?> animatedCommentId;
  final ValueNotifier<String?> animatedReplyId;
  final String? avatarUrl;
  final PostModel? currentPost;
  final Function() onDispose;
  final String? userEmail;

  PostCommentTeacher({
    Key? key,
    required this.comments,
    required this.commentSelected,
    required this.commentController,
    required this.onSendComment,
    required this.animatedCommentId,
    required this.animatedReplyId,
    required this.setCommentSelected,
    required this.onLoadMoreComments,
    required this.onLoadMoreReplies,
    required this.onEditComment,
    required this.onEditReply,
    required this.onDispose,
    required this.userEmail,
    this.currentPost,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<PostCommentTeacher> createState() => _PostCommentTeacherState();
}

class _PostCommentTeacherState extends State<PostCommentTeacher> {
  // Theo dõi danh sách các comment đã được mở rộng
  final ValueNotifier<Set<String>> _expandedComments =
      ValueNotifier<Set<String>>({});

  // Thêm map để theo dõi page number của từng comment
  final Map<String, int> _replyPageNumbers = {};

  // Thêm map để theo dõi trạng thái loading của từng comment
  final Map<String, bool> _loadingReplies = {};

  String? _editingCommentId;
  String? _editingReplyId;
  String? _editingParentCommentId;
  final TextEditingController _editingController = TextEditingController();
  bool _isEditing = false;

  final Logger logger = Logger();

  // Thêm ScrollController để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();

  // Số trang hiện tại và trạng thái tải
  int _currentPage = 0;
  bool _isLoading = false;

  // Lưu vị trí scroll
  double? _lastScrollPosition;

  @override
  void initState() {
    super.initState();
    //update ui khi input thay đổi
    widget.commentController.addListener(_onTextChanged);

    // Thêm listener cho commentSelected để rebuild UI khi chọn comment để phản hồi
    widget.commentSelected.addListener(_onCommentSelectedChanged);

    // Thêm listener cho comments để rebuild khi có comment/reply thay đổi
    widget.comments.addListener(_onCommentsChanged);

    // Thêm listener cho animatedCommentId và animatedReplyId
    // để phát hiện khi có comment/reply mới được thêm vào
    widget.animatedCommentId.addListener(_onNewCommentDetected);
    widget.animatedReplyId.addListener(_onNewReplyDetected);

    // Thêm listener cho ScrollController để phát hiện khi cuộn tới gần cuối danh sách
    _scrollController.addListener(_scrollListener);

    // Theo dõi sự thay đổi của danh sách comments để duy trì vị trí cuộn
    widget.comments.addListener(_maintainScrollPosition);

    // Load comments khi bottom sheet được hiển thị
    if (widget.currentPost != null) {
      _loadInitialComments();
    }
  }

  void _loadInitialComments() {
    _currentPage = 0;
    _isLoading = false;
    widget.onLoadMoreComments(
        post: widget.currentPost!, pageSize: 20, pageNumber: 0);
  }

  // Thêm hàm mới để xử lý khi danh sách comments thay đổi
  void _onCommentsChanged() {
    if (!mounted) return;

    // Đảm bảo UI được rebuild khi có comment mới
    setState(() {
      // Force rebuild UI khi comments thay đổi
    });

    // Hoặc có thể sử dụng postFrameCallback để đảm bảo
    // UI được cập nhật sau khi frame hiện tại hoàn thành
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Confirm rebuild was triggered
          logger.i("Rebuilding UI after comments changed");
        });
      }
    });
  }

  // Thêm hàm listener mới cho commentSelected
  void _onCommentSelectedChanged() {
    if (mounted) {
      setState(() {
        // Khi commentSelected thay đổi, gọi setState để rebuild UI
      });
    }
  }

  // Hàm duy trì vị trí cuộn khi danh sách comments thay đổi
  void _maintainScrollPosition() {
    // Make sure we're still mounted before using the ValueNotifier
    if (!mounted) return;

    if (_lastScrollPosition != null && _scrollController.hasClients) {
      // Lưu giá trị _lastScrollPosition vào biến cục bộ để tránh giá trị null
      final double savedPosition = _lastScrollPosition!;
      _lastScrollPosition =
          null; // Xóa giá trị ngay lập tức để tránh sử dụng lại

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          // Đảm bảo rằng vị trí scroll không vượt quá kích thước mới của danh sách
          final double maxScrollExtent =
              _scrollController.position.maxScrollExtent;
          final double scrollTo =
              savedPosition < maxScrollExtent ? savedPosition : maxScrollExtent;

          _scrollController.jumpTo(scrollTo);
        }
      });
    }
  }

  // Hàm theo dõi cuộn
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Lưu vị trí scroll hiện tại trước khi load thêm dữ liệu
      _lastScrollPosition = _scrollController.position.pixels;
      _loadMoreComments();
    }
  }

  // Hàm tải thêm comment
  void _loadMoreComments() {
    if (!mounted || !_scrollController.hasClients) return;

    if (!_isLoading && widget.currentPost != null) {
      setState(() {
        _isLoading = true;
      });

      // Lấy kích thước comments hiện tại từ ViewModel
      final commentsLength = widget.comments.value?.length ?? 0;

      logger.i("Tải thêm comments, pageNumber: $commentsLength");

      widget.onLoadMoreComments(
          post: widget.currentPost!, pageSize: 20, pageNumber: commentsLength);

      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // Hàm tải thêm replies và hiển thị đúng các replies đã load
  void _loadMoreReplies(String commentId,
      {int currentReplies = 0, int totalReplies = 0}) {
    if (!mounted) return;
    if (_loadingReplies[commentId] == true) return;

    setState(() {
      _loadingReplies[commentId] = true;
    });

    try {
      widget.onLoadMoreReplies(
        commentId: commentId,
      );

      // Thiết lập cờ đánh dấu đã mở rộng comment này
      final currentExpanded = Set<String>.from(_expandedComments.value);
      if (!currentExpanded.contains(commentId)) {
        currentExpanded.add(commentId);
        _expandedComments.value = currentExpanded;
      }
    } catch (e) {
      logger.e("Error loading more replies: $e");
      if (mounted) {
        setState(() {
          _loadingReplies[commentId] = false;
        });
      }
    }

    // Reset loading state sau 1 giây
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _loadingReplies[commentId] = false;
        });
      }
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _startEditComment(CommentModel comment) {
    setState(() {
      _isEditing = true;
      _editingCommentId = comment.commentId;
      _editingReplyId = null;
      _editingParentCommentId = null;
      _editingController.text = comment.detail ?? '';
    });

    _showEditingBottomSheet(
      title: 'Chỉnh sửa bình luận',
      initialText: comment.detail ?? '',
      onSave: (newText) {
        if (_editingCommentId != null && newText.isNotEmpty) {
          widget.onEditComment(
            commentId: _editingCommentId!,
            detail: newText,
          );
        }
        _cancelEditing();
      },
    );
  }

  // Chỉnh sửa reply
  void _startEditReply(ReplyModel reply, String parentCommentId) {
    setState(() {
      _isEditing = true;
      _editingCommentId = null;
      _editingReplyId = reply.commentReplyId;
      _editingParentCommentId = parentCommentId;
      _editingController.text = reply.detail ?? '';
    });

    _showEditingBottomSheet(
      title: 'Chỉnh sửa phản hồi',
      initialText: reply.detail ?? '',
      onSave: (newText) {
        if (_editingReplyId != null &&
            _editingParentCommentId != null &&
            newText.isNotEmpty) {
          widget.onEditReply(
            replyId: _editingReplyId!,
            parentCommentId: _editingParentCommentId!,
            detail: newText,
          );
        }
        _cancelEditing();
      },
    );
  }

  // Hủy chỉnh sửa
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingCommentId = null;
      _editingReplyId = null;
      _editingParentCommentId = null;
      _editingController.clear();
    });
  }

  void _showEditingBottomSheet({
    required String title,
    required String initialText,
    required Function(String) onSave,
  }) {
    _editingController.text = initialText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: styleMediumBold.copyWith(color: primary),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _editingController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập nội dung',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: grey4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelEditing();
                      },
                      child: Text(
                        'Hủy',
                        style: styleSmall.copyWith(color: grey3),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onSave(_editingController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Lưu',
                        style: styleSmall.copyWith(color: white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canEdit(String? commentUsername) {
    String currentUserEmail = widget.userEmail ?? '';
    return commentUsername == currentUserEmail;
  }

  // Hàm để ẩn/thu gọn phản hồi
  void _hideReplies(String commentId) {
    if (!mounted) return;

    if (widget.comments.value != null) {
      final currentComments = List<CommentModel>.from(widget.comments.value!);
      for (var i = 0; i < currentComments.length; i++) {
        if (currentComments[i].commentId == commentId) {
          // Tạo bản sao của comment hiện tại trước khi thay đổi
          CommentModel updatedComment = currentComments[i].copyWith(
            commentReplyResponses: [],
          );

          // Cập nhật lại comment trong danh sách
          currentComments[i] = updatedComment;

          // Reset trạng thái loading và tracking cho comment này
          _loadingReplies[commentId] = false;
          _replyPageNumbers[commentId] = 0; // Reset pageNumber về 0

          setState(() {});
          break;
        }
      }

      if (mounted) {
        widget.comments.value = currentComments;
        try {
          widget.comments.notifyListeners();
        } catch (e) {
          logger.e("Error notifying comments listeners: $e");
        }
      }

      // Hiển thị thông báo nhỏ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ẩn các phản hồi'),
            duration: Duration(milliseconds: 800),
            backgroundColor: primary.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Theo dõi khi có comment mới được thêm
  void _onNewCommentDetected() {
    if (widget.animatedCommentId.value != null) {
      logger.i("Phát hiện comment mới: ${widget.animatedCommentId.value}");
      setState(() {
        // Rebuild UI
      });
    }
  }

  // Theo dõi khi có reply mới được thêm
  void _onNewReplyDetected() {
    if (widget.animatedReplyId.value != null && widget.comments.value != null) {
      final replyId = widget.animatedReplyId.value;
      logger.i("Phát hiện reply mới: $replyId");

      // Khi có reply mới, chúng ta sẽ không tự động hiển thị reply đó
      // mà chỉ cập nhật UI để hiển thị số lượng reply đã thay đổi
      // và để người dùng chủ động nhấn vào nút "Xem thêm x phản hồi"
      setState(() {
        // Rebuild UI để cập nhật số lượng phản hồi được hiển thị
        logger.i("Rebuild UI để cập nhật số lượng phản hồi");
      });

      // Thông báo nhỏ để người dùng biết có phản hồi mới
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có phản hồi mới'),
          duration: Duration(seconds: 1),
          backgroundColor: primary.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Xem',
            textColor: Colors.white,
            onPressed: () {
              // Không cần làm gì vì UI đã được cập nhật với nút "Xem x phản hồi"
            },
          ),
        ),
      );
    }
  }

  // Override original methods with new implementations
  @override
  void dispose() {
    widget.commentController.removeListener(_onTextChanged);
    widget.animatedCommentId.removeListener(_onNewCommentDetected);
    widget.animatedReplyId.removeListener(_onNewReplyDetected);
    widget.commentSelected.removeListener(_onCommentSelectedChanged);
    widget.comments.removeListener(_maintainScrollPosition);
    widget.comments.removeListener(_onCommentsChanged);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _expandedComments.dispose();
    _editingController.dispose();

    // Call onDispose callback to reset comment loading state
    widget.onDispose();

    logger.i("PostCommentTeacher đã dispose");
    super.dispose();
  }

  void _onAnimatedCommentIdChanged() {
    // Chỉ xử lý animation khi có ID mới
    if (widget.animatedCommentId.value != null) {
      logger.i("Animation cho comment mới: ${widget.animatedCommentId.value}");
      setState(() {
        // Rebuild UI để hiển thị animation
      });

      // Xóa animation ID sau khi animation hoàn thành
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          widget.animatedCommentId.value = null;
        }
      });
    }
  }

  void _onAnimatedReplyIdChanged() {
    // Chỉ xử lý animation khi có ID mới
    if (widget.animatedReplyId.value != null) {
      logger.i("Animation cho reply mới: ${widget.animatedReplyId.value}");

      // Gỡ bỏ việc tự động cập nhật danh sách reply
      // Để các API và socket server xử lý

      setState(() {
        // Rebuild UI để hiển thị animation
      });

      // Xóa animation ID sau khi animation hoàn thành
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          widget.animatedReplyId.value = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin về padding của bàn phím
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardPadding),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.05).round()),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (!mounted) return Container();
                    final commentsList = widget.comments.value;
                    if (commentsList == null) {
                      return Column(
                        children: [
                          _buildCommentHeader(context, 0),
                          Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primary),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (commentsList.isEmpty) {
                      return Column(
                        children: [
                          _buildCommentHeader(context, 0),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Chưa có bình luận nào',
                                style: styleSmall.copyWith(color: grey3),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildCommentHeader(context, commentsList.length),
                        Flexible(
                          child: _buildCommentsSection(commentsList),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Sử dụng ValueListenableBuilder cho phần hiển thị "Đang trả lời"
              ValueListenableBuilder<CommentModel?>(
                valueListenable: widget.commentSelected,
                builder: (context, replying, _) {
                  if (replying != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: primary.withAlpha((255 * 0.05).round()),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Đang trả lời ${replying.fullname}',
                              style: styleSmall.copyWith(color: primary),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              widget.setCommentSelected();
                            },
                            child: Icon(Icons.close, size: 16, color: grey3),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context, int commentsCount) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bình luận',
                style: styleLargeBold.copyWith(
                  color: primary,
                  fontSize: 20,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.05).round()),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey.shade200,
          margin: EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(List<CommentModel> comments) {
    return ListView.builder(
      key: PageStorageKey<String>('comments_list'),
      controller: _scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      itemCount: comments.length + (_isLoading ? 1 : 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Hiển thị loading indicator ở cuối danh sách
        if (index == comments.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ),
          );
        }

        final comment = comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    if (!mounted) return Container();

    final replyCount = comment.countOfReply ?? 0;
    final hasReplies = replyCount > 0;
    final isLoading = _loadingReplies[comment.commentId] ?? false;
    final currentReplies = comment.commentReplyResponses?.length ?? 0;
    final remainingReplies = replyCount - currentReplies;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: primary.withAlpha((255 * 0.1).round()), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.05).round()),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
            child: WidgetImageNetwork(
              url: comment.avatar,
              width: 36,
              height: 36,
              radiusAll: 100,
              widgetError: Center(
                child: Text(
                  (comment.fullname?.isNotEmpty ?? false)
                      ? comment.fullname![0].toUpperCase()
                      : "?",
                  style: styleMediumBold.copyWith(color: primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment chính
                GestureDetector(
                  onLongPress: () {
                    _showCommentOptionsBottomSheet(comment);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: grey5.withAlpha((255 * 0.5).round()),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.05).round()),
                          blurRadius: 3,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(
                                  comment.fullname ?? '',
                                  style: styleSmallBold.copyWith(
                                    color:
                                    primary.withAlpha((255 * 0.8).round()),
                                    fontSize: 13,
                                  ),
                                ),),
                                if (comment.lastUpdate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '(đã chỉnh sửa)',
                                      style: styleVerySmall.copyWith(
                                        color: grey3,
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              AppUtils.getTimeAgo(comment.createdDate),
                              style: styleVerySmall.copyWith(
                                color: grey3,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment.detail ?? '',
                          style: styleSmall.copyWith(
                            color: grey2,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nút xem phản hồi (chỉ hiển thị khi có replies nhưng chưa load hoặc đã ẩn)
                    if (hasReplies && currentReplies == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TextButton.icon(
                          onPressed: () => _loadMoreReplies(
                            comment.commentId ?? '',
                            currentReplies: currentReplies,
                            totalReplies: replyCount,
                          ),
                          icon: Icon(
                            Icons.visibility_outlined,
                            size: 15,
                            color: primary.withAlpha((255 * 0.7).round()),
                          ),
                          label: Text(
                            "Xem $replyCount phản hồi",
                            style: styleVerySmall.copyWith(
                              color: primary.withAlpha((255 * 0.7).round()),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                  ],
                ),

                // Danh sách phản hồi (nếu có và đã load)
                if (hasReplies && currentReplies > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: primary.withAlpha((255 * 0.1).round()),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...comment.commentReplyResponses!.map((reply) {
                          return _buildReplyItem(
                              reply: reply, comment: comment);
                        }).toList(),

                        // Hiển thị loading indicator nếu đang tải
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(primary),
                                ),
                              ),
                            ),
                          ),

                        // Hiển thị nút xem thêm phản hồi nếu còn replies chưa load
                        if (remainingReplies > 0)
                          TextButton.icon(
                            onPressed: () => _loadMoreReplies(
                              comment.commentId ?? '',
                              currentReplies: currentReplies,
                              totalReplies: replyCount,
                            ),
                            icon: Icon(
                              Icons.expand_more,
                              size: 14,
                              color: primary.withAlpha((255 * 0.7).round()),
                            ),
                            label: Text(
                              "Xem thêm $remainingReplies phản hồi",
                              style: styleVerySmall.copyWith(
                                color: primary.withAlpha((255 * 0.7).round()),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),

                        // Thêm nút ẩn phản hồi
                        TextButton(
                          onPressed: () =>
                              _hideReplies(comment.commentId ?? ''),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_off_outlined,
                                size: 14,
                                color: grey3,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Ẩn phản hồi",
                                style: styleVerySmall.copyWith(
                                  color: grey3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(
      {required ReplyModel reply, required CommentModel comment}) {
    if (!mounted) return Container();

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: primary.withAlpha((255 * 0.1).round()), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.03).round()),
                  blurRadius: 3,
                  spreadRadius: 0,
                )
              ],
            ),
            child: WidgetImageNetwork(
              url: reply.avatarReply,
              width: 36,
              height: 36,
              radiusAll: 100,
              widgetError: Center(
                child: Text(
                  (reply.fullnameReply?.isNotEmpty ?? false)
                      ? reply.fullnameReply![0].toUpperCase()
                      : "?",
                  style: styleMediumBold.copyWith(color: primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nội dung phản hồi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () {
                    _showReplyOptionsBottomSheet(reply, comment);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: grey5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.02).round()),
                          blurRadius: 2,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(
                              reply.fullnameReply ?? '',
                              style: styleSmallBold.copyWith(
                                color: primary.withAlpha((255 * 0.8).round()),
                                fontSize: 13,
                              ),
                            ),),
                            if (reply.lastUpdate != null)
                              Text(
                                '(đã chỉnh sửa)',
                                style: styleVerySmall.copyWith(
                                  color: grey3,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          AppUtils.getTimeAgo(
                              reply.lastUpdate ?? reply.createdDate),
                          style: styleVerySmall.copyWith(
                            color: grey3,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            text: '@${reply.fullnameOwner}',
                            style: styleSmallBold.copyWith(
                              color: primary.withAlpha((255 * 0.8).round()),
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                  text: ' ${reply.detail}',
                                  style: styleVerySmallBold.copyWith(
                                      color: grey3,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentOptionsBottomSheet(CommentModel comment) {
    final bool canEditThisComment = _canEdit(comment.username);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20)
              .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Trả lời
              ListTile(
                leading: Icon(Icons.reply_outlined, color: primary),
                title: Text(
                  'Trả lời',
                  style: styleMedium.copyWith(color: grey2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.setCommentSelected(comment: comment);
                },
              ),

              // Chỉnh sửa bình luận (chỉ hiển thị nếu người dùng là chủ bình luận)
              if (canEditThisComment)
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: primary),
                  title: Text(
                    'Chỉnh sửa bình luận',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startEditComment(comment);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showReplyOptionsBottomSheet(ReplyModel reply, CommentModel comment) {
    final bool canEditThisReply = _canEdit(reply.usernameReply);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Trả lời
              ListTile(
                leading: Icon(Icons.reply_outlined, color: primary),
                title: Text(
                  'Trả lời',
                  style: styleMedium.copyWith(color: grey2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.setCommentSelected(
                      comment: CommentModel(
                          username: reply.usernameReply,
                          fullname: reply.fullnameReply,
                          commentId: comment.commentId));
                },
              ),

              // Chỉnh sửa phản hồi (chỉ hiển thị nếu người dùng là chủ bình luận)
              if (canEditThisReply)
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: primary),
                  title: Text(
                    'Chỉnh sửa phản hồi',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startEditReply(reply, comment.commentId ?? '');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).round()),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: WidgetInput(
              controller: widget.commentController,
              hintText: "Thêm bình luận...",
              hintStyle: styleSmall.copyWith(color: grey4),
              borderColor: grey5,
              style: styleSmall.copyWith(color: grey2),
              suffix: (widget.commentController.text.isNotEmpty)
                  ? IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: primary2,
                        size: 22,
                      ),
                      onPressed: () {
                        if (widget.commentSelected.value != null) {
                          widget.onSendComment(
                              comment: widget.commentSelected.value);
                        } else {
                          widget.onSendComment();
                        }
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : SizedBox(),
              maxLines: 3,
              minLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Cập nhật phương thức để xử lý việc cập nhật số lượng reply
  void _updateReplyCount(String commentId, int newReplyCount) {
    if (!mounted || widget.comments.value == null) return;

    final commentsList = List<CommentModel>.from(widget.comments.value!);
    for (int i = 0; i < commentsList.length; i++) {
      if (commentsList[i].commentId == commentId) {
        // Cập nhật countOfReply và giữ lại các thuộc tính khác
        CommentModel updatedComment =
            commentsList[i].copyWith(countOfReply: newReplyCount);

        commentsList[i] = updatedComment;

        widget.comments.value = commentsList;
        // Thông báo listeners để cập nhật UI
        try {
          widget.comments.notifyListeners();
        } catch (e) {
          logger.e("Error notifying listeners on reply count update: $e");
        }

        setState(() {
          // Đảm bảo UI được cập nhật
        });

        break;
      }
    }
  }
}
