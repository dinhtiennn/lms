import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/utils/chewie_helper.dart';

class CourseFileDetailTeacherScreen extends StatefulWidget {
  const CourseFileDetailTeacherScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CourseFileDetailTeacherScreen> createState() => _CourseFileDetailTeacherScreenState();
}

class _CourseFileDetailTeacherScreenState extends State<CourseFileDetailTeacherScreen> {
  late CourseFileDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseFileDetailTeacherViewModel>(
        viewModel: CourseFileDetailTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: white,
            appBar: AppBar(
              backgroundColor: primary2,
              title: ValueListenableBuilder(
                valueListenable: _viewModel.chapter,
                builder: (context, chapter, child) => Text(
                  chapter?.name ?? 'Nội dung chương',
                  style: styleMediumBold.copyWith(color: white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ValueListenableBuilder(
              valueListenable: _viewModel.chapter,
              builder: (context, chapter, child) => SafeArea(
                child: chapter?.type == 'file' && chapter != null
                    ? CourseFileTeacher(
                        url: AppUtils.pathMediaToUrl(chapter.path),
                        filePath: chapter.path ?? '',
                        mediaQuery: MediaQuery.of(context),
                      )
                    : _buildVideoWidget(chapter!),
              ),
            )
          );
        });
  }

  Widget _buildVideoWidget(ChapterModel chapter) {
    if (_viewModel.videoHelper != null && _viewModel.videoHelper!.isInitialized) {
      return CourseVideoTeacher(
        videoPlayerHelper: _viewModel.videoHelper!,
        mediaQuery: MediaQuery.of(context),
        path: chapter.path ?? '',
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primary),
            SizedBox(height: 16),
            Text(
              'Đang tải video...',
              style: styleSmall.copyWith(color: white),
            ),
          ],
        ),
      ),
    );
  }
}
