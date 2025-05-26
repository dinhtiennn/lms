import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:lms/src/resource/model/model.dart';

class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({Key? key}) : super(key: key);

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  late RegisterTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<RegisterTeacherViewModel>(
        viewModel: RegisterTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Form(
          key: _viewModel.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: Get.width * 0.25 > 200 ? 200 : Get.width * 0.38,
                      child: Image(
                        image: AssetImage(AppImages.png('logo')),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Đăng ký tài khoản',
                    style: styleVeryLargeBold.copyWith(color: primary),
                  ),
                  SizedBox(height: 24),
                  WidgetInput(
                    validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập họ tên'),
                    controller: _viewModel.fullNameController,
                    titleText: 'Họ và tên giảng viên',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: Nguyễn Văn A',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 16),
                  WidgetInput(
                    validator: AppValid.validateHuscEmail(),
                    controller: _viewModel.usernameController,
                    titleText: 'Email'.tr,
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: teacher@husc.edu.vn',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 16),
                  WidgetInput(
                    validator: AppValid.validatePassword(),
                    controller: _viewModel.passWordController,
                    titleText: 'Mật khẩu',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: Abc1234@',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    showEye: true,
                    obscureText: true,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 16),
                  WidgetInput(
                    validator: AppValid.validatePasswordConfirm(_viewModel.passWordController),
                    controller: _viewModel.passWordConfirmController,
                    titleText: 'Nhập lại mật khẩu',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: Abc123@',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    showEye: true,
                    obscureText: true,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 8),
                  _buildPasswordRequirement('min_length_requirement'.tr),
                  _buildPasswordRequirement('uppercase_requirement'.tr),
                  _buildPasswordRequirement('lowercase_requirement'.tr),
                  _buildPasswordRequirement('number_requirement'.tr),
                  _buildPasswordRequirement('special_char_requirement'.tr),
                  SizedBox(height: 24),
                  WidgetButton(
                    radius: BorderRadius.circular(100),
                    text: 'Đăng ký',
                    onTap: _viewModel.sendEmail,
                  ),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _viewModel.login,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${'Đã có tài khoản'.tr} ',
                            style: styleSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: grey3,
                            ),
                          ),
                          TextSpan(
                            text: '${'Đăng nhập'.tr}?',
                            style: styleSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: primary3,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.0,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationColor: primary3,
                            ),
                          )
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.sc,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: primary2),
          SizedBox(width: 8),
          Text(
            text,
            style: styleVerySmall.copyWith(color: grey3),
          ),
        ],
      ),
    );
  }
}
