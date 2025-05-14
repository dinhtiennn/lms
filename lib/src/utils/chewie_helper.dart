import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms/src/presentation/widgets/custom_material_controls.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHelper {
  final Logger logger = Logger();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Event listeners
  final List<VoidCallback> _fullscreenListeners = [];
  final List<VoidCallback> _playPauseListeners = [];
  final List<VoidCallback> _completionListeners = [];
  bool _hasError = false;
  bool hasCompleted = false;
  String? _errorMessage;
  bool _firstTimeWatch = false;

  /// reset lại biến check của listener
  void resetCompletion() {
    hasCompleted = false;
  }

  /// Lấy ChewieController đã khởi tạo
  ChewieController? get chewieController => _chewieController;

  /// Lấy VideoPlayerController đã khởi tạo
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// Kiểm tra trạng thái đã khởi tạo
  bool get isInitialized =>
      _videoPlayerController?.value.isInitialized ?? false;

  /// Kiểm tra trạng thái đang phát
  bool get isPlaying => _videoPlayerController?.value.isPlaying ?? false;

  /// Lấy tổng thời lượng video
  Duration get totalDuration =>
      _videoPlayerController?.value.duration ?? Duration.zero;

  /// Lấy vị trí hiện tại
  Duration get currentPosition =>
      _videoPlayerController?.value.position ?? Duration.zero;

  /// Kiểm tra có lỗi không
  bool get hasError => _hasError;

  /// Lấy thông báo lỗi
  String? get errorMessage => _errorMessage;

  /// Kiểm tra trạng thái fullscreen
  bool get isFullScreen => _chewieController?.isFullScreen ?? false;

  /// Khởi tạo VideoPlayerHelper
  VideoPlayerHelper();

  /// Khởi tạo VideoPlayerController với URL video
  Future<bool> initialize(String videoUrl, bool firstTimeWatch) async {
    logger.d("Initializing player with URL: $videoUrl");
    logger.d("Initializing player with firstTimeWatch: $firstTimeWatch");

    try {
      // Hủy controller cũ nếu có
      dispose();

      // Reset trạng thái lỗi
      _hasError = false;
      _errorMessage = null;
      _firstTimeWatch = firstTimeWatch;

      // Đảm bảo URL hợp lệ
      if (videoUrl.isEmpty) {
        throw Exception("URL video không hợp lệ");
      }

      // Khởi tạo video controller
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'Authorization': 'Bearer ${AppPrefs.accessToken}',
        },
      );

      // Chờ controller khởi tạo
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Khởi tạo video quá thời gian chờ");
        },
      );

      if (!_videoPlayerController!.value.isInitialized) {
        throw Exception("Không thể khởi tạo video controller");
      }

      // Thiết lập Chewie Controller
      _setupChewieController(firstTimeWatch);

      // Đăng ký lắng nghe sự kiện
      _setupEventListeners();

      logger.d("Video player initialized successfully: $videoUrl");
      return true;
    } catch (e) {
      logger.e("Lỗi khởi tạo video: $e");
      _hasError = true;
      _errorMessage = e.toString();
      dispose();
      return false;
    }
  }

  /// Thiết lập ChewieController
  void _setupChewieController(bool firstTimeWatch) {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      logger.e("VideoPlayerController chưa được khởi tạo");
      return;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      showControls: true,
      showOptions: true,
      allowFullScreen: true,
      fullScreenByDefault: false,
      allowMuting: true,
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      routePageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondAnimation, provider) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: provider,
              ),
            );
          },
        );
      },
      customControls: CustomMaterialControls(
        showSkipButtons: true,
        skipProgress: true,
        hideSpeedButton: false,
        firstTimeWatch: firstTimeWatch,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.white, size: 42),
              const SizedBox(height: 12),
              Text(
                "Lỗi tải video: $errorMessage",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Thiết lập lắng nghe sự kiện
  void _setupEventListeners() {
    if (_chewieController != null) {
      _chewieController!.addListener(_handleFullscreenChange);
    }

    if (_videoPlayerController != null) {
      _videoPlayerController!.addListener(_handleVideoEvents);
    }
  }

  /// Xử lý sự kiện fullscreen
  void _handleFullscreenChange() {
    try {
      if (_chewieController != null) {
        // Thông báo cho các listener về sự kiện fullscreen
        for (final listener in _fullscreenListeners) {
          listener();
        }

        // Xử lý việc thoát fullscreen
        if (!_chewieController!.isFullScreen) {
          // Cập nhật các system overlays khi thoát khỏi fullscreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
            // Bắt buộc định hướng thẳng đứng khi thoát fullscreen
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          });
        }
      }
    } catch (e) {
      // Bắt các lỗi có thể xảy ra
      logger.e("Lỗi khi xử lý thay đổi fullscreen: $e");
      // Đảm bảo giao diện người dùng được phục hồi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      });
    }
  }

  /// Xử lý sự kiện video
  void _handleVideoEvents() {
    if (_videoPlayerController == null) return;

    // Kiểm tra trạng thái play/pause
    final isPlaying = _videoPlayerController!.value.isPlaying;

    // Thông báo sự kiện play/pause
    for (final listener in _playPauseListeners) {
      listener();
    }

    // Kiểm tra nếu video đã hoàn thành
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;

    if (position >= duration - const Duration(milliseconds: 500)) {
      // Thông báo hoàn thành
      for (final listener in _completionListeners) {
        listener();
      }
    }
  }

  /// Đăng ký sự kiện fullscreen
  void addFullscreenListener(VoidCallback listener) {
    _fullscreenListeners.add(listener);
  }

  /// Hủy đăng ký sự kiện fullscreen
  void removeFullscreenListener(VoidCallback listener) {
    _fullscreenListeners.remove(listener);
  }

  /// Đăng ký sự kiện play/pause
  void addPlayPauseListener(VoidCallback listener) {
    _playPauseListeners.add(listener);
  }

  /// Hủy đăng ký sự kiện play/pause
  void removePlayPauseListener(VoidCallback listener) {
    _playPauseListeners.remove(listener);
  }

  /// Đăng ký sự kiện hoàn thành
  void addCompletionListener(VoidCallback listener) {
    _completionListeners.add(listener);
  }

  /// Hủy đăng ký sự kiện hoàn thành
  void removeCompletionListener(VoidCallback listener) {
    _completionListeners.remove(listener);
  }

  /// Phát video
  Future<void> play() async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.play();
    }
  }

  /// Tạm dừng video
  Future<void> pause() async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.pause();
    }
  }

  /// Chuyển đổi phát/tạm dừng
  Future<void> togglePlay() async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      if (_videoPlayerController!.value.isPlaying) {
        await pause();
      } else {
        await play();
      }
    }
  }

  /// Tua đến vị trí cụ thể
  Future<void> seekTo(Duration position) async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.seekTo(position);
    }
  }

  /// Đặt âm lượng (từ 0.0 đến 1.0)
  Future<void> setVolume(double volume) async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.setVolume(volume);
    }
  }

  /// Đặt tốc độ phát (1.0 là bình thường)
  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.setPlaybackSpeed(speed);
    }
  }

  /// Chuyển đổi fullscreen
  void toggleFullScreen() {
    if (_chewieController != null) {
      _chewieController!.toggleFullScreen();
    }
  }

  /// Giải phóng tài nguyên
  void dispose() {
    logger.d("Disposing video player resources");

    // Hủy các event listener
    _fullscreenListeners.clear();
    _playPauseListeners.clear();
    _completionListeners.clear();

    // Hủy controllers
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }

    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }

    // Đảm bảo trạng thái hệ thống được khôi phục
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
