import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:lms/src/resource/model/model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<RegisterViewModel>(
        viewModel: RegisterViewModel(),
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
                    titleText: 'Họ và tên sinh viên',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: Nguyễn Văn A',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 16),
                  ValueListenableBuilder<List<MajorModel>>(
                    valueListenable: _viewModel.majors,
                    builder: (context, majors, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _viewModel.majorSelected,
                          builder: (context, major, child) => WidgetInput(
                            readOnly: true,
                            controller: TextEditingController(
                              text: major?.name ?? '',
                            ),
                            style: styleSmall.copyWith(color: grey2),
                            onTap: () => _showMajorBottomSheet(context, majors),
                            titleText: 'Chọn ngành',
                            titleStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            suffix: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn ngành học' : null,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  WidgetInput(
                    validator: AppValid.validateHuscEmail(),
                    controller: _viewModel.usernameController,
                    titleText: 'Email'.tr,
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: example@husc.edu.vn',
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

  void _showMajorBottomSheet(BuildContext context, List<MajorModel> majors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Chọn ngành học',
                style: styleLargeBold.copyWith(color: grey2),
              ),
              SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: majors.length,
                  itemBuilder: (context, index) {
                    final major = majors[index];
                    return ListTile(
                      title: Text(
                        major.name ?? '',
                        style: styleMedium.copyWith(color: grey2),
                      ),
                      onTap: () {
                        _viewModel.setMajor(major);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
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
