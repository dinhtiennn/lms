import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_utils.dart';

class CourseDrawer extends StatelessWidget {
  final ValueNotifier<CourseDetailModel?> courseDetail;
  final Function(LessonMaterialModel, LessonModel) onMaterialSelected;
  final Function(ChapterModel, LessonModel) onChapterSelected;
  final Function(List<LessonQuizModel>, LessonModel) onQuizSelected;
  final Function() tapToInfo;
  final CourseModel? course;
  final ValueNotifier<LessonModel?> lessonCurrent;
  final ValueNotifier<CurrentContent?> currentContent;
  final logger;

  const CourseDrawer({
    Key? key,
    required this.courseDetail,
    required this.onMaterialSelected,
    required this.onChapterSelected,
    required this.onQuizSelected,
    required this.course,
    required this.logger,
    required this.lessonCurrent,
    required this.tapToInfo,
    required this.currentContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Drawer(
        backgroundColor: white,
        child: ValueListenableBuilder<CourseDetailModel?>(
          valueListenable: courseDetail,
          builder: (context, courseDetailValue, child) => Column(
            children: [
              _buildDrawerHeader(courseDetailValue),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                  child: _buildLessonList(courseDetailValue?.lesson),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(CourseDetailModel? courseDetail) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary2, primary3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          //Ảnh nền
          WidgetImageNetwork(
            url: course?.image ?? '',
            fit: BoxFit.cover,
            height: 200,
            widgetError: Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppUtils.getGradientForCourse(courseDetail?.name),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Gradient để văn bản dễ đọc hơn
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha((255 * 0.8).round()),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          // Thông tin khóa học
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        courseDetail?.name ?? '',
                        style: styleLargeBold.copyWith(color: white, fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary3.withAlpha((255 * 0.9).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Đang học',
                        style: styleSmall.copyWith(
                          color: white,
                          fontWeight: FontWeight.w600,
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
  }

  Widget _buildLessonList(List<LessonModel>? lessons) {
    if (lessons == null || lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 48, color: grey2),
            const SizedBox(height: 16),
            Text(
              'Không có bài học nào',
              style: styleMedium.copyWith(color: grey2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final LessonModel lesson = lessons[index];

        String? currentContentString;
        CurrentContent? content = currentContent.value;
        if (content is MaterialContent) {
          currentContentString = content.material.path;
        } else if (content is ChapterContent) {
          currentContentString = content.chapter.id;
        } else if (content is QuizContent) {
          currentContentString = 'quiz';
        }

        return ValueListenableBuilder(
          valueListenable: lessonCurrent,
          builder: (context, lessonCurrent, child) {
            return ExpansionTile(
              initiallyExpanded: lessons[index].id == lessonCurrent?.id,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.import_contacts_sharp,
                    color: primary3,
                    size: 20,
                  ),
                ),
              ),
              collapsedBackgroundColor: lessons[index].id == lessonCurrent?.id ? grey5 : white,
              title: Text(
                lesson.description ?? '',
                style: styleSmall.copyWith(color: black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: lesson.progress == true
                  ? Image(
                      image: AssetImage(AppImages.png('done')),
                      width: 16,
                    )
                  : Icon(Icons.keyboard_arrow_down, color: grey2),
              children: [
                if (lesson.lessonMaterials != null && lesson.lessonMaterials!.isNotEmpty) ...[
                  ...List.generate(
                      lesson.lessonMaterials!.length,
                      (index) => _buildMaterialItem(
                          context: context,
                          material: lesson.lessonMaterials![index],
                          lesson: lesson,
                          path: currentContentString ?? '')),
                ],
                if (lesson.chapters != null && lesson.chapters!.isNotEmpty) ...[
                  ...List.generate(
                      lesson.chapters!.length,
                      (index) => _buildChapterItem(
                          context: context,
                          chapter: lesson.chapters![index],
                          lesson: lesson,
                          idCurrentContent: currentContentString ?? '')),
                ],
                if (lesson.lessonQuizs != null && lesson.lessonQuizs!.isNotEmpty) ...[
                  _buildQuizItem(
                      context: context,
                      quiz: lesson.lessonQuizs,
                      isCompletedLesson: lesson.progress?.isCompleted ?? false,
                      lesson: lesson,
                      isSelected: currentContentString == 'quiz'),
                ],
                if ((lesson.lessonMaterials?.isEmpty ?? true) &&
                    (lesson.chapters?.isEmpty ?? true) &&
                    (lesson.lessonQuizs?.isEmpty ?? true)) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: grey3,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Hiện tại không có bài giảng hay bài tập nào',
                            style: styleSmall.copyWith(color: grey3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialItem(
      {required BuildContext context,
      LessonMaterialModel? material,
      required LessonModel lesson,
      required String path}) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      tileColor: path == material?.path ? grey5 : white,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.edit_document,
          size: 16,
          color: Colors.purple,
        ),
      ),
      title: Text(
        'Tài liệu học tập',
        style: styleSmall.copyWith(color: grey2),
      ),
      onTap: () {
        onMaterialSelected(material!, lesson);
        Navigator.of(context).pop(); // Đóng drawer
      },
    );
  }

  Widget _buildQuizItem(
      {required BuildContext context,
      List<LessonQuizModel>? quiz,
      required bool isCompletedLesson,
      required LessonModel lesson,
      required bool isSelected}) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      tileColor: isSelected ? grey5 : white,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.quiz_outlined,
          size: 16,
          color: Colors.purple,
        ),
      ),
      title: Text(
        'Bài quiz',
        style: styleSmall.copyWith(color: grey2),
      ),
      trailing: isCompletedLesson
          ? Image(
              image: AssetImage(AppImages.png('done')),
              width: 20,
              color: success,
            )
          : SizedBox.shrink(),
      onTap: () {
        onQuizSelected(quiz!, lesson);
        Navigator.of(context).pop(); // Đóng drawer
      },
    );
  }

  Widget _buildChapterItem(
      {required BuildContext context,
      ChapterModel? chapter,
      required LessonModel lesson,
      required String idCurrentContent}) {
    return ListTile(
      dense: true,
      tileColor: chapter?.id == idCurrentContent ? grey5 : white,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.play_lesson_outlined,
          size: 16,
          color: Colors.purple,
        ),
      ),
      title: Text(
        chapter?.name ?? '',
        style: styleSmall.copyWith(color: grey2),
      ),
      trailing: (chapter?.progress?.isCompleted ?? false)
          ? Image(
              image: AssetImage(AppImages.png('done')),
              width: 20,
              color: success,
            )
          : SizedBox.shrink(),
      onTap: () {
        onChapterSelected(chapter!, lesson);
        Navigator.of(context).pop(); // Đóng drawer
      },
    );
  }
}
