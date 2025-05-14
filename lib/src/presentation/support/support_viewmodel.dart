import 'package:lms/src/utils/app_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:lms/src/presentation/presentation.dart';

class SupportViewModel extends BaseViewModel {
  String? phoneNumber;
  String? facebook;

  init() async {
    this.phoneNumber = 'config.phoneNumber';
    facebook = 'config.facebook';
  }

  Future<void> phoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    // Kiểm tra quyền gọi điện
    PermissionStatus status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      AppUtils.openBrowserUrl(
        uri: phoneUri,
      );
    }
  }

  void openFacebook() async {
    AppUtils.openBrowserUrl(
      uri: Uri.parse(facebook ?? ''),
    );
  }
}
