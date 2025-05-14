import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_valid.dart';

class ChangePasswordTeacherScreen extends StatefulWidget {
  const ChangePasswordTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordTeacherScreen> createState() => _ChangePasswordTeacherScreenState();
}

class _ChangePasswordTeacherScreenState extends State<ChangePasswordTeacherScreen> {
  late ChangePasswordTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChangePasswordTeacherViewModel>(
        viewModel: ChangePasswordTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'change_password'.tr,
                style: styleMediumBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return Column(
      children: [
        Form(
          key: _viewModel.formKey,
          child: Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Các trường nhập mật khẩu
                  _viewModel.otpArgument == null
                      ? WidgetInput(
                          controller: _viewModel.oldPassword,
                          validator: AppValid.validateRequireEnter(titleValid: 'enter_password'.tr),
                          titleText: 'old_password'.tr,
                          titleStyle: styleVerySmall.copyWith(color: grey3),
                          style: styleVerySmall.copyWith(color: grey3),
                          showEye: true,
                          obscureText: true,
                          borderColor: grey5,
                          hintText: 'enter_password'.tr,
                        )
                      : SizedBox(),
                  SizedBox(height: 16),

                  WidgetInput(
                    controller: _viewModel.newPassword,
                    style: styleVerySmall.copyWith(color: grey3),
                    validator: AppValid.validatePassword(),
                    titleText: 'new_password'.tr,
                    titleStyle: styleVerySmall.copyWith(color: grey3),
                    showEye: true,
                    obscureText: true,
                    borderColor: grey5,
                    hintText: 'enter_new_password'.tr,
                  ),
                  SizedBox(height: 16),

                  WidgetInput(
                    controller: _viewModel.newPasswordConfirm,
                    style: styleVerySmall.copyWith(color: grey3),
                    validator: AppValid.validatePasswordConfirm(_viewModel.newPassword),
                    titleText: 'Nhập lại mật khẩu mới',
                    titleStyle: styleVerySmall.copyWith(color: grey3),
                    showEye: true,
                    obscureText: true,
                    borderColor: grey5,
                    hintText: 'confirm_new_password'.tr,
                  ),

                  // Yêu cầu mật khẩu
                  SizedBox(height: 24),
                  Text(
                    'requirements'.tr,
                    style: styleSmall.copyWith(color: grey3, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildPasswordRequirement('min_length_requirement'.tr),
                  _buildPasswordRequirement('uppercase_requirement'.tr),
                  _buildPasswordRequirement('lowercase_requirement'.tr),
                  _buildPasswordRequirement('number_requirement'.tr),
                  _buildPasswordRequirement('special_char_requirement'.tr),
                ],
              ),
            ),
          ),
        ),

        // Nút lưu
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(top: 0),
          child: Column(
            children: [
              WidgetButton(
                  text: 'save'.tr,
                  onTap: () {
                    _viewModel.savePassword();
                  }),
            ],
          ),
        )
      ],
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
