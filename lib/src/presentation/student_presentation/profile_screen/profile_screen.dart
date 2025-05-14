import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ProfileViewModel>(
        viewModel: ProfileViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              elevation: 0,
              title: const Text(
                'Thông tin tài khoản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: white),
                  onPressed: () {
                    // Xử lý chỉnh sửa thông tin
                  },
                ),
              ],
            ),
            body: _buildBody(),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ValueListenableBuilder<StudentModel?>(
              valueListenable: _viewModel.studentModel,
              builder: (context, student, child) => _buildProfileHeader(student: student),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<StudentModel?>(
              valueListenable: _viewModel.studentModel,
              builder: (context, student, child) => _buildProfileInfo(student: student),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({required StudentModel? student}) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: primary2,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: black.withAlpha((255 * 0.2).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                          BorderSide(color: primary, width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                      boxShadow: [
                        BoxShadow(
                          color: black.withAlpha(20),
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
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                widgetError: Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primary.withAlpha((255 * 0.2).round()), width: 2),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: grey4,
                                    size: 48,
                                  ),
                                ),
                              )
                            : _buildDefaultAvatar()),
                  ),
                  Positioned(
                    bottom: -2,
                    right: 0,
                    child: InkWell(
                      splashColor: transparent,
                      onTap: _showBottomSheetSelectAvatar,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withAlpha((255 * 0.3).round()),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student.fullName ?? "",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: white.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined, size: 14, color: white),
                const SizedBox(width: 4),
                Text(
                  student.major?.name ?? "",
                  style: const TextStyle(color: white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      color: white,
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  void _showBottomSheetSelectAvatar() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: grey.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Thay đổi ảnh đại diện',
                        style: styleMediumBold.copyWith(color: black),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: grey.withAlpha((255 * 0.1).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_outlined, color: grey5),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Divider(
                color: grey.withAlpha((255 * 0.2).round()),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatarOptionItem(
                    Icons.photo_library_outlined,
                    'Thư viện',
                    () {
                      _viewModel.pickImageAvatar(confirmDialog: confirmSaveImage);
                      Navigator.pop(context);
                    },
                  ),
                  _buildAvatarOptionItem(
                    Icons.camera_alt_outlined,
                    'Máy ảnh',
                    () {
                      _viewModel.pickImageAvatar(camera: true, confirmDialog: confirmSaveImage);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<bool> confirmSaveImage() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Người dùng không thể đóng bằng cách nhấn bên ngoài dialog
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Xác nhận lưu ảnh',
                style: styleLargeBold.copyWith(color: grey2),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Bạn có chắc chắn muốn lưu ảnh này không?',
                    textAlign: TextAlign.center,
                    style: styleMedium.copyWith(color: grey3),
                  ),
                  SizedBox(height: 8),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: grey4),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('cancel'.tr, style: styleSmallBold.copyWith(color: grey4)),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: primary3,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('yes'.tr, style: styleSmallBold.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
              actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            );
          },
        ) ??
        false; // Trả về false nếu dialog bị đóng mà không chọn lưu
  }

  Widget _buildAvatarOptionItem(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: primary.withAlpha((255 * 0.1).round()),
              border: Border.all(
                color: primary.withAlpha((255 * 0.3).round()),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            label,
            style: styleSmall.copyWith(
              color: const Color(0xFF606060),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo({required StudentModel? student}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin cá nhân', Icons.person_outlined),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoItem('Họ và tên', student?.fullName ?? ""),
            _buildInfoItem('Email', student?.email ?? "", isContact: true),
            _buildInfoItem('Chuyên ngành', student?.major?.name ?? ""),
            if (student?.description != null) _buildInfoItem('Giới thiệu', student?.description ?? ''),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primary2, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: styleMediumBold.copyWith(color: primary2),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        children: _insertDividers(children),
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> widgets) {
    if (widgets.isEmpty) return widgets;

    final List<Widget> result = [];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: grey5),
        ));
      }
    }
    return result;
  }

  Widget _buildInfoItem(String label, String value, {bool isContact = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: grey3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isContact
                ? _buildContactValue(value)
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactValue(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: primary2.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primary2,
        ),
      ),
    );
  }
}
