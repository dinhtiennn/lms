import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/presentation/presentation.dart';

class CourseMaterialDetailTeacherScreen extends StatefulWidget {
  const CourseMaterialDetailTeacherScreen({Key? key}) : super(key: key);

  @override
  State<CourseMaterialDetailTeacherScreen> createState() =>
      _CourseMaterialDetailTeacherScreenState();
}

class _CourseMaterialDetailTeacherScreenState
    extends State<CourseMaterialDetailTeacherScreen> {
  late CourseMaterialDetailTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CourseMaterialDetailTeacherViewModel>(
        viewModel: CourseMaterialDetailTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Tài liệu học tập',
                style: styleMediumBold.copyWith(color: white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return SafeArea(
      child: CourseFileTeacher(
        url: AppUtils.pathMediaToUrl(_viewModel.path),
        filePath: _viewModel.material?.path ?? '',
        mediaQuery: MediaQuery.of(context),
      ),
    );
  }
}
