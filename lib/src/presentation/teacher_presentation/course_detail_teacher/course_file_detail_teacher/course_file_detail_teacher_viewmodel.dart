import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chapter_model.dart';
import 'package:lms/src/utils/chewie_helper.dart';

class CourseFileDetailTeacherViewModel extends BaseViewModel {
  ValueNotifier<ChapterModel?> chapter = ValueNotifier(null);
  VideoPlayerHelper? videoHelper;

  init() async {
    logger.e('message');
    chapter.value = Get.arguments['chapter'];
    chapter.notifyListeners();
    if (chapter.value?.path?.split('.').last.toLowerCase().contains('mp4') ?? false) {
      initializePlayer();
    }
  }

  String get chapterUrl => '${AppEndpoint.baseImageUrl}${chapter.value?.path}';

  Future<void> initializePlayer() async {
    videoHelper = VideoPlayerHelper();
    await videoHelper!.initialize(chapterUrl, false);
    if (context.mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    videoHelper?.dispose();
    videoHelper = null;
    super.dispose();
  }
}
