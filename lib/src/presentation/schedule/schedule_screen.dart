import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late ScheduleViewModel _viewModel;
  final List<String> daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'SUN'];

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ScheduleViewModel>(
      viewModel: ScheduleViewModel(),
      onViewModelReady: (viewModel) {
        _viewModel = viewModel..init();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primary2,
            elevation: 0,
            title: Text(
              'study_schedule'.tr,
              style: styleLargeBold.copyWith(color: white),
            ),
            centerTitle: true,
          ),
          body: SafeArea(child: _buildBody()),
          backgroundColor: white,
        );
      },
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 800));
        _viewModel.setDate(DateTime.now());
        _viewModel.initDays(DateTime.now().year, DateTime.now().month);
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(bottom: Get.height / 15),
        child: Column(
          children: [
            _buildCalendar(),
            SizedBox(height: 20),
            _buildContentSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildMonthSelector(),
        ValueListenableBuilder<DateTime>(
          valueListenable: _viewModel.date,
          builder: (context, date, child) => _buildLearningSchedule(date),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<DateTime>(
        valueListenable: _viewModel.date,
        builder: (context, date, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _viewModel.addMonths(-1),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: primary2,
                    size: 16,
                  ),
                ),
              ),
              Text(
                '${DateFormat('MMMM').format(date).toLowerCase().tr} ${date.year}',
                style: styleMediumBold.copyWith(color: black),
              ),
              IconButton(
                onPressed: () => _viewModel.addMonths(1),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: primary2,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLearningSchedule(DateTime dateSelect) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daysOfWeek.map((day) {
              return Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      day == 'SUN' ? 'Sun' : day,
                      style: styleSmallBold.copyWith(
                        color: day == 'SUN' ? primary3 : grey4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: grey5, // Màu viền
                width: 0.2, // Độ dày viền
              ),
            ),
            child: ValueListenableBuilder<List<DateTime>>(
              valueListenable: _viewModel.days,
              builder: (context, dateOfMonth, child) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: dateOfMonth.length,
                  itemBuilder: (context, index) {
                    bool isToday = dateOfMonth[index].isSameDate(DateTime.now());
                    bool isSelected = dateOfMonth[index].isSameDate(dateSelect);
                    bool isCurrentMonth = dateOfMonth[index].month == dateSelect.month;
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? primary3 : grey5,
                            width: isSelected ? 2 : 0.4,
                          ),
                          borderRadius: BorderRadius.circular(isSelected ? 4 : 0)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          if (isCurrentMonth) {
                            _viewModel.setDate(dateOfMonth[index]);
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary3
                                      : isToday && !isSelected
                                          ? white
                                          : transparent,
                                  shape: BoxShape.circle,
                                  border: isToday && !isSelected ? Border.all(color: primary3, width: 1) : null,
                                ),
                                child: Text(
                                  dateOfMonth[index].day.toString(),
                                  style: styleVerySmallBold.copyWith(
                                    color: !isCurrentMonth
                                        ? grey4
                                        : isSelected
                                            ? white
                                            : dateOfMonth[index].weekday == DateTime.sunday
                                                ? primary3
                                                : black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(1),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: primary2.withAlpha((255 * 0.8).round()),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(1),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withAlpha((255 * 0.8).round()),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: primary2.withAlpha((255 * 0.8).round()),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'study'.tr,
                      style: styleVerySmall.copyWith(color: blackLight),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha((255 * 0.8).round()),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'exam'.tr,
                      style: styleVerySmall.copyWith(color: blackLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSchedule() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _viewModel.date,
            builder: (context, date, child) => Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: primary3.withAlpha(50), shape: BoxShape.circle),
                    child: Text(DateFormat('EEEE').format(date).toLowerCase().tr,
                        style: styleMediumBold.copyWith(color: black)),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${DateFormat('dd').format(date)} ${DateFormat('MMMM').format(date).toLowerCase().tr}',
                    style: styleSmallBold.copyWith(color: black),
                  ),
                ],
              ),
            ),
          ),
          _buildSchedulesList(),
        ],
      ),
    );
  }

  Widget _buildSchedulesList() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _viewModel.date,
      builder: (context, date, child) {
        final schedules = [
          {
            'timeStart': '07:30',
            'timeEnd': '09:30',
            'subjectName': 'Thiết kế cơ sở dữ liệu',
            'classRoomName': 'Phòng B202',
            'teacherName': 'GV. Nguyễn Văn A'
          },
          {
            'timeStart': '10:00',
            'timeEnd': '11:30',
            'subjectName': 'Lập trình Java',
            'classRoomName': 'Phòng A305',
            'teacherName': 'GV. Trần Thị B'
          },
          {
            'timeStart': '13:30',
            'timeEnd': '16:00',
            'subjectName': 'An toàn thông tin',
            'classRoomName': 'Phòng LAB 3',
            'teacherName': 'GV. Lê Văn C'
          },
        ];

        if (schedules.isEmpty) {
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: grey3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'no_schedule_for_this_day'.tr,
                    style: styleSmall.copyWith(color: grey4),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: List.generate(
            schedules.length,
            (index) => _buildItemSchedule(
              timeStart: schedules[index]['timeStart'] ?? '',
              timeEnd: schedules[index]['timeEnd'] ?? '',
              subjectName: schedules[index]['subjectName'] ?? '',
              classRoomName: schedules[index]['classRoomName'] ?? '',
              teacherName: schedules[index]['teacherName'] ?? '',
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemSchedule({
    required String timeStart,
    required String timeEnd,
    required String subjectName,
    required String classRoomName,
    required String teacherName,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Get.toNamed(Routers.courseDetail);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: primary3.withAlpha(100),
                width: 8,
              ),
              right: BorderSide(
                color: primary3.withAlpha(100),
                width: 1,
              ),
              top: BorderSide(
                color: primary3.withAlpha(100),
                width: 1,
              ),
              bottom: BorderSide(
                color: primary3.withAlpha(100),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: black.withAlpha(15),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: black.withAlpha(20),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStart,
                              style: styleSmallBold.copyWith(color: black),
                            ),
                            SizedBox(
                              height: 16,
                              child: VerticalDivider(
                                color: grey3,
                                thickness: 1,
                                width: 20,
                              ),
                            ),
                            Text(
                              timeEnd,
                              style: styleSmall.copyWith(color: grey4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjectName,
                              style: styleMediumBold.copyWith(color: black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: grey4),
                                SizedBox(width: 4),
                                Text(
                                  classRoomName,
                                  style: styleSmall.copyWith(color: grey4),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primary3.withAlpha(32),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: primary3,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'detail'.tr,
                                        style: styleVerySmall.copyWith(
                                          color: primary3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
