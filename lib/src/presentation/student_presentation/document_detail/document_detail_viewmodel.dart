import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/utils/utils.dart';

class DocumentDetailViewModel extends BaseViewModel {
  ValueNotifier<DocumentModel?> document = ValueNotifier(null);

  init() async {
    document.value = Get.arguments['document'];
  }


  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        Get.defaultDialog(
          backgroundColor: white,
          title: 'Cần quyền truy cập',
          titleStyle: styleSmallBold.copyWith(color: grey3),
          content: Text(
            'Cần cấp quyền lưu trữ để tải xuống file. Vui lòng cấp quyền trong cài đặt của ứng dụng.',
            style: styleSmall.copyWith(color: grey3),
          ),
          confirm: ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mở cài đặt'),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> downloadFile() async {
    if (document.value?.path == null) {
      showToast(
        title: 'Không tìm thấy đường dẫn tài liệu!',
        type: ToastificationType.error,
      );
      return;
    }

    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) return;

      final String url = document.value!.path!;
      final String fileName = document.value!.fileName ?? 'document.pdf';

      late final String savePath;
      if (Platform.isAndroid) {
        final downloadPath = await AndroidPathProvider.downloadsPath;
        savePath = '$downloadPath/$fileName';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }

      setLoading(true);

      await AppClients().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('Download progress: $progress%');
        },
      );

      setLoading(false);

      showToast(
        title: 'Tải xuống thành công: $fileName',
        type: ToastificationType.success,
      );
    } catch (e) {
      setLoading(false);

      showToast(
        title: 'Tải xuống thất bại: $e',
        type: ToastificationType.error,
      );
    }
  }
}
