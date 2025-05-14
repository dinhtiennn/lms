import 'package:flutter/material.dart';
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
                    height: (widget.joined ?? false) ? 120 : 200,
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

                // Duration badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((255 * 0.7).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.course?.learningDurationType ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
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

                  // Course description
                  Text(
                    widget.course?.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withAlpha((255 * 0.6).round()),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_sharp,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${widget.course?.studentCount ?? 0}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${widget.course?.lessonCount ?? 0}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: (widget.joined ?? false)
                            ? SizedBox()
                            : Container(
                          decoration: BoxDecoration(
                            color: (widget.course?.status?.contains('PUBLIC') ?? false)
                                ? success.withAlpha((255 * 0.12).round())
                                : error.withAlpha((255 * 0.12).round()),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((255 * 0.04).round()),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Icon(
                                  (widget.course?.status?.contains('PUBLIC') ?? false)
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_outline_rounded,
                                  color: (widget.course?.status?.contains('PUBLIC') ?? false) ? success : error,
                                  size: 18,
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  (widget.course?.status ?? '').toUpperCase(),
                                  style: styleSmallBold.copyWith(
                                    color: (widget.course?.status?.contains('PUBLIC') ?? false) ? success : error,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 10),

                  if (widget.joined ?? false) ...[
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
