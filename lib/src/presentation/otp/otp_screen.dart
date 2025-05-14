import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/widgets/widget_button.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:lms/src/presentation/presentation.dart';

enum OtpPurpose { register, forgotPassword }

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  late OtpViewModel _viewModel;
  late CustomTimerController _controller;
  bool _allowSubmit = false;

  @override
  void initState() {
    _controller = CustomTimerController(
        vsync: this,
        begin: const Duration(seconds: otpCountdownTime),
        end: const Duration(seconds: 0),
        initialState: CustomTimerState.reset,
        interval: CustomTimerInterval.milliseconds);
    _controller.start();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<OtpViewModel>(
        viewModel: OtpViewModel(),
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
    return Container(
      color: white,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios, color: Colors.black,size: 20,))
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    height: 16,
                  ),
                  Text(
                    'otp_input'.tr,
                    style: styleVeryLargeBold.copyWith(
                      color: primary,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text('Nhập OTP đã được gửi về Email',
                      style: styleVerySmall.copyWith(color: grey3), textAlign: TextAlign.center),
                  SizedBox(
                    height: 4,
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: _viewModel.phoneNumber,
                    builder: (context, phoneNumber, child) => Text(
                      phoneNumber,
                      style: styleVerySmall.copyWith(color: primary),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                  ),
                  _buildPinCodeForm(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.0),
            child: WidgetButton(
              text: 'continue'.tr,
              color: _allowSubmit ? primary : primary.withAlpha((255 * 0.3).round()),
              borderColor: _allowSubmit ? primary : transparent,
              onTap: () {
                _viewModel.verifyOtp();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCodeForm() {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          pastedTextStyle: TextStyle(
            color: success,
            fontWeight: FontWeight.bold,
          ),
          length: 6,
          blinkWhenObscuring: true,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: primary3,
            activeColor: primary3,
            inactiveColor: primary3,
            inactiveFillColor: primary3,
            selectedColor: primary3,
            selectedFillColor: primary3,
          ),
          cursorColor: black,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          controller: _viewModel.pinCodeController,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          textStyle: styleLargeBold.copyWith(color: primary),
          onCompleted: (v) {
            // _viewModel.verifyOtp();
          },
          onChanged: (value) {
            setState(() {
              _allowSubmit = getStateSubmit(value);
            });
          },
        ),
        CustomTimer(
            controller: _controller,
            builder: (state, time) {
              return InkWell(
                onTap: () {
                  // _viewModel.resendOtp();
                  _controller.start();
                },
                child: RichText(
                    text: TextSpan(
                        text: 'send_the_otp_code_back'.tr,
                        style: styleVerySmall.copyWith(fontWeight: FontWeight.w500, color: primary),
                        children: [
                      TextSpan(
                          text: '(00:${time.seconds})',
                          style: styleVerySmall.copyWith(fontWeight: FontWeight.w500, color: grey4)),
                    ])),
              );
            }),
      ],
    );
  }

  bool getStateSubmit(String value) {
    if (value.length == 6) {
      return true;
    }
    return false;
  }
}
