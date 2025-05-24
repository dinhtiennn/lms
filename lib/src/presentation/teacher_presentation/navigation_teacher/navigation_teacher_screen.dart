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

  List<Widget> screens() {
    return [
      HomeTeacherScreen(),
      GroupTeacherScreen(),
      ChatBoxTeacherScreen(),
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
        title: "Chat",
        activeColorPrimary: Colors.blue,
        activeColorSecondary: black,
      ),
      PersistentBottomNavBarItem(
        icon: badges.Badge(
          badgeContent: ValueListenableBuilder(
            valueListenable: _viewModel.notificationView,
            builder: (context, notificationView, child) {
              final count = notificationView?.countUnreadNotification ?? 0;
              if (count == 0) return const SizedBox.shrink();
              final displayText = count > 99 ? '99+' : count.toString();
              return Text(
                displayText,
                style: styleVerySmall.copyWith(color: white, fontSize: 8),
              );
            },
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: error,
            padding: EdgeInsets.all(4),
            shape: badges.BadgeShape.circle,
          ),
          showBadge: true,
          position: badges.BadgePosition.topEnd(top: -8, end: -8),
          child: Image(image: AssetImage(AppImages.png('bell'))),
        ),
        title: "Thông báo",
        activeColorPrimary: primary2,
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
