import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/arguments/argument.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({Key? key}) : super(key: key);

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  late ChooseRoleViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChooseRoleViewModel>(
        viewModel: ChooseRoleViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: white,
            body: _buildBody(),
          );
        });
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.35,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image(
                        image: AssetImage(AppImages.png('logo')),
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Chào mừng đến với Hệ thống hỗ trợ học tập trực tuyến',
                        style: styleLargeBold.copyWith(
                          color: primary3,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Vui lòng chọn vai trò của bạn',
                      style: styleMedium.copyWith(
                        color: primary3.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Phần chọn vai trò
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Sinh viên',
                            subtitle: 'Đăng nhập để học',
                            icon: Icons.school_rounded,
                            onTap: () => _viewModel.selectRole(Role.student),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Card Giảng viên
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Giảng viên',
                            subtitle: 'Đăng nhập để giảng dạy',
                            icon: Icons.person_rounded,
                            onTap: () => _viewModel.selectRole(Role.teacher),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary3.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: primary3.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary3.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: primary3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: styleMediumBold.copyWith(
                color: primary3,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: styleSmall.copyWith(
                color: grey3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
