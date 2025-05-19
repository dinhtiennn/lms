import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatDetailViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatDetailViewModel>(
        viewModel: ChatDetailViewModel(),
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
