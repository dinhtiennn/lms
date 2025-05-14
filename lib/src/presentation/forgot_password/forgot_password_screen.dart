import 'package:lms/src/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_valid.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ForgotPasswordViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ForgotPasswordViewModel>(
        viewModel: ForgotPasswordViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(child: _buildBody()),
          );
        });
  }

  Widget _buildBody() {
    return Form(
      key: _viewModel.formKey,
      child: Container(
        color: white,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ))
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Container(
                  padding: EdgeInsets.all(24.0).copyWith(bottom: 0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: (Get.width - 24 * 2) / 3,
                        child: Image(
                          image: AssetImage(AppImages.png('logo')),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Quên mật khẩu',
                              style: styleVeryLargeBold.copyWith(color: primary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                  text: 'Nhập email để được cấp lại mật khẩu',
                                  style: styleVerySmall.copyWith(color: grey4)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 34,
                      ),
                      WidgetInput(
                        titleText: 'Email'.tr,
                        titleStyle: styleSmall.copyWith(color: grey4),
                        style: styleSmall.copyWith(color: grey2),
                        hintText: 'VD: email@husc.edu.vn',
                        hintStyle: styleSmall.copyWith(color: grey3, fontWeight: FontWeight.w400),
                        borderColor: grey4,
                        validator: AppValid.validateHuscEmail(),
                        controller: _viewModel.emailController,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      WidgetButton(
                        text: 'continue'.tr,
                        onTap: () {
                          _viewModel.verify();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
