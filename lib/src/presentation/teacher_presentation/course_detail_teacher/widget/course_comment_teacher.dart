import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:logger/logger.dart';

class CourseCommentTeacher extends StatefulWidget {
  final ValueNotifier<List<CommentModel>?> comments;
  final ValueNotifier<CommentModel?> commentSelected;
  final TextEditingController commentController;
  final Function({CommentModel? comment}) onSendComment;
  final Function({CommentModel? comment}) setCommentSelected;
  final Function({required ChapterModel chapter, int pageSize, int pageNumber})
      onLoadMoreComments;
  final ValueNotifier<String?> animatedCommentId;
  final ValueNotifier<String?> animatedReplyId;
  final String? avatarUrl;
  final ChapterModel? currentChapter;

  CourseCommentTeacher({
    Key? key,
    required this.comments,
    required this.commentSelected,
    required this.commentController,
    required this.onSendComment,
    required this.animatedCommentId,
    required this.animatedReplyId,
    required this.setCommentSelected,
    required this.onLoadMoreComments,
    this.currentChapter,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<CourseCommentTeacher> createState() => _CourseCommentTeacherState();
}

class _CourseCommentTeacherState extends State<CourseCommentTeacher> {
  // Theo dõi danh sách các comment đã được mở rộng
  final ValueNotifier<Set<String>> _expandedComments =
      ValueNotifier<Set<String>>({});

  final Logger logger = Logger();

  // Thêm ScrollController để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();

  // Số trang hiện tại và trạng thái tải
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //update ui khi input thay đổi
    widget.commentController.addListener(_onTextChanged);

    // Đăng ký riêng biệt listener cho comments và animatedCommentId
    widget.animatedCommentId.addListener(_onAnimatedCommentIdChanged);

    // Đăng ký riêng biệt listener cho animatedReplyId
    widget.animatedReplyId.addListener(_onAnimatedReplyIdChanged);

    // Thêm listener cho ScrollController để phát hiện khi cuộn tới gần cuối danh sách
    _scrollController.addListener(_scrollListener);

    // Đặt lại _currentPage mỗi khi widget được tạo mới
    _currentPage = 0;
  }

  void _onAnimatedCommentIdChanged() {
    logger.e("animatedCommentId thay đổi: ${widget.animatedCommentId.value}");

    // Chỉ xử lý animation khi có ID mới
    if (widget.animatedCommentId.value != null) {
      // Đảm bảo UI được cập nhật
      setState(() {});

      // Xóa animation sau khi animation hoàn thành
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          // Xóa ID animation
          widget.animatedCommentId.value = null;
          logger.e('Xóa animation cho comment: null');
        }
      });
    }
  }

  // Hàm xử lý riêng cho animatedReplyId
  void _onAnimatedReplyIdChanged() {
    logger.e("animatedReplyId thay đổi: ${widget.animatedReplyId.value}");

    // Chỉ xử lý animation khi có ID mới
    if (widget.animatedReplyId.value != null) {
      // Đảm bảo UI được cập nhật
      setState(() {});

      // Xóa animation sau khi animation hoàn thành
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          // Xóa ID animation
          widget.animatedReplyId.value = null;
          logger.e('Xóa animation cho reply: null');
        }
      });
    }
  }

  @override
  void dispose() {
    widget.commentController.removeListener(_onTextChanged);
    widget.animatedCommentId.removeListener(_onAnimatedCommentIdChanged);
    widget.animatedReplyId.removeListener(_onAnimatedReplyIdChanged);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _expandedComments.dispose();
    logger.i("CourseComment đã dispose");
    super.dispose();
  }

  // Hàm theo dõi cuộn
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreComments();
    }
  }

  // Hàm tải thêm comment
  void _loadMoreComments() {
    if (!_isLoading && widget.currentChapter != null) {
      setState(() {
        _isLoading = true;
      });

      _currentPage++;
      logger.i("Tải thêm comments trang $_currentPage");

      widget.onLoadMoreComments(
          chapter: widget.currentChapter!,
          pageSize: 20,
          pageNumber: _currentPage);

      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  // Method expanded khi ấn xem thêm comment
  void _toggleExpanded(String commentId) {
    final currentExpanded = Set<String>.from(_expandedComments.value);
    if (currentExpanded.contains(commentId)) {
      currentExpanded.remove(commentId);
    } else {
      currentExpanded.add(commentId);
    }
    _expandedComments.value = currentExpanded;
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
                child: ValueListenableBuilder<List<CommentModel>?>(
                  valueListenable: widget.comments,
                  builder: (context, commentsList, child) {
                    if (commentsList == null) {
                      return SizedBox();
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
              ValueListenableBuilder<CommentModel?>(
                valueListenable: widget.commentSelected,
                builder: (context, replying, child) {
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

  Widget _buildCommentsSection(List<CommentModel> comments) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      itemCount: comments.length + (_isLoading ? 1 : 0),
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
    bool hasReplies = comment.commentReplyResponses != null &&
        comment.commentReplyResponses!.isNotEmpty;

    // Sử dụng ValueListenableBuilder thay vì AnimatedBuilder
    return ValueListenableBuilder<String?>(
      valueListenable: widget.animatedCommentId,
      builder: (context, animatedId, child) {
        final bool needsAnimation = comment.commentId == animatedId;

        final Widget commentWidget = Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: primary.withAlpha((255 * 0.1).round()),
                        width: 2),
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
                  )),
              const SizedBox(width: 16),
              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment chính
                    Container(
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
                                  Text(
                                    comment.fullname ?? '',
                                    style: styleSmallBold.copyWith(
                                      color: primary
                                          .withAlpha((255 * 0.8).round()),
                                      fontSize: 13,
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

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              widget.setCommentSelected(comment: comment);
                            },
                            icon: Icon(
                              Icons.reply_outlined,
                              size: 15,
                              color: primary.withAlpha((255 * 0.7).round()),
                            ),
                            label: Text(
                              "Phản hồi",
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
                          if (hasReplies)
                            Expanded(
                              child: ValueListenableBuilder<Set<String>>(
                                valueListenable: _expandedComments,
                                builder: (context, expandedComments, _) {
                                  final isExpanded = expandedComments
                                      .contains(comment.commentId);
                                  return TextButton.icon(
                                    onPressed: () => _toggleExpanded(
                                        comment.commentId ?? ''),
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 15,
                                      color: primary
                                          .withAlpha((255 * 0.7).round()),
                                    ),
                                    label: Text(
                                      isExpanded
                                          ? "Ẩn tất cả phản hồi"
                                          : "Xem tất cả phản hồi (${comment.commentReplyResponses!.length})",
                                      style: styleVerySmall.copyWith(
                                        color: primary
                                            .withAlpha((255 * 0.7).round()),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Danh sách phản hồi (nếu có)
                    if (hasReplies)
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: _expandedComments,
                        builder: (context, expandedComments, _) {
                          final isExpanded =
                              expandedComments.contains(comment.commentId);
                          if (!isExpanded) return SizedBox.shrink();

                          return Container(
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
                              children:
                                  comment.commentReplyResponses!.map((reply) {
                                return _buildReplyItem(
                                    reply: reply, comment: comment);
                              }).toList(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

// Nếu comment cần animation
        if (needsAnimation) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: commentWidget,
          );
        }

        return commentWidget;
      },
    );
  }

  Widget _buildReplyItem(
      {required ReplyModel reply, required CommentModel comment}) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.animatedReplyId,
      builder: (context, animatedId, _) {
        final bool needsAnimation = reply.commentReplyId == animatedId;

        // Widget cơ bản cho reply
        final replyWidget = Container(
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
                    Container(
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
                          Text(
                            reply.fullnameReply ?? '',
                            style: styleSmallBold.copyWith(
                              color: primary.withAlpha((255 * 0.8).round()),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            AppUtils.getTimeAgo(reply.createdDate),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              //username, fullname đuọc set là của người reply,
                              //id là id của commentParent
                              widget.setCommentSelected(comment: CommentModel(username: reply.usernameReply, fullname: reply.fullnameReply, commentId: comment.commentId));
                            },
                            icon: Icon(
                              Icons.reply_outlined,
                              size: 15,
                              color: primary.withAlpha((255 * 0.7).round()),
                            ),
                            label: Text(
                              "Phản hồi",
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Nếu cần animation, wrap widget với TweenAnimationBuilder
        if (needsAnimation) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              );
            },
            child: replyWidget,
          );
        }

        return replyWidget;
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.commentSelected,
      builder: (context, commentSelected, child) => Container(
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
                          if (commentSelected != null) {
                            widget.onSendComment(comment: commentSelected);
                          } else {
                            widget.onSendComment();
                          }
                        },
                      )
                    : SizedBox(),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ],
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
}
