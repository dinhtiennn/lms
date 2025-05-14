import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lms/src/presentation/presentation.dart';

class LoginTeacherScreen extends StatefulWidget {
  const LoginTeacherScreen({Key? key}) : super(key: key);

  @override
  State<LoginTeacherScreen> createState() => _LoginTeacherScreenState();
}

class _LoginTeacherScreenState extends State<LoginTeacherScreen> {
  late LoginTeacherViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<LoginTeacherViewModel>(
      viewModel: LoginTeacherViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: _buildBody(),
          ),
          backgroundColor: white,
        );
      },
    );
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
                  IconButton(
                    onPressed: () {
                      Get.offAllNamed(Routers.chooseRole);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
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
                    'login'.tr,
                    style: styleVeryLargeBold.copyWith(color: primary),
                  ),
                  SizedBox(height: 24),
                  WidgetInput(
                    validator: AppValid.validateRequireEnter(
                        titleValid: 'Vui lòng nhập mã giảng viên'),
                    controller: _viewModel.userNameController,
                    titleText: 'Email',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: teacher@husc.edu.vn',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 16),
                  WidgetInput(
                    validator: AppValid.validateRequireEnter(
                        titleValid: 'Vui lòng nhập mật khẩu'),
                    controller: _viewModel.passWordController,
                    titleText: 'Mật khẩu',
                    titleStyle: styleSmall.copyWith(color: grey2),
                    hintText: 'VD: Abc123@',
                    hintStyle: styleVerySmall.copyWith(color: grey4),
                    borderColor: grey5,
                    showEye: true,
                    obscureText: true,
                    style: styleSmall.copyWith(color: grey2),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _viewModel.forgotPassword,
                      child: Text(
                        'Quên mật khẩu?',
                        style: styleSmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: grey3,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.0,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationColor: grey3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ValueListenableBuilder(
                    valueListenable: _viewModel.preferredBiometric,
                    builder: (context, preferredBiometric, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: WidgetButton(
                              radius: BorderRadius.only(
                                topLeft: Radius.circular(100),
                                topRight: preferredBiometric != null
                                    ? Radius.circular(12)
                                    : Radius.circular(100),
                                bottomLeft: Radius.circular(100),
                                bottomRight: preferredBiometric != null
                                    ? Radius.circular(12)
                                    : Radius.circular(100),
                              ),
                              text: 'login'.tr,
                              onTap: _viewModel.login,
                            ),
                          ),
                          SizedBox(width: preferredBiometric != null ? 4 : 0),
                          if (preferredBiometric != null)
                            InkWell(
                              splashColor: transparent,
                              onTap: _viewModel.auth,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(100),
                                    topLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(100),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child:
                                    preferredBiometric == BiometricType.strong
                                        ? Icon(
                                            Icons.fingerprint_outlined,
                                            color: white,
                                            size: 30,
                                          )
                                        : Image(
                                            image: AssetImage(
                                                AppImages.png('face_id')),
                                            color: white,
                                            width: 30,
                                            height: 30,
                                          ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  //Phần login của google
                  // SizedBox(height: 32),
                  // Center(
                  //   child: Material(
                  //     color: Colors.transparent,
                  //     child: Ink(
                  //       decoration: BoxDecoration(
                  //         color: grey5,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: InkWell(
                  //         borderRadius: BorderRadius.circular(100),
                  //         splashColor:
                  //             Colors.blue.withAlpha((255 * 0.3).round()),
                  //         onTap: () {
                  //           _viewModel.loginWithGoogle();
                  //         },
                  //         child: Padding(
                  //           padding: EdgeInsets.all(8),
                  //           child: Image(
                  //             image: AssetImage(AppImages.png('google')),
                  //             width: 28,
                  //             height: 28,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _viewModel.register,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${'Chưa có tài khoản'} ',
                            style: styleSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: grey3,
                            ),
                          ),
                          TextSpan(
                            text: '${'Đăng ký'.tr}?',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
