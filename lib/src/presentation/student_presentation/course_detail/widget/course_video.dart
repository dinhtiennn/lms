import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/utils/chewie_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CourseVideo extends StatelessWidget {
  final dynamic videoPlayerHelper;
  final MediaQueryData mediaQuery;
  final String path;

  const CourseVideo({
    Key? key,
    required this.videoPlayerHelper,
    required this.mediaQuery,
    required this.path,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildVideoPlayer(videoPlayerHelper: videoPlayerHelper);
  }

  Widget _buildVideoPlayer({required VideoPlayerHelper videoPlayerHelper}) {
    // Kiểm tra nếu chewieController đã được khởi tạo
    if (videoPlayerHelper.chewieController != null) {
      return Material(
        color: Colors.black,
        child: Chewie(controller: videoPlayerHelper.chewieController!),
      );
    } else {
      // Hiển thị màn hình đang tải
      return Container(
        color: Colors.black,
        child: Center(
          child: LoadingAnimationWidget.stretchedDots(
            color: primary,
            size: 50,
          ),
        ),
      );
    }
  }
}