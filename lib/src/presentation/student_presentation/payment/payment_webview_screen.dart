import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/repo/course_repository.dart';
import 'package:toastification/toastification.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({Key? key}) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _webViewController;
  CourseRepository courseRepository = CourseRepository();
  bool _isLoading = true;
  String? _paymentUrl;
  String? _successUrl;
  String? _cancelUrl;
  String? _courseId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // Lấy thông tin từ arguments
    final arguments = Get.arguments as Map<String, dynamic>;
    _paymentUrl = arguments['paymentUrl'];
    _successUrl = arguments['successUrl'] ?? 'https://success.payment';
    _cancelUrl = arguments['cancelUrl'] ?? 'https://cancel.payment';
    _courseId = arguments['courseId'];
    // Khởi tạo WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Kiểm tra URL callback
            final url = request.url;
            if (url.startsWith(_successUrl!)) {
              // Xử lý khi thanh toán thành công
              _handlePaymentSuccess(url);
              return NavigationDecision.prevent;
            } else if (url.startsWith(_cancelUrl!)) {
              // Xử lý khi thanh toán bị hủy
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_paymentUrl!));
  }

  void _handlePaymentSuccess(String url) async {
    final uri = Uri.parse(url);
    final paymentId = uri.queryParameters['paymentId'];
    final payerID = uri.queryParameters['PayerID'];
    NetworkState resultPaymentSuccess = await courseRepository.paymentSuccess(paymentId: paymentId, payerID: payerID);
    if(resultPaymentSuccess.isSuccess ){
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text(
          'Thanh toán khóa học khóa học thành công.',
          style: styleSmall.copyWith(color: white),
        ),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
        showIcon: true,
        applyBlurEffect: true,
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      );
      Get.back(result: {
        'success': true,
        'courseId': _courseId,
      });
    }else{
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(
          'Thanh toán đã thất bại, vui lòng thử lại sau',
          style: styleSmall.copyWith(color: white),
        ),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
        showIcon: true,
        applyBlurEffect: true,
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      );
      Get.back(result: {
        'success': false,
        'courseId': _courseId,
      });
    }
  }

  void _handlePaymentCancelled() async {
    NetworkState resultPaymentCancel = await courseRepository.paymentCancel();

    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(
        'Thanh toán đã bị hủy',
        style: styleSmall.copyWith(color: white),
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      showIcon: true,
      applyBlurEffect: true,
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    );

    Get.back(result: {
      'success': false,
      'courseId': _courseId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán khóa học'),
        backgroundColor: primary2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () {
            // Hiển thị dialog xác nhận khi người dùng nhấn nút back
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: white,
                title: Text('Hủy thanh toán?', style: styleVeryLargeBold.copyWith(color: grey2),),
                content: Text(
                    'Bạn có chắc chắn muốn hủy quá trình thanh toán này không?', style: styleMedium.copyWith(color: grey2),),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Tiếp tục thanh toán', style: styleSmall.copyWith(color: primary3),),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handlePaymentCancelled();
                    },
                    child:
                        Text('Hủy thanh toán', style: styleSmall.copyWith(color: error),),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: primary2,
              ),
            ),
        ],
      ),
    );
  }
}
