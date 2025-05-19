import 'dart:io';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

class DocumentTeacherViewModel extends BaseViewModel {
  var formKey = GlobalKey<FormState>();
  TextEditingController keyword = TextEditingController();
  TextEditingController documentNameController = TextEditingController();
  TextEditingController documentDescriptionController = TextEditingController();
  ValueNotifier<List<DocumentModel>?> myDocuments = ValueNotifier(null);
  ValueNotifier<MajorModel?> majorSelected = ValueNotifier(null);
  ValueNotifier<List<MajorModel>?> majors = ValueNotifier(null);
  ValueNotifier<StatusOption?> statusSelected = ValueNotifier(null);
  ValueNotifier<File?> filePicker = ValueNotifier(null);
  ValueNotifier<String?> fileName = ValueNotifier(null);
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  int pageSize = 10;
  int currentPage = 0;
  bool hasMoreDocuments = true;
  final ScrollController scrollController = ScrollController();

  List<StatusOption> statusOptions = [
    StatusOption(Status.PUBLIC, 'Công khai', 'PUBLIC'),
    StatusOption(Status.PRIVATE, 'Riêng tư', 'PRIVATE'),
  ];

  init() async {
    scrollController.addListener(_onScroll);
    await refresh();
    await _loadMajor();
    statusSelected.value = statusOptions.firstWhere(
      (option) => option.apiValue == 'PUBLIC',
      orElse: () => statusOptions.first,
    );
    statusSelected.notifyListeners();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreDocuments();
    }
  }

  Future<void> refresh() async {
    currentPage = 0;
    hasMoreDocuments = true;
    await _loadMyDocument(isRefresh: true);
  }

  void loadMoreDocuments() {
    if (!isLoadingMore.value && hasMoreDocuments) {
      currentPage++;
      _loadMyDocument(isLoadMore: true);
    }
  }

  Future<void> _loadMajor() async {
    setLoading(true);
    NetworkState<List<MajorModel>> resultMajor = await majorRepository.getAllMajor();
    setLoading(false);
    if (resultMajor.isSuccess && resultMajor.result != null) {
      majors.value = resultMajor.result ?? [];
      majors.notifyListeners();
    } else {
      showToast(title: 'Không thể tải danh sách ngành học. Vui lòng thử lại!', type: ToastificationType.error);
    }
  }

  Future<void> initBottomSheet() async {
    documentNameController.clear();
    documentDescriptionController.clear();
    filePicker.value = null;
    fileName.value = null;
    majorSelected.value = null;
    statusSelected.value = statusOptions.firstWhere(
      (option) => option.apiValue == 'PUBLIC',
      orElse: () => statusOptions.first,
    );
    majorSelected.notifyListeners();
    statusSelected.notifyListeners();
  }

  void setMajor(MajorModel major) {
    majorSelected.value = major;
    majorSelected.notifyListeners();
  }

  Future<void> selectFile() async {
    try {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final extension = file.extension?.toLowerCase();

        // Kiểm tra loại file
        if (extension != null && (extension == 'pdf' || extension == 'doc' || extension == 'docx')) {
          filePicker.value = File(file.path!);
          fileName.value = file.name;
          filePicker.notifyListeners();
          fileName.notifyListeners();
        } else {
          showToast(
            title: 'Chỉ chấp nhận file PDF hoặc Word!',
            type: ToastificationType.error,
          );
        }
      }
    } catch (e) {
      showToast(
        title: 'Không thể chọn file. Vui lòng thử lại!',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> createDocument() async {
    if (filePicker.value == null) {
      showToast(
        title: 'Vui lòng chọn file tài liệu!',
        type: ToastificationType.error,
      );
      return;
    }

    if (majorSelected.value == null) {
      showToast(
        title: 'Vui lòng chọn ngành học!',
        type: ToastificationType.error,
      );
      return;
    }

    isLoading.value = true;
    isLoading.notifyListeners();

    NetworkState resultCreateDocument = await documentRepository.createDocument(
        title: documentNameController.text,
        description: documentDescriptionController.text,
        status: statusSelected.value?.apiValue ?? 'PUBLIC',
        majorId: majorSelected.value?.id ?? '',
        type: 'file',
        filePicker: filePicker.value);

    isLoading.value = false;
    isLoading.notifyListeners();

    if (resultCreateDocument.isSuccess) {
      showToast(
        title: 'Tạo tài liệu thành công!',
        type: ToastificationType.success,
      );
      Get.back();
      refresh(); // Refresh để hiển thị tài liệu mới
    } else {
      showToast(
        title: 'Tạo tài liệu thất bại: ${resultCreateDocument.message}',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> _loadMyDocument({bool isLoadMore = false, bool isRefresh = false}) async {
    if (isRefresh) {
      myDocuments.value = null;
      myDocuments.notifyListeners();
    }

    if (isLoadMore) {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(true);
    }

    NetworkState<List<DocumentModel>> resultMyDocument =
        await documentRepository.myDocument(keyword: keyword.text, pageSize: pageSize, pageNumber: currentPage);

    if (isLoadMore) {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(false);
    }

    if (resultMyDocument.isSuccess && resultMyDocument.result != null) {
      final newDocuments = resultMyDocument.result ?? [];

      if (isLoadMore && myDocuments.value != null) {
        // Nếu là loadmore, thêm vào danh sách hiện tại
        myDocuments.value = [...myDocuments.value!, ...newDocuments];
      } else {
        // Nếu là tải lần đầu hoặc refresh, gán mới
        myDocuments.value = newDocuments;
      }

      myDocuments.notifyListeners();

      // Kiểm tra xem còn dữ liệu để load tiếp không
      hasMoreDocuments = newDocuments.length >= pageSize;
    } else {
      if (!isLoadMore) {
        myDocuments.value = [];
        myDocuments.notifyListeners();
      }

      if (resultMyDocument.message?.isNotEmpty == true) {
        showToast(
          title: 'Lỗi tải tài liệu: ${resultMyDocument.message}',
          type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
