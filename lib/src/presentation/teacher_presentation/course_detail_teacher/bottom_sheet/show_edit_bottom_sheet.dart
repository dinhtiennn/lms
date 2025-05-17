import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:lms/src/presentation/widgets/date_picker/flutter_datetime_picker_plus.dart'
    as picker;

void showEditBottomSheet(
    BuildContext context, CourseDetailTeacherViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    'Chỉnh sửa khóa học',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    viewModel.setPickerEmpty();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16)
                  .copyWith(bottom: MediaQuery.paddingOf(context).bottom),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Ảnh khóa học
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
                      onTap: () => viewModel.pickCourseImage(),
                      prefix: Container(
                          height: 60,
                          width: 60,
                          margin: EdgeInsets.all(12),
                          child: ValueListenableBuilder<XFile?>(
                              valueListenable: viewModel.imageCoursePicker,
                              builder: (context, xFile, child) => xFile == null
                                  ? WidgetImageNetwork(
                                      url:
                                          '${AppEndpoint.baseImageUrl}${viewModel.course?.image}',
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      radiusAll: 8,
                                      widgetError: Container(
                                          decoration: BoxDecoration(
                                              color: grey5,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          padding: EdgeInsets.all(12),
                                          child: Image(
                                            image: AssetImage(
                                                AppImages.png('empty')),
                                          )),
                                    )
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
                      controller: viewModel.courseNameController,
                      titleText: 'Tên khóa học',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Tên khóa học',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      validator: AppValid.validateRequireEnter(
                          titleValid: 'Vui lòng nhập tên khóa học'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Mô tả khóa học
                    WidgetInput(
                      controller: viewModel.courseDescriptionController,
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
                      valueListenable: viewModel.majors,
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
                              onTap: () => showMajorBottomSheet(
                                  context, majors, viewModel),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child:
                                          ValueListenableBuilder<MajorModel?>(
                                        valueListenable:
                                            viewModel.majorSelected,
                                        builder: (context, major, child) =>
                                            Text(
                                          (major != null && major.name != null)
                                              ? major.name!
                                              : 'Vui lòng chọn ngành học',
                                          style: styleSmall.copyWith(
                                            color:
                                                major != null ? grey2 : grey4,
                                          ),
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

                    // Trạng thái khóa học
                    ValueListenableBuilder<StatusOption?>(
                      valueListenable: viewModel.statusSelected,
                      builder: (context, selectedStatus, child) {
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
                              onTap: () =>
                                  showStatusBottomSheet(context, viewModel),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedStatus?.label ??
                                            'Vui lòng chọn trạng thái khóa học',
                                        style: styleSmall.copyWith(
                                          color: selectedStatus != null
                                              ? grey2
                                              : grey4,
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

                    // Ngày kết thúc
                    WidgetInput(
                      controller: viewModel.endDateController,
                      titleText: 'Ngày kết thúc',
                      style: styleSmall.copyWith(color: grey2),
                      titleStyle: styleSmall.copyWith(color: grey2),
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Chọn ngày kết thúc',
                      hintStyle: styleSmall.copyWith(color: grey4),
                      readOnly: true,
                      onTap: () => buildBottomSheetSelectDate(
                          context, viewModel.endDateController),
                      suffix: ValueListenableBuilder<bool>(
                        valueListenable: viewModel.isEndDate,
                        builder: (context, isShow, child) => isShow
                            ? IconButton(
                                icon: Icon(Icons.close, color: grey2),
                                onPressed: () {
                                  viewModel.endDateController.clear();
                                },
                              )
                            : SizedBox(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // Không nhập ngày kết thúc thì hợp lệ
                        }

                        final startDate = viewModel.course?.startDate;
                        if (startDate == null) {
                          return 'Vui lòng chọn ngày bắt đầu trước';
                        }

                        final formattedStartDate = AppUtils.formatDateToDDMMYYYY(startDate.toString());
                        return AppValid.validateEndDate(formattedStartDate, value);
                      },

                    ),
                    const SizedBox(height: 24),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (viewModel.formKey.currentState!.validate()) {
                            viewModel.updateCourse();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void buildBottomSheetSelectDate(
    BuildContext context, TextEditingController controller) {
  picker.DatePicker.showDatePicker(
    context,
    theme: picker.DatePickerTheme(
      header: Text(
        'Chọn ngày',
        style: styleMediumBold.copyWith(color: primary3),
      ),
    ),
    showTitleActions: true,
    minTime: DateTime.now(),
    maxTime: DateTime.now().add(const Duration(days: 365)),
    onConfirm: (date) {
      controller.text = '${date.day}/${date.month}/${date.year}';
    },
    currentTime: DateTime.now(),
    locale: picker.LocaleType.vi,
  );
}
