import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:lms/src/configs/configs.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:badges/badges.dart' as badges;

import 'package:lms/src/presentation/presentation.dart';

class NavigationTeacherScreen extends StatefulWidget {
  const NavigationTeacherScreen({Key? key}) : super(key: key);

  @override
  State<NavigationTeacherScreen> createState() =>
      _NavigationTeacherScreenState();
}

class _NavigationTeacherScreenState extends State<NavigationTeacherScreen>
    with TickerProviderStateMixin {
  late NavigationTeacherViewModel _viewModel;
  int notificationCount = 5; // Số thông báo cần hiển thị

  List<Widget> screens() {
    return [
      HomeTeacherScreen(),
      GroupTeacherScreen(),
      SizedBox(),
      NotificationTeacherScreen(),
      AccountTeacherScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('home'))),
        title: "Trang chủ",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('group'))),
        title: "Nhóm",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('chat'))),
        title: "chat_box",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: badges.Badge(
          badgeContent: Text(
            notificationCount.toString(),
            style: styleVerySmall.copyWith(color: white),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.red,
            shape: badges.BadgeShape.circle,
          ),
          child: Image(image: AssetImage(AppImages.png('bell'))),
        ),
        title: "notification",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: Image(image: AssetImage(AppImages.png('profile'))),
        title: "account",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<NavigationTeacherViewModel>(
        viewModel: NavigationTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            body: UpgradeAlert(
                upgrader: Upgrader(
                  durationUntilAlertAgain: const Duration(days: 1),
                  willDisplayUpgrade: (
                          {required display, installedVersion, versionInfo}) =>
                      log("Upgrade alert is displayed!"),
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
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style1,
      neumorphicProperties: NeumorphicProperties(showSubtitleText: false),
      bottomScreenMargin: MediaQuery.paddingOf(context).bottom,
      navBarHeight: Get.height / 15,
    );
  }
}
