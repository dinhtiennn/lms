import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/student_presentation/student_presentation.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:badges/badges.dart' as badges;

import 'package:lms/src/presentation/presentation.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with TickerProviderStateMixin {
  late NavigationViewModel _viewModel;
  int notificationCount = 6; // Số thông báo cần hiển thị

  List<Widget> screens() {
    return [
      HomeScreen(),
      CourseScreen(),
      GroupScreen(),
      ChatBoxScreen(),
      NotificationScreen(),
      AccountScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('home'))),
        title: "Trang chủ".tr,
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(
          image: AssetImage(AppImages.png('course')),
        ),
        title: "Khóa học".tr,
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('group'))),
        title: "Nhóm".tr,
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('chat'))),
        title: "Nhắn tin",
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: badges.Badge(
          // badgeContent: ValueListenableBuilder(
          //   valueListenable: _viewModel.notificationView,
          //   builder: (context, notificationView, child) {
          //     final count = notificationView?.countUnreadNotification ?? 0;
          //     final displayText = count > 99 ? '99+' : count.toString();
          //     return Text(
          //       displayText,
          //       style: styleVerySmall.copyWith(color: white, fontSize: 8),
          //     );
          //   },
          // ),
          badgeContent: ValueListenableBuilder(valueListenable: _viewModel.notificationView, builder: (context, notificationView, child) => Text(
            (notificationView?.countUnreadNotification ?? 0).toString(),
            style: styleVerySmall.copyWith(color: white, fontSize: 8),
          ),),
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.red,
            shape: badges.BadgeShape.circle,
          ),
          child: Image(image: AssetImage(AppImages.png('bell'))),
        ),
        title: "Thông báo",
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('profile'))),
        title: "Tài khoản",
        activeColorPrimary: primary3,
        activeColorSecondary: black,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NavigationViewModel>(
        viewModel: NavigationViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: UpgradeAlert(
                upgrader: Upgrader(
                  durationUntilAlertAgain: const Duration(days: 1),
                  willDisplayUpgrade: ({required display, installedVersion, versionInfo}) =>
                      print("Upgrade alert is displayed!"),
                ),
                child: _buildBody()),
          );
        });
  }

  Widget _buildBody() {
    return PersistentTabView(
      context,
      controller: _viewModel.controller,
      screens: screens(),
      items: navBarsItems(),
      backgroundColor: white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        colorBehindNavBar: white,
      ),
      navBarStyle: NavBarStyle.style1,
      neumorphicProperties: NeumorphicProperties(showSubtitleText: false),
      bottomScreenMargin: MediaQuery.paddingOf(context).bottom,
      navBarHeight: Get.height / 15,
    );
  }
}
