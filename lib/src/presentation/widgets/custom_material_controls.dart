import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:video_player/video_player.dart';

class CustomMaterialControls extends StatefulWidget {
  final bool showSkipButtons;
  final bool skipProgress;
  final bool hideSpeedButton;
  final bool firstTimeWatch;

  const CustomMaterialControls({
    Key? key,
    this.showSkipButtons = true,
    this.hideSpeedButton = true,
    this.skipProgress = true,
    this.firstTimeWatch = false,
  }) : super(key: key);

  @override
  State<CustomMaterialControls> createState() => _CustomMaterialControlsState();
}

class _CustomMaterialControlsState extends State<CustomMaterialControls> {
  VideoPlayerValue? _latestValue;
  bool _hideStuff = true;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _progressTimer;
  bool _displayTapped = false;
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  Duration _maxViewedPosition = Duration.zero;
  bool _isDragging = false;
  bool _hasShownLimitMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chewieController = ChewieController.of(context);
    _videoPlayerController = _chewieController.videoPlayerController;
  }

  @override
  void initState() {
    super.initState();
    _initTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _videoPlayerController.addListener(_updateState);

        if (widget.firstTimeWatch) {
          _setupProgressTracking();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoPlayerController.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    _latestValue = _videoPlayerController.value;

    if (_latestValue!.hasError) {
      return _buildErrorWidget();
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _cancelAndRestartTimer();
                if (_hideStuff) {
                  setState(() {
                    _hideStuff = false;
                  });
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
            IgnorePointer(
              ignoring: _hideStuff,
              child: AnimatedOpacity(
                opacity: _hideStuff ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.showSkipButtons)
                          _buildCenterSkipButton(
                            icon: Icons.replay_10,
                            onPressed: () => _skipTo(Duration(seconds: -10)),
                          ),
                        SizedBox(width: widget.showSkipButtons ? 24 : 0),
                        _buildCenterPlayPause(size: 55),
                        SizedBox(width: widget.showSkipButtons ? 24 : 0),
                        if (widget.showSkipButtons)
                          _buildCenterSkipButton(
                            icon: Icons.forward_10,
                            onPressed: () => _skipTo(Duration(seconds: 10)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: (!_chewieController.isPlaying && _hideStuff) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: _chewieController.isPlaying || !_hideStuff,
                child: Center(
                  child: _buildPulsatingPlayButton(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: _hideStuff,
                child: AnimatedOpacity(
                  opacity: _hideStuff ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildBottomBar(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tính năng giới hạn xem video cho sinh viên:
  // _maxViewedPosition: Theo dõi vị trí xem tối đa của sinh viên
  // Sinh viên chỉ có thể tua video đến vị trí họ đã xem
  // Thanh tiến trình hiển thị phần đã xem tối đa bằng màu đỏ mờ
  // Nếu sinh viên cố tua quá vị trí đã xem, sẽ hiển thị thông báo
  // Các nút skip và thanh tiến trình đều bị hạn chế không vượt quá vị trí đã xem
  // Tính năng này chỉ hoạt động khi widget.isStudent = true

  Widget _buildBottomBar(BuildContext context) {
    final position = _latestValue!.position;
    final duration = _latestValue!.duration;

    return Container(
      padding: EdgeInsets.only(bottom: 10, top: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black12, Colors.black54],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildProgressBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildPosition(),
                Spacer(),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFullScreenButton(),
              ],
            ),
          ),
          SizedBox(height: 8),
          _buildMaxViewedPosition(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double percent =
            _videoPlayerController.value.position.inMilliseconds /
                (_videoPlayerController.value.duration.inMilliseconds == 0
                    ? 1
                    : _videoPlayerController.value.duration.inMilliseconds);

        final double thumbPosition = percent * maxWidth;
        const double thumbSize = 12.0;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 32,
                child: Stack(
                  children: [
                    if (widget.firstTimeWatch)
                      Positioned.fill(
                        top: -4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: LinearProgressIndicator(
                            // màu của thời gian tối đa
                            value: _maxViewedPosition.inMilliseconds /
                                (_videoPlayerController
                                            .value.duration.inMilliseconds ==
                                        0
                                    ? 1
                                    : _videoPlayerController
                                        .value.duration.inMilliseconds),
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.yellow.withAlpha((255 * 0.5).round())),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: VideoProgressIndicator(
                        _videoPlayerController,
                        allowScrubbing: false,
                        colors: VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: widget.firstTimeWatch
                              ? Colors.transparent
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              //Vị trí của chấm tròn
              Positioned(
                left: thumbPosition.clamp(0, maxWidth - thumbSize) - 8,
                top: 6,
                child: _buildProgressThumb(),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: widget.skipProgress
                      ? (DragStartDetails details) {
                          _pauseHideTimer();
                          _videoPlayerController.pause();
                          _isDragging = true;
                          _hasShownLimitMessage = false;
                        }
                      : null,
                  onHorizontalDragUpdate: widget.skipProgress
                      ? (DragUpdateDetails details) {
                          final double relativePos =
                              details.localPosition.dx / maxWidth;
                          final double clampedPos = relativePos.clamp(0.0, 1.0);
                          final Duration position =
                              _videoPlayerController.value.duration *
                                  clampedPos;

                          if (widget.firstTimeWatch) {
                            if (position > _maxViewedPosition &&
                                !_hasShownLimitMessage) {
                              _hasShownLimitMessage = true;
                              _showSkipLimitMessage();
                              _videoPlayerController.seekTo(_maxViewedPosition);
                              return;
                            } else if (position <= _maxViewedPosition) {
                              _videoPlayerController.seekTo(position);
                            }
                          } else {
                            _videoPlayerController.seekTo(position);
                          }
                        }
                      : null,
                  onHorizontalDragEnd: widget.skipProgress
                      ? (DragEndDetails details) {
                          _restartHideTimer();
                          _videoPlayerController.play();
                          _isDragging = false;
                          _hasShownLimitMessage = false;
                        }
                      : null,
                  onTapDown: widget.skipProgress
                      ? (TapDownDetails details) {
                          final double relativePos =
                              details.localPosition.dx / maxWidth;
                          final double clampedPos = relativePos.clamp(0.0, 1.0);
                          final Duration position =
                              _videoPlayerController.value.duration *
                                  clampedPos;

                          if (widget.firstTimeWatch &&
                              position > _maxViewedPosition) {
                            _showSkipLimitMessage();
                            return;
                          }

                          _seekTo(position);
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressThumb() {
    final bool isDisabled = widget.firstTimeWatch &&
        _videoPlayerController.value.position >= _maxViewedPosition;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position = _latestValue!.position;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Text(
        _formatDuration(position),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMaxViewedPosition() {
    if (!widget.firstTimeWatch) {
      return SizedBox();
    }

    final double percent =
        _videoPlayerController.value.duration.inMilliseconds > 0
            ? (_maxViewedPosition.inMilliseconds /
                    _videoPlayerController.value.duration.inMilliseconds *
                    100)
                .roundToDouble()
            : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        'Đã xem: ${_formatDuration(_maxViewedPosition)} (${percent.toStringAsFixed(0)}%)',
        style: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        _latestValue!.errorDescription ?? 'Error',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _hideStuff = true;
        });
      }
    });
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _latestValue = _videoPlayerController.value;
      });
    }
  }

  void _setupProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _videoPlayerController.value.isPlaying) {
        final currentPosition = _videoPlayerController.value.position;
        if (currentPosition > _maxViewedPosition) {
          setState(() {
            _maxViewedPosition = currentPosition;
          });
        }
      }
    });
  }

  void _seekTo(Duration position) {
    if (widget.firstTimeWatch) {
      final currentPosition = _videoPlayerController.value.position;
      final duration = _videoPlayerController.value.duration;

      if (position > _maxViewedPosition) {
        _videoPlayerController.seekTo(_maxViewedPosition);
        return;
      }

      if (position > duration) {
        _videoPlayerController.seekTo(duration);
        return;
      }

      if (position < Duration.zero) {
        _videoPlayerController.seekTo(Duration.zero);
        return;
      }

      _videoPlayerController.seekTo(position);
    } else {
      _videoPlayerController.seekTo(position);
    }
  }

  void _skipTo(Duration duration) {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition + duration;

    if (widget.firstTimeWatch && duration.inSeconds > 0) {
      if (newPosition > _maxViewedPosition) {
        if (!_hasShownLimitMessage) {
          _hasShownLimitMessage = true;
          _showSkipLimitMessage();
        }
        _seekTo(_maxViewedPosition);
        return;
      }
    }

    _seekTo(newPosition);
  }

  void _showSkipLimitMessage() {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: Text('Bạn chỉ có thể tua đến vị trí đã xem'),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      showIcon: true,
      applyBlurEffect: true,
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    );
  }

  Widget _buildFullScreenButton() {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          _chewieController.toggleFullScreen();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            _chewieController.isFullScreen
                ? Icons.fullscreen_exit
                : Icons.fullscreen,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildCenterPlayPause({double size = 55}) {
    return Material(
      type: MaterialType.transparency,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          _chewieController.isPlaying
              ? _chewieController.pause()
              : _chewieController.play();
        },
        child: Ink(
          child: SizedBox(
            height: size + 20,
            width: size + 20,
            child: Center(
              child: Icon(
                _chewieController.isPlaying ? Icons.pause : Icons.play_arrow,
                size: size,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSkipButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final bool isForward = icon == Icons.forward_10;
    final bool isDisabled = widget.firstTimeWatch &&
        isForward &&
        _videoPlayerController.value.position >= _maxViewedPosition;

    return InkWell(
      onTap: isDisabled ? () => _showSkipLimitMessage() : onPressed,
      child: Ink(
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.withOpacity(0.3) : Colors.white24,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: Icon(
              icon,
              size: 40,
              color: isDisabled ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulsatingPlayButton() {
    return GestureDetector(
      onTap: () {
        _chewieController.play();
        _cancelAndRestartTimer();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        height: 80,
        width: 80,
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  void _pauseHideTimer() {
    _hideTimer?.cancel();
  }

  void _restartHideTimer() {
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _progressTimer?.cancel();
    _videoPlayerController.removeListener(_updateState);
    super.dispose();
  }
}
