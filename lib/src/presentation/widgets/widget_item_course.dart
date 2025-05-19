import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/presentation/widgets/widget_image_network.dart';
import 'package:lms/src/resource/model/course_model.dart';
import 'package:lms/src/utils/app_utils.dart';
import '../../configs/configs.dart';

class WidgetItemCourse extends StatefulWidget {
  final Function()? onTap;
  final CourseModel? course;
  final bool? joined;
  final Color? bgColor;

  const WidgetItemCourse({
    Key? key,
    this.onTap,
    this.course,
    this.joined,
    this.bgColor,
  }) : super(key: key);

  @override
  State<WidgetItemCourse> createState() => _WidgetItemCourseState();
}

class _WidgetItemCourseState extends State<WidgetItemCourse> {
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getLearningDurationLabel(String? type) {
    switch (type) {
      case 'LIMITED':
        return 'Giới hạn thời gian';
      case 'UNLIMITED':
        return 'Không giới hạn';
      default:
        return type ?? 'N/A';
    }
  }

  Widget _buildFeeInfo() {
    final bool isChargeable = widget.course?.feeType == 'CHARGEABLE';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '\$');

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isChargeable ? primary2.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isChargeable ? Icons.attach_money : Icons.money_off,
            size: 14,
            color: isChargeable ? primary2 : Colors.green,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isChargeable ? (widget.course?.price != null ? widget.course!.price.toString() : 'Có phí') : 'Miễn phí',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isChargeable ? primary2 : Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInfo() {
    final bool isLimited = widget.course?.learningDurationType == 'LIMITED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLimited ? Icons.timer : Icons.all_inclusive,
              size: 14,
              color: grey3,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _getLearningDurationLabel(widget.course?.learningDurationType),
                style: const TextStyle(
                  fontSize: 12,
                  color: grey3,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (isLimited && (widget.course?.startDate != null || widget.course?.endDate != null)) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              widget.course?.startDate != null && widget.course?.endDate != null
                  ? '${_formatDate(widget.course?.startDate)} - ${_formatDate(widget.course?.endDate)}'
                  : widget.course?.startDate != null
                      ? 'Bắt đầu: ${_formatDate(widget.course?.startDate)}'
                      : 'Kết thúc: ${_formatDate(widget.course?.endDate)}',
              style: const TextStyle(
                fontSize: 10,
                color: grey3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.08).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image with Overlay
            Stack(
              children: [
                // Course image
                WidgetImageNetwork(
                    url: '${AppEndpoint.baseImageUrl}${widget.course?.image ?? ''}',
                    width: double.infinity,
                    height: (widget.joined ?? false) ? 120 : 150,
                    fit: BoxFit.cover,
                    widgetError: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppUtils.getGradientForCourse(widget.course?.name ?? ''),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'LMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              widget.course?.name ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course title
                  Text(
                    widget.course?.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Fee info
                  _buildFeeInfo(),

                  const SizedBox(height: 8),

                  // Duration info
                  _buildDurationInfo(),

                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      // Teacher info
                      if (widget.course?.teacher != null) ...[
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'GV: ${widget.course?.teacher?.fullName ?? ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: grey2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Students count
                            Icon(
                              Icons.person,
                              size: 12,
                              color: grey3,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.course?.studentCount ?? 0}',
                              style: TextStyle(
                                fontSize: 11,
                                color: grey3,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Chapters count
                            Icon(
                              Icons.book,
                              size: 12,
                              color: grey3,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.course?.chapterCount ?? 0}',
                              style: TextStyle(
                                fontSize: 11,
                                color: grey3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (widget.joined ?? false) ...[
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        // Background progress bar
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            height: 4,
                            width: (widget.course != null &&
                                    widget.course!.progress != null &&
                                    widget.course?.progress != 0)
                                ? (widget.course!.progress! / 100) * constraints.maxWidth
                                : 0,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(widget.course?.progress ?? 0).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: primary2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
