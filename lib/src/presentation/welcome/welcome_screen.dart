import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late WelcomeViewModel _viewModel;
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      _buildScreen1(),
      _buildScreen2(),
      _buildScreen3(),
      _buildScreen4(),
    ];

    return BaseWidget<WelcomeViewModel>(
        viewModel: WelcomeViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: white,
            body: SafeArea(child: _buildBody(screens)),
          );
        });
  }

  Widget _buildBody(List<Widget> screens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Skip button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _viewModel.screenIndex,
                builder: (context, index, child) => index != 0
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Material(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        _viewModel.previous();
                      },
                      splashColor: primary3,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: Text(
                            'BACK'.tr,
                            style: styleVerySmall.copyWith(color: black),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Material(
                  color: grey5,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      _viewModel.chooseRole();
                    },
                    splashColor: primary3,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(
                        child: Text(
                          'Bỏ qua',
                          style: styleVerySmall.copyWith(color: black),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _viewModel.screenIndex,
              builder: (context, index, child) {
                // Lưu index trước đó để xác định hướng
                final previousIndex = _previousIndex ?? index;
                final isForward = index < previousIndex;
                print('previousIndex $previousIndex');
                print('index $index');
                print('isForward $isForward');
                // Cập nhật index trước đó cho lần render tiếp theo
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _previousIndex = index;
                });

                return PageTransitionSwitcher(
                  duration: Duration(milliseconds: 300),
                  reverse: !isForward, // Đảo ngược hiệu ứng khi index giảm
                  transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1.0, 0), // Phải khi tăng, trái khi giảm
                        end: Offset.zero,
                      ).animate(primaryAnimation),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset.zero,
                          end: Offset(1.0, 0), // Trái khi tăng, phải khi giảm
                        ).animate(secondaryAnimation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(index),
                    child: screens[index],
                  ),
                );
              },
            ),
          ),

          // Pagination dots
          ValueListenableBuilder(
            valueListenable: _viewModel.screenIndex,
            builder: (context, index, child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: index == 0),
                  _buildDot(isActive: index == 1),
                  _buildDot(isActive: index == 2),
                  _buildDot(isActive: index == 3),
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                width: Get.width,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  splashColor: Colors.grey.withAlpha((255 * 0.3).round()), // Tùy chỉnh màu splash
                  onTap: () => _viewModel.onContinue(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        'CONTINUE'.tr,
                        style: styleMediumBold.copyWith(color: white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScreen1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: grey5,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: grey4,
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Image(image: AssetImage(AppImages.png('image1'))),
                ),
              ),
            ],
          ),
        ),

        // Title text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Welcome to Cybex IT Group where learning meets innovation!',
            textAlign: TextAlign.center,
            style: styleLarge.copyWith(color: black),
          ),
        ),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Empowering your journey through cutting-edge IT education and expertise',
            textAlign: TextAlign.center,
            style: styleSmall.copyWith(color: black),
          ),
        ),
      ],
    );
  }

  Widget _buildScreen2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: grey5,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: grey4,
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Image(image: AssetImage(AppImages.png('image2'))),
                ),
              ),
            ],
          ),
        ),

        // Title text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Discover our comprehensive courses',
            textAlign: TextAlign.center,
            style: styleLarge.copyWith(color: black),
          ),
        ),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Learn with expert instructors and gain practical knowledge in the IT industry',
            textAlign: TextAlign.center,
            style: styleSmall.copyWith(color: black),
          ),
        ),
      ],
    );
  }

  Widget _buildScreen3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: grey5,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: grey4,
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Image(image: AssetImage(AppImages.png('image3'))),
                ),
              ),
            ],
          ),
        ),

        // Title text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Track your progress',
            textAlign: TextAlign.center,
            style: styleLarge.copyWith(color: black),
          ),
        ),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Monitor your learning journey with detailed analytics and achievement badges',
            textAlign: TextAlign.center,
            style: styleSmall.copyWith(color: black),
          ),
        ),
      ],
    );
  }

  Widget _buildScreen4() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: grey5,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: grey4,
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Image(image: AssetImage(AppImages.png('image4'))),
                ),
              ),
            ],
          ),
        ),

        // Title text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Join our community',
            textAlign: TextAlign.center,
            style: styleLarge.copyWith(color: black),
          ),
        ),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Connect with fellow learners and industry experts to enhance your learning experience',
            textAlign: TextAlign.center,
            style: styleSmall.copyWith(color: black),
          ),
        ),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 6.83,
      height: 6.83,
      decoration: BoxDecoration(
        color: isActive ? black : const Color(0xFFD9D9D9),
        border: Border.all(color: const Color(0xFFC6C6C6), width: 1),
        shape: BoxShape.circle,
      ),
    );
  }
}
