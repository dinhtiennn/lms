import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';

class WidgetTypingIndicator extends StatefulWidget {
  final bool showIndicator;
  final Color bubbleColor;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  const WidgetTypingIndicator({
    Key? key,
    this.showIndicator = false,
    this.bubbleColor = const Color(0xFFE8E8E8),
    this.flashingCircleDarkColor = const Color(0xFF939497),
    this.flashingCircleBrightColor = const Color(0xFFAEAEB2),
  }) : super(key: key);

  @override
  _WidgetTypingIndicatorState createState() => _WidgetTypingIndicatorState();
}

class _WidgetTypingIndicatorState extends State<WidgetTypingIndicator> with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _indicatorSpaceAnimation;

  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.0, 0.4),
    Interval(0.3, 0.7),
    Interval(0.6, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: Interval(0.0, 1, curve: Curves.easeOut),
      reverseCurve: Interval(0.0, 1, curve: Curves.easeIn),
    ).drive(Tween<double>(begin: 0.0, end: 60));

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(WidgetTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _repeatingController.repeat();
        }
      });
  }

  void _hideIndicator() {
    _appearanceController
      ..reverse()
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _repeatingController.stop();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: child,
        );
      },
      child: widget.showIndicator ? _buildIndicator() : null,
    );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            color: white,
            child: Container(
              margin: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFlashingCircle(0),
                  _buildFlashingCircle(1),
                  _buildFlashingCircle(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashingCircle(int index) {
    return AnimatedBuilder(
      animation: _repeatingController,
      builder: (context, child) {
        final circleFlashPercent = _dotIntervals[index].transform(_repeatingController.value);
        final circleColorPercent = sin(pi * circleFlashPercent);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              widget.flashingCircleDarkColor,
              widget.flashingCircleBrightColor,
              circleColorPercent,
            ),
          ),
        );
      },
    );
  }
}
