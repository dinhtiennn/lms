import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<AccountViewModel>(
        viewModel: AccountViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              elevation: 0,
              title: Text(
                'Tài khoản'.tr,
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: const Color(0xFFF8F9FA),
          );
        });
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.only(top: 24, bottom: Get.height / 15, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserProfile(),
                SizedBox(height: 24),
                _buildSettingsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<StudentModel?>(valueListenable: _viewModel.student, builder: (context, student, child) => Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary.withAlpha((255 * 0.2).round()), width: 2),
              boxShadow: [
                BoxShadow(
                  color: black.withAlpha((255 * 0.05).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: student!.avatar != null
                    ? WidgetImageNetwork(
                  url: student.avatar,
                  radiusAll: 100,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  widgetError: Container(
                    decoration: BoxDecoration(
                              color: white,
                              shape: BoxShape.circle,
                      border: Border.all(color: primary.withAlpha((255 * 0.2).round()), width: 2),
                    ),
                    child: Icon(Icons.person, color: grey4,size: 32,),
                  ),
                )
                    : _buildDefaultAvatar()),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName ?? '',
                  style: styleMediumBold.copyWith(color: black),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  student.email ?? '',
                  style: styleSmall.copyWith(color: grey5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withAlpha((255 * 0.1).round()),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: primary,
              ),
              onPressed: () {
                _viewModel.editProfile();
              },
            ),
          ),
        ],
      ),),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      color: white,
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemAction(
              title: 'support'.tr,
              image: 'support',
              iconBackgroundColor: success,
              onTap: () {
                _viewModel.support();
              }),
          _buildItemAction(
              title: 'change_password'.tr,
              image: 'lock',
              iconBackgroundColor: const Color(0xFFFF9800),
              onTap: () {
                _viewModel.changePassword();
              }),
          _buildItemAction(
              title: 'Đăng xuất',
              image: 'logout',
              iconBackgroundColor: const Color(0xFFE53935),
              isLast: true,
              onTap: () {
                _showLogoutConfirmation();
              }),
        ],
      ),
    );
  }

  Widget _buildItemAction(
      {required String title,
      required String image,
      required Color iconBackgroundColor,
      bool isLast = false,
      required VoidCallback onTap}) {
    return InkWell(
      splashColor: transparent,
      highlightColor: grey.withAlpha((255 * 0.1).round()),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: iconBackgroundColor,
                  ),
                  child: Image(
                    image: AssetImage(AppImages.png(image)),
                    color: white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: styleSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: grey4,
                )
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: EdgeInsets.only(left: 72),
              child: const Divider(
                height: 1,
                color: Color(0xFFEEEEEE),
              ),
            )
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 30,
                    color: const Color(0xFFE53935),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Đăng xuât'.tr,
                  style: styleMediumBold.copyWith(color: black),
                ),
                SizedBox(height: 12),
                Text(
                  'Xác nhận đăng xuất'.tr,
                  textAlign: TextAlign.center,
                  style: styleSmall.copyWith(color: grey3),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: styleSmall.copyWith(
                            color: black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _viewModel.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Đăng xuất',
                          style: styleSmall.copyWith(
                            color: white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
