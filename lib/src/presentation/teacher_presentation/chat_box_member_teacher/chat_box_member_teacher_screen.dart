import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';

class ChatBoxMemberTeacherScreen extends StatefulWidget {
  const ChatBoxMemberTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxMemberTeacherScreen> createState() => _ChatBoxMemberTeacherScreenState();
}

class _ChatBoxMemberTeacherScreenState extends State<ChatBoxMemberTeacherScreen> {
  late ChatBoxMemberTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxMemberTeacherViewModel>(
        viewModel: ChatBoxMemberTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
            WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
            });
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(child: _buildBody()),
          );
        });
  }

  Widget _buildBody() {
    return SizedBox();
  }
}
