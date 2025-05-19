import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:lms/src/presentation/widgets/date_picker/flutter_datetime_picker_plus.dart'
    as picker;

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({Key? key}) : super(key: key);

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  late CreateCourseViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CreateCourseViewModel>(
        viewModel: CreateCourseViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tạo khóa học mới'),
              backgroundColor: primary2,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                'Ảnh khóa học',
                style: styleSmall.copyWith(color: grey2),
              ),
            ),
            const SizedBox(height: 8),
            WidgetInput(
              readOnly: true,
              widthPrefix: 100,
              heightPrefix: 100,
              onTap: () => _viewModel.pickCourseImage(),
              prefix: Container(
                  height: 60,
                  width: 60,
                  margin: EdgeInsets.all(12),
                  child: ValueListenableBuilder<XFile?>(
                      valueListenable: _viewModel.imageCoursePicker,
                      builder: (context, xFile, child) => xFile == null
                          ? Container(
                              decoration: BoxDecoration(
                                  color: grey5,
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.all(12),
                              child: Image(
                                image: AssetImage(AppImages.png('empty')),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(xFile.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ))),
              radius: 12,
              widthSuffix: 28,
              suffix: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Image(
                    image: AssetImage(AppImages.png('upload')),
                  )),
            ),
            const SizedBox(height: 16),
            // Tên khóa học
            WidgetInput(
              controller: _viewModel.courseNameController,
              titleText: 'Tên khóa học',
              style: styleSmall.copyWith(color: grey2),
              titleStyle: styleSmall.copyWith(color: grey2),
              borderRadius: BorderRadius.circular(12),
              hintText: 'Tên khóa học',
              hintStyle: styleSmall.copyWith(color: grey4),
              validator: AppValid.validateRequireEnter(
                  titleValid: 'Vui lòng nhập tên khóa học'),
            ),
            const SizedBox(height: 16),

            // Mô tả khóa học
            WidgetInput(
              controller: _viewModel.courseDescriptionController,
              titleText: 'Mô tả khóa học',
              style: styleSmall.copyWith(color: grey2),
              titleStyle: styleSmall.copyWith(color: grey2),
              borderRadius: BorderRadius.circular(12),
              hintText: 'Nhập mô tả khóa học',
              hintStyle: styleSmall.copyWith(color: grey4),
              maxLines: 5,
              validator: AppValid.validateRequireEnter(
                  titleValid: 'Vui lòng nhập mô tả khóa học'),
            ),
            const SizedBox(height: 16),

            // Chọn ngành học
            ValueListenableBuilder<List<MajorModel>?>(
              valueListenable: _viewModel.majors,
              builder: (context, majors, child) {
                if (majors == null) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Ngành học',
                        style: styleSmall.copyWith(color: grey2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showMajorBottomSheet(context, majors),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: grey5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<MajorModel?>(
                              valueListenable: _viewModel.majorSelected,
                              builder: (context, major, child) => Text(
                                (major != null && major.name != null)
                                    ? major.name!
                                    : 'Vui lòng chọn ngành học',
                                style: styleSmall.copyWith(
                                  color: major != null ? grey2 : grey4,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: grey2),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Loại phí khóa học
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    'Loại phí khóa học',
                    style: styleSmall.copyWith(color: grey2),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showFeeTypeBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: grey5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<FeeStatusOption?>(
                          valueListenable: _viewModel.feeTypeSelected,
                          builder: (context, feeType, child) => Text(
                            feeType?.label ?? 'Vui lòng chọn loại phí',
                            style: styleSmall.copyWith(
                              color: feeType != null ? grey2 : grey4,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: grey2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hiển thị trường phù hợp dựa trên loại phí
            ValueListenableBuilder<FeeStatusOption?>(
              valueListenable: _viewModel.feeTypeSelected,
              builder: (context, feeType, child) {
                if (feeType == null) {
                  return const SizedBox.shrink();
                }

                // Nếu là khóa học có phí
                if (feeType.value == FeeStatusType.CHARGEABLE) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetInput(
                        controller: _viewModel.priceController,
                        titleText: 'Giá khóa học',
                        style: styleSmall.copyWith(color: grey2),
                        titleStyle: styleSmall.copyWith(color: grey2),
                        suffix: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '\$',
                            style: styleMediumBold.copyWith(color: primary3),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        textInputType: TextInputType.number,
                        hintText: 'Nhập giá của khóa học',
                        hintStyle: styleSmall.copyWith(color: grey4),
                        validator: AppValid.validateRequireEnter(
                            titleValid: 'Vui lòng nhập giá khóa học'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                // Nếu là khóa học miễn phí
                else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Trạng thái khóa học',
                          style: styleSmall.copyWith(color: grey2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showStatusBottomSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: grey5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<StatusOption?>(
                                valueListenable: _viewModel.statusSelected,
                                builder: (context, status, child) => Text(
                                  status?.label ??
                                      'Vui lòng chọn trạng thái khóa học',
                                  style: styleSmall.copyWith(
                                    color: status != null ? grey2 : grey4,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: grey2),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              },
            ),

            // Ngày bắt đầu
            WidgetInput(
              controller: _viewModel.startDateController,
              titleText: 'Ngày bắt đầu',
              style: styleSmall.copyWith(color: grey2),
              titleStyle: styleSmall.copyWith(color: grey2),
              borderRadius: BorderRadius.circular(12),
              hintText: 'Chọn ngày bắt đầu',
              hintStyle: styleSmall.copyWith(color: grey4),
              readOnly: true,
              onTap: () =>
                  _buildBottomSheetSelectDate(_viewModel.startDateController),
              validator: AppValid.validateRequireEnter(
                  titleValid: 'Vui lòng chọn ngày bắt đầu'),
            ),
            const SizedBox(height: 16),

            // Ngày kết thúc
            WidgetInput(
              controller: _viewModel.endDateController,
              titleText: 'Ngày kết thúc',
              style: styleSmall.copyWith(color: grey2),
              titleStyle: styleSmall.copyWith(color: grey2),
              borderRadius: BorderRadius.circular(12),
              hintText: 'Chọn ngày kết thúc',
              hintStyle: styleSmall.copyWith(color: grey4),
              readOnly: true,
              onTap: () =>
                  _buildBottomSheetSelectDate(_viewModel.endDateController),
              suffix: _viewModel.endDateController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: grey2),
                      onPressed: () {
                        setState(() {
                          _viewModel.endDateController.clear();
                        });
                      },
                    )
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else {
                  return AppValid.validateEndDate(
                    _viewModel.startDateController.text,
                    value,
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Nút tạo khóa học
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_viewModel.formKey.currentState!.validate()) {
                    _viewModel.addCourse();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tạo khóa học',
                  style: styleSmall.copyWith(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildBottomSheetSelectDate(TextEditingController controller) {
    List<String> date = controller.text.isNotEmpty
        ? controller.text.split('/')
        : [
            '${DateTime.now().day}',
            '${DateTime.now().month}',
            '${DateTime.now().year}'
          ];
    picker.DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(DateTime.now().year + 5),
        theme: picker.DatePickerTheme(
            header: Text(
              'Chọn ngày',
              style: styleLargeBold.copyWith(color: Colors.black),
            ),
            headerColor: Colors.white,
            backgroundColor: Colors.white,
            itemStyle: const TextStyle(
                color: grey2, fontWeight: FontWeight.w500, fontSize: 18),
            doneStyle: const TextStyle(color: Colors.black, fontSize: 16)),
        onConfirm: (date) {
      setState(() {
        controller.text =
            '${date.day < 10 ? '0${date.day}' : date.day}/${date.month < 10 ? '0${date.month}' : date.month}/${date.year < 10 ? '0${date.year}' : date.year}';
      });
    },
        currentTime: DateTime(
            int.parse(date[2]), int.parse(date[1]), int.parse(date[0])),
        locale: picker.LocaleType.vi);
  }

  void _showMajorBottomSheet(BuildContext context, List<MajorModel> majors) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn ngành học',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: majors.length,
                itemBuilder: (context, index) {
                  final major = majors[index];
                  return ListTile(
                    title: Text(
                      major.name ?? '',
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () {
                      _viewModel.setMajor(major);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeeTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: white,
      builder: (context) => Container(
        padding: EdgeInsets.all(16)
            .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn loại phí khóa học',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _viewModel.freeStatusOptions.length,
                itemBuilder: (context, index) {
                  final feeType = _viewModel.freeStatusOptions[index];
                  return ListTile(
                    title: Text(
                      feeType.label,
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    subtitle: Text(
                      feeType.value == FeeStatusType.CHARGEABLE
                          ? 'Khóa học có phí'
                          : 'Khóa học miễn phí',
                      style: styleVerySmall.copyWith(color: grey3),
                    ),
                    onTap: () {
                      _viewModel.feeTypeSelected.value = feeType;
                      // Reset giá và trạng thái khi thay đổi loại phí
                      if (feeType.value == FeeStatusType.CHARGEABLE) {
                        _viewModel.statusSelected.value = null;
                      } else {
                        _viewModel.priceController.text = '';
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: white,
      builder: (context) => Container(
        padding: EdgeInsets.all(16)
            .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn trạng thái khóa học',
                    style: styleMedium.copyWith(color: grey2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _viewModel.statusOptions.length,
                itemBuilder: (context, index) {
                  final status = _viewModel.statusOptions[index];
                  return ListTile(
                    title: Text(
                      status.label,
                      style: styleSmall.copyWith(color: grey2),
                    ),
                    onTap: () {
                      _viewModel.statusSelected.value = status;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
