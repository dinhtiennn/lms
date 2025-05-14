import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';

import '../presentation.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget<SplashViewModel>(
        viewModel: SplashViewModel(),
        onViewModelReady: (viewModel) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            body: child,
          );
        },
        child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: white,
      child: Center(
        child: Image(
          image: AssetImage(AppImages.png('logo')),
          width: MediaQuery.of(context).size.width / 2,
        ),
      ),
    );
  }
}
