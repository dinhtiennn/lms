import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/resource/model/model.dart';

import 'package:lms/src/presentation/presentation.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late DocumentViewModel _viewModel;
  // final List<Document> documents = [
  //   Document(
  //     title: 'Đại số tuyến tính',
  //     description: 'Tổng hợp về ma trận, định thức và không gian vector',
  //     dateUploaded: '15/02/2025',
  //     fileSize: '3.2 MB',
  //     fileType: 'PDF',
  //     iconData: Icons.picture_as_pdf,
  //   ),
  //   Document(
  //     title: 'Giải tích 1',
  //     description: 'Giới hạn, đạo hàm và tích phân',
  //     dateUploaded: '10/02/2025',
  //     fileSize: '2.5 MB',
  //     fileType: 'PDF',
  //     iconData: Icons.picture_as_pdf,
  //   ),
  //   Document(
  //     title: 'Cơ học cổ điển',
  //     description: 'Các định luật Newton và ứng dụng',
  //     dateUploaded: '20/02/2025',
  //     fileSize: '2.8 MB',
  //     fileType: 'PDF',
  //     iconData: Icons.picture_as_pdf,
  //   ),
  //   Document(
  //     title: 'Điện và từ học',
  //     description: 'Tổng hợp các định luật về điện và từ trường',
  //     dateUploaded: '18/02/2025',
  //     fileSize: '3.5 MB',
  //     fileType: 'DOC',
  //     iconData: Icons.description,
  //   ),
  //   Document(
  //     title: 'Lập trình Flutter cơ bản',
  //     description: 'Hướng dẫn xây dựng ứng dụng đầu tiên với Flutter',
  //     dateUploaded: '22/02/2025',
  //     fileSize: '4.1 MB',
  //     fileType: 'PDF',
  //     iconData: Icons.picture_as_pdf,
  //   ),
  //   Document(
  //     title: 'Cấu trúc dữ liệu và giải thuật',
  //     description: 'Các cấu trúc dữ liệu cơ bản và thuật toán',
  //     dateUploaded: '19/02/2025',
  //     fileSize: '3.0 MB',
  //     fileType: 'PPTX',
  //     iconData: Icons.slideshow,
  //   ),
  // ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BaseWidget<DocumentViewModel>(
        viewModel: DocumentViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Tài liệu học tập',
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Phần tìm kiếm
        Padding(
          padding: EdgeInsets.all(16.0),
          child: WidgetInput(
            hintText: 'Tìm kiếm tài liệu...',
            hintStyle: styleSmall.copyWith(color: grey4),
            style: styleSmall.copyWith(color: grey2),
            prefix: const Icon(
              Icons.search,
              color: grey3,
              size: 20,
            ),
            widthPrefix: 40,
            borderRadius: BorderRadius.circular(50),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        // Phần tiêu đề tài liệu mới
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tài liệu',
                style: styleMediumBold.copyWith(color: grey3),
              ),
            ],
          ),
        ),

        // // Danh sách tài liệu
        // Expanded(
        //   child: ListView.builder(
        //     padding: EdgeInsets.all(16),
        //     itemCount: documents.length,
        //     itemBuilder: (context, index) {
        //       final document = documents[index];
        //       return Card(
        //         color: white,
        //         margin: EdgeInsets.only(bottom: 12),
        //         elevation: 2,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //         child: ListTile(
        //           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //           leading: Container(
        //             width: 50,
        //             height: 50,
        //             decoration: BoxDecoration(
        //               color: primary3,
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //             child: Icon(
        //               document.iconData,
        //               color: white,
        //               size: 30,
        //             ),
        //           ),
        //           title: Text(
        //             document.title,
        //             style: styleSmallBold.copyWith(color: black),
        //           ),
        //           subtitle: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               SizedBox(height: 4),
        //               Text(
        //                 document.description,
        //                 style: styleVerySmall.copyWith(color: black),
        //               ),
        //               SizedBox(height: 4),
        //               Row(
        //                 children: [
        //                   Text(
        //                     document.dateUploaded,
        //                     style: styleVerySmall.copyWith(color: grey3, fontSize: 10),
        //                   ),
        //                   SizedBox(width: 8),
        //                   Text(document.fileSize, style: styleVerySmall.copyWith(fontSize: 10, color: grey3)),
        //                 ],
        //               ),
        //             ],
        //           ),
        //           trailing: IconButton(
        //             icon: Icon(Icons.download),
        //             onPressed: () {
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 SnackBar(
        //                   content: Text('${'download'.tr} ${document.title}'),
        //                   duration: const Duration(seconds: 2),
        //                 ),
        //               );
        //             },
        //           ),
        //           onTap: () {
        //             // Mở tài liệu
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) => DocumentViewPage(document: document),
        //               ),
        //             );
        //           },
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

// class DocumentViewPage extends StatelessWidget {
//   final Document document;
//
//   const DocumentViewPage({Key? key, required this.document}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(document.title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () {
//               // Logic để lưu tài liệu
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Đã lưu tài liệu'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 document.iconData,
//                 size: 100,
//                 color: Colors.grey.shade700,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Đây là tài liệu ${document.title}',
//                 style: styleLargeBold.copyWith(color: black),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 document.description,
//                 style: styleMedium.copyWith(color: blackLight),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
