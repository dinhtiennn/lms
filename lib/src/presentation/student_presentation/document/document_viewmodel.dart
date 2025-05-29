import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:toastification/toastification.dart';

class DocumentViewModel extends BaseViewModel {
  TextEditingController keyword = TextEditingController();
  ValueNotifier<StudentModel?> student = ValueNotifier(null);
  ValueNotifier<List<DocumentModel>?> documents = ValueNotifier(null);
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  int pageSize = 10;
  int currentPage = 0;
  bool hasMoreDocuments = true;
  final ScrollController scrollController = ScrollController();

  init() async {
    student.value = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    scrollController.addListener(_onScroll);
    await refresh();
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

  Future<void> _loadMyDocument({bool isLoadMore = false, bool isRefresh = false}) async {
    if (isRefresh) {
      documents.value = null;
      documents.notifyListeners();
    }

    if (isLoadMore) {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(true);
    }

    NetworkState<List<DocumentModel>> resultDocuments =
        await documentRepository.publicDocument(pageSize: pageSize, pageNumber: currentPage);

    if (isLoadMore) {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(false);
    }

    if (resultDocuments.isSuccess && resultDocuments.result != null) {
      final newDocuments = resultDocuments.result ?? [];

      if (isLoadMore && documents.value != null) {
        // Nếu là loadmore, thêm vào danh sách hiện tại
        documents.value = [...documents.value!, ...newDocuments];
      } else {
        // Nếu là tải lần đầu hoặc refresh, gán mới
        documents.value = newDocuments;
      }

      documents.notifyListeners();

      // Kiểm tra xem còn dữ liệu để load tiếp không
      hasMoreDocuments = newDocuments.length >= pageSize;
    } else {
      if (!isLoadMore) {
        documents.value = [];
        documents.notifyListeners();
      }

      if (resultDocuments.message?.isNotEmpty == true) {
        showToast(
          title: 'Lỗi tải tài liệu: ${resultDocuments.message}',
          type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> search(
      {required String keyword, bool isLoadMore = false, bool isRefresh = false, required String majorId}) async {
    if (isRefresh) {
      documents.value = null;
      documents.notifyListeners();
    }

    if (isLoadMore) {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(true);
    }

    NetworkState<List<DocumentModel>> resultDocuments = await documentRepository.search(
        keyword: keyword, majorId: majorId, pageSize: pageSize, pageNumber: currentPage);

    if (isLoadMore) {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    } else if (!isRefresh) {
      setLoading(false);
    }

    if (resultDocuments.isSuccess && resultDocuments.result != null) {
      final newDocuments = resultDocuments.result ?? [];

      if (isLoadMore && documents.value != null) {
        // Nếu là loadmore, thêm vào danh sách hiện tại
        documents.value = [...documents.value!, ...newDocuments];
      } else {
        // Nếu là tải lần đầu hoặc refresh, gán mới
        documents.value = newDocuments;
      }

      documents.notifyListeners();

      // Kiểm tra xem còn dữ liệu để load tiếp không
      hasMoreDocuments = newDocuments.length >= pageSize;
    } else {
      if (!isLoadMore) {
        documents.value = [];
        documents.notifyListeners();
      }

      if (resultDocuments.message?.isNotEmpty == true) {
        showToast(
          title: 'Lỗi tải tài liệu: ${resultDocuments.message}',
          type: ToastificationType.error,
        );
      }
    }
  }
}
