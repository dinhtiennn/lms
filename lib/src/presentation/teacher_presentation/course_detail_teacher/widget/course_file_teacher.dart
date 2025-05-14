import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:lms/src/resource/enum/enum.dart';

class CourseFileTeacher extends StatefulWidget {
  final String url;
  final String filePath;
  final MediaQueryData mediaQuery;

  const CourseFileTeacher({
    Key? key,
    required this.url,
    required this.filePath,
    required this.mediaQuery,
  }) : super(key: key);

  @override
  State<CourseFileTeacher> createState() => _CourseFileTeacherState();
}

class _CourseFileTeacherState extends State<CourseFileTeacher> {
  bool _isLoading = true;
  String? _errorMessage;
  FileType _fileType = FileType.unknown;
  String? _textContent;
  Uint8List? _pdfBytes;
  String? _docxXmlContent;

  @override
  void initState() {
    super.initState();
    _determineFileType();
    _loadFileContent();
  }

  void _determineFileType() {
    final extension = widget.filePath.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      _fileType = FileType.pdf;
    } else if (extension == 'docx' || extension == 'doc') {
      _fileType = FileType.docx;
    } else if (extension == 'txt' ||
        extension == 'md' ||
        extension == 'json' ||
        extension == 'csv' ||
        extension == 'xml' ||
        extension == 'html') {
      _fileType = FileType.text;
    } else {
      _fileType = FileType.potentially_text;
    }
  }

  Future<void> _loadFileContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AppClients().get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        switch (_fileType) {
          case FileType.pdf:
            _pdfBytes = data;
            break;

          case FileType.docx:
            if (isValidDocx(response.data)) {
              await _parseDocx(response.data);
            }
            break;

          case FileType.text:
          case FileType.potentially_text:
            _textContent = utf8.decode(data);
            if (_fileType == FileType.potentially_text) {
              _fileType = FileType.text;
            }
            break;

          default:
            _textContent = utf8.decode(data);
            _fileType = FileType.text;
            break;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải nội dung!';
          Logger().e('HTTP ${response.statusCode}');
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  bool isValidDocx(Uint8List data) {
    // Kiểm tra file ZIP đầu tiên, thường file DOCX bắt đầu với "PK"
    return data.length > 4 && data[0] == 0x50 && data[1] == 0x4B;
  }

  Future<void> _parseDocx(Uint8List data) async {
    try {
      final archive = ZipDecoder().decodeBytes(data);

      // Kiểm tra xem archive có file document.xml hay không
      final documentFile = archive.files.firstWhere(
        (file) => file.name.toLowerCase() == 'word/document.xml',
      );

      if (documentFile == null || documentFile.content == null) {
        _errorMessage = 'Không tìm thấy hoặc đọc được word/document.xml';
        return;
      }

      final contentData = documentFile.content;
      final xmlContent = utf8.decode(contentData);

      final xmlDoc = XmlDocument.parse(xmlContent);
      final buffer = StringBuffer();

      final paragraphs = xmlDoc.findAllElements('w:p');
      for (var p in paragraphs) {
        for (var node in p.descendants) {
          if (node is XmlElement) {
            if (node.name.local == 't') {
              buffer.write(node.text);
            } else if (node.name.local == 'br') {
              buffer.write('\n');
            }
          }
        }
        buffer.write('\n');
      }

      _docxXmlContent = buffer.toString().trim();
    } catch (e) {
      _errorMessage = 'Không thể đọc nội dung docx: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.mediaQuery.size.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.stretchedDots(
              color: primary,
              size: 50,
            ),
            SizedBox(height: 16),
            Text('Đang tải nội dung tài liệu...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: widget.mediaQuery.size.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFileContent,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return _buildFileViewer();
  }

  Widget _buildFileViewer() {
    switch (_fileType) {
      case FileType.pdf:
        return _buildPdfViewer();
      case FileType.docx:
        return _buildDocxViewer();
      case FileType.text:
        return _buildTextViewer();
      case FileType.binary:
      case FileType.unknown:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Định dạng file ${widget.filePath.split('.').last} không thể hiển thị trực tiếp',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadFileContent,
                icon: Icon(Icons.refresh),
                label: Text('Tải lại'),
              ),
            ],
          ),
        );
      case FileType.potentially_text:
        return Center(child: Text('Đang xác định loại file...'));
    }
  }

  Widget _buildPdfViewer() {
    if (_pdfBytes == null) {
      return const Center(child: Text('Không có dữ liệu PDF'));
    }

    return Column(
      children: [
        Expanded(
          child: SfPdfViewer.memory(
            _pdfBytes!,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableDoubleTapZooming: true,
            enableTextSelection: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDocxViewer() {
    if (_docxXmlContent == null) {
      return const Center(child: Text('Không có dữ liệu DOCX'));
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.mediaQuery.size.height,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            _docxXmlContent!,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.5,
              color: Colors.blue[900],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextViewer() {
    if (_textContent == null) {
      return const Center(child: Text('Không có nội dung văn bản'));
    }

    final extension = widget.filePath.split('.').last.toLowerCase();

    // Kiểm tra nếu là HTML, hiển thị bằng trình duyệt HTML
    if (extension == 'html' ||
        _textContent!.trim().toLowerCase().contains('<!doctype html>') ||
        _textContent!.trim().toLowerCase().contains('<html')) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.mediaQuery.size.height,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(extension),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _textContent!,
              style: TextStyle(
                fontFamily: _getFont(extension),
                fontSize: 14,
                height: 1.5,
                color: _getTextColor(extension),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(extension),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _textContent!,
                  style: TextStyle(
                    fontFamily: _getFont(extension),
                    fontSize: 14,
                    height: 1.5,
                    color: _getTextColor(extension),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String extension) {
    switch (extension) {
      case 'json':
        return Color(0xFFFFF8E1);
      case 'xml':
        return Color(0xFFF3E5F5);
      case 'html':
        return Color(0xFFFFEBEE);
      case 'md':
        return Color(0xFFE0F2F1);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(String extension) {
    switch (extension) {
      case 'json':
        return Colors.brown[800]!;
      case 'xml':
        return Colors.purple[800]!;
      case 'html':
        return Colors.red[900]!;
      default:
        return Colors.black87;
    }
  }

  String _getFont(String extension) {
    switch (extension) {
      case 'json':
      case 'xml':
      case 'html':
        return 'monospace';
      default:
        return 'sans-serif';
    }
  }
}
