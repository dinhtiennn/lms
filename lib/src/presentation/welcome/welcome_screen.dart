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

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late WelcomeViewModel _viewModel;
  int? _previousIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    white,
                    Color(0xFFF5F5F5),
                  ],
                ),
              ),
              child: SafeArea(child: _buildBody(screens)),
            ),
          );
        });
  }

  Widget _buildBody(List<Widget> screens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Skip and Back buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _viewModel.screenIndex,
                builder: (context, index, child) => index != 0
                    ? _buildNavigationButton(
                        text: 'BACK'.tr,
                        onTap: () => _viewModel.previous(),
                      )
                    : SizedBox(),
              ),
              _buildNavigationButton(
                text: 'Bỏ qua',
                onTap: () => _viewModel.chooseRole(),
              ),
            ],
          ),

          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _viewModel.screenIndex,
              builder: (context, index, child) {
                final previousIndex = _previousIndex ?? index;
                final isForward = index < previousIndex;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _previousIndex = index;
                });

                return PageTransitionSwitcher(
                  duration: Duration(milliseconds: 500),
                  reverse: !isForward,
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return FadeScaleTransition(
                      animation: animation,
                      child: child,
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
              padding: const EdgeInsets.symmetric(vertical: 20),
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.only(bottom: 20),
              child: Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary2, primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => _viewModel.onContinue(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'CONTINUE'.tr,
                            style: styleMediumBold.copyWith(
                              color: white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        elevation: 2,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFF8F8F8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: grey5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  text,
                  style: styleSmall.copyWith(
                    color: black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen1() {
    return _buildScreenContent(
      image: 'image1',
      title: 'Chào mừng đến với LMS 👋',
      subtitle:
          'Nơi kiến thức và sự sáng tạo hội tụ, mở ra cánh cửa tri thức mới',
    );
  }

  Widget _buildScreen2() {
    return _buildScreenContent(
      image: 'image2',
      title: 'Khám phá kho khóa học đa dạng 🎓',
      subtitle:
          'Học cùng các chuyên gia hàng đầu và tiếp cận kiến thức thực tiễn trong ngành',
    );
  }

  Widget _buildScreen3() {
    return _buildScreenContent(
      image: 'image3',
      title: 'Theo dõi tiến độ học tập 📊',
      subtitle:
          'Dễ dàng nắm bắt quá trình học tập với các chỉ số chi tiết và huy hiệu thành tích',
    );
  }

  Widget _buildScreen4() {
    return _buildScreenContent(
      image: 'image4',
      title: 'Tham gia cộng đồng học tập 🤝',
      subtitle:
          'Kết nối với các học viên và chuyên gia, chia sẻ kinh nghiệm và phát triển cùng nhau',
    );
  }

  Widget _buildScreenContent({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8F8F8), white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: grey4.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image(
                      image: AssetImage(AppImages.png(image)),
                      width: Get.width * 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: styleLarge.copyWith(
                color: black,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Subtitle text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: styleSmall.copyWith(
                color: grey2,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? primary : grey4,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
