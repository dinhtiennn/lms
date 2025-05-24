import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CourseCommentScreen extends StatefulWidget {
  const CourseCommentScreen({Key? key}) : super(key: key);

  @override
  State<CourseCommentScreen> createState() => _CourseCommentScreenState();
}

class _CourseCommentScreenState extends State<CourseCommentScreen> {
  late CourseCommentViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseCommentViewModel>(
      viewModel: CourseCommentViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _viewModel.init();
          _viewModel.loadComments(isReset: true);
        });
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: white),
            ),
            title: Text(
              'Bình luận',
              style: styleLargeBold.copyWith(color: white),
            ),
            backgroundColor: primary2,
          ),
          body: SafeArea(
            child: _buildBody(),
          ),
          backgroundColor: white,
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<CommentModel>?>(
            valueListenable: _viewModel.comments,
            builder: (context, comments, _) {
              if (comments == null) {
                return _buildLoading();
              }

              if (comments.isEmpty) {
                return _buildEmptyComments();
              }

              return _buildCommentsList(comments);
            },
          ),
        ),
        // Sử dụng ValueListenableBuilder cho phần hiển thị "Đang trả lời"
        ValueListenableBuilder<CommentModel?>(
          valueListenable: _viewModel.commentSelected,
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
                        _viewModel.setCommentSelected();
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
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentsList(List<CommentModel> comments) {
    return ListView.builder(
      controller: _viewModel.commentsScrollController,
      padding: EdgeInsets.all(16),
      itemCount: comments.length + (_viewModel.isLoadingComments ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == comments.length) {
          return _buildLoadingIndicator();
        }

        final comment = comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetImageNetwork(
                url: comment.avatar,
                width: 40,
                height: 40,
                radiusAll: 20,
                widgetError: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (comment.fullname?.isNotEmpty ?? false) ? comment.fullname![0].toUpperCase() : "?",
                        style: styleMediumBold.copyWith(color: primary),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            comment.fullname ?? '',
                            style: styleSmallBold.copyWith(color: primary.withOpacity(0.8)),
                          ),
                        ),
                        if (comment.lastUpdate != null)
                          Text(
                            '(đã chỉnh sửa)',
                            style: styleVerySmall.copyWith(
                              color: grey3,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        SizedBox(width: 4),
                        Text(
                          AppUtils.getTimeAgo(comment.createdDate),
                          style: styleVerySmall.copyWith(color: grey3, fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      comment.detail ?? '',
                      style: styleSmall.copyWith(color: grey2, height: 1.4),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _viewModel.setCommentSelected(comment: comment),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: grey5.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.reply, size: 14, color: primary.withOpacity(0.7)),
                                SizedBox(width: 4),
                                Text(
                                  'Trả lời',
                                  style: styleVerySmall.copyWith(
                                    color: primary.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_canEdit(comment.username))
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: InkWell(
                              onTap: () => _showEditCommentDialog(comment),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: grey5.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_outlined, size: 14, color: grey3),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sửa',
                                      style: styleVerySmall.copyWith(
                                        color: grey3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Hiển thị replies nếu có
          if (comment.commentReplyResponses != null && comment.commentReplyResponses!.isNotEmpty)
            _buildRepliesList(comment),

          // Nút xem thêm replies nếu còn
          if ((comment.countOfReply ?? 0) > (comment.commentReplyResponses?.length ?? 0))
            Padding(
              padding: const EdgeInsets.only(left: 52.0, top: 4.0),
              child: TextButton.icon(
                onPressed: () => _viewModel.loadMoreReplies(commentId: comment.commentId ?? ''),
                icon: Icon(
                  Icons.comment_outlined,
                  size: 14,
                  color: primary.withOpacity(0.7),
                ),
                label: Text(
                  'Xem thêm phản hồi (${(comment.countOfReply ?? 0) - (comment.commentReplyResponses?.length ?? 0)})',
                  style: styleVerySmall.copyWith(
                    color: primary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRepliesList(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(left: 52.0, top: 8.0),
      child: Container(
        padding: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: primary.withOpacity(0.1),
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...comment.commentReplyResponses!.map((reply) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetImageNetwork(
                      url: reply.avatarReply,
                      width: 32,
                      height: 32,
                      radiusAll: 16,
                      widgetError: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (reply.fullnameReply?.isNotEmpty ?? false) ? reply.fullnameReply![0].toUpperCase() : "?",
                              style: styleSmallBold.copyWith(color: primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  reply.fullnameReply ?? '',
                                  style: styleVerySmallBold.copyWith(color: primary),
                                ),
                              ),
                              if (reply.lastUpdate != null)
                                Text(
                                  '(đã chỉnh sửa)',
                                  style: styleVerySmall.copyWith(
                                    color: grey3,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              SizedBox(width: 4),
                              Text(
                                AppUtils.getTimeAgo(reply.createdDate),
                                style: styleVerySmall.copyWith(color: grey3, fontSize: 10),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              text: '@${reply.fullnameOwner} ',
                              style: styleVerySmallBold.copyWith(
                                color: primary.withOpacity(0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: reply.detail ?? '',
                                  style: styleVerySmall.copyWith(
                                    color: grey2,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _viewModel.setCommentSelected(
                                  comment: CommentModel(
                                    username: reply.usernameReply,
                                    fullname: reply.fullnameReply,
                                    commentId: comment.commentId,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: grey5.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.reply, size: 12, color: primary.withOpacity(0.7)),
                                      SizedBox(width: 2),
                                      Text(
                                        'Trả lời',
                                        style: styleVerySmall.copyWith(
                                          color: primary.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_canEdit(reply.usernameReply))
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: InkWell(
                                    onTap: () => _showEditReplyDialog(reply, comment.commentId ?? ''),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: grey5.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit_outlined, size: 12, color: grey3),
                                          SizedBox(width: 2),
                                          Text(
                                            'Sửa',
                                            style: styleVerySmall.copyWith(
                                              color: grey3,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            // Thêm nút ẩn phản hồi
            TextButton.icon(
              onPressed: () => _hideReplies(comment),
              icon: Icon(
                Icons.visibility_off_outlined,
                size: 14,
                color: grey3,
              ),
              label: Text(
                'Ẩn phản hồi',
                style: styleVerySmall.copyWith(
                  color: grey3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: WidgetInput(
              controller: _viewModel.commentController,
              hintText: "Thêm bình luận...",
              hintStyle: styleSmall.copyWith(color: grey4),
              borderColor: grey5,
              style: styleSmall.copyWith(color: grey2),
              maxLines: 3,
              minLines: 1,
              onChanged: (value) => _viewModel.setCanSend(value.isNotEmpty ? true : false),
            ),
          ),
          SizedBox(width: 12),
          ValueListenableBuilder<bool>(
            valueListenable: _viewModel.canSend,
            builder: (context, canSend, _) {
              return InkWell(
                onTap: canSend
                    ? () {
                        _viewModel.send(comment: _viewModel.commentSelected.value);
                        FocusScope.of(context).unfocus();
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: canSend ? primary : grey5,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    color: canSend ? white : grey4,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: grey4,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có bình luận nào',
            style: styleMedium.copyWith(color: grey3),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy là người đầu tiên bình luận',
            style: styleSmall.copyWith(color: grey3),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: LoadingAnimationWidget.stretchedDots(
        color: primary,
        size: 50,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
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

  bool _canEdit(String? username) {
    return username == _viewModel.student?.email;
  }

  void _showEditCommentDialog(CommentModel comment) {
    final TextEditingController editController = TextEditingController(text: comment.detail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: Text(
          'Chỉnh sửa bình luận',
          style: styleMediumBold.copyWith(color: primary),
        ),
        content: TextField(
          controller: editController,
          style: styleSmall.copyWith(color: grey3),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung bình luận...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: styleSmall.copyWith(color: grey3)),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                _viewModel.editComment(
                  commentId: comment.commentId ?? '',
                  detail: editController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Lưu', style: styleSmall.copyWith(color: white)),
          ),
        ],
      ),
    );
  }

  void _showEditReplyDialog(ReplyModel reply, String parentCommentId) {
    final TextEditingController editController = TextEditingController(text: reply.detail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: Text(
          'Chỉnh sửa phản hồi',
          style: styleMediumBold.copyWith(color: primary),
        ),
        content: TextField(
          controller: editController,
          style: styleSmall.copyWith(color: grey2),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung phản hồi...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: styleSmall.copyWith(color: grey3)),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                _viewModel.editReply(
                  replyId: reply.commentReplyId ?? '',
                  parentCommentId: parentCommentId,
                  detail: editController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Lưu', style: styleSmall.copyWith(color: white)),
          ),
        ],
      ),
    );
  }

  // Thêm hàm _hideReplies
  void _hideReplies(CommentModel comment) {
    if (_viewModel.comments.value == null) return;

    final List<CommentModel> currentComments = List.from(_viewModel.comments.value!);
    final int commentIndex = currentComments.indexWhere((c) => c.commentId == comment.commentId);

    if (commentIndex != -1) {
      // Tạo bản sao của comment hiện tại
      final CommentModel updatedComment = CommentModel(
        commentId: comment.commentId,
        username: comment.username,
        fullname: comment.fullname,
        avatar: comment.avatar,
        detail: comment.detail,
        createdDate: comment.createdDate,
        countOfReply: comment.countOfReply,
        lastUpdate: comment.lastUpdate,
        chapterId: comment.chapterId,
        courseId: comment.courseId,
        commentReplyResponses: [], // Đặt danh sách phản hồi thành rỗng
      );

      // Cập nhật comment trong danh sách
      currentComments[commentIndex] = updatedComment;

      // Cập nhật ValueNotifier
      _viewModel.comments.value = currentComments;
    }
  }
}
