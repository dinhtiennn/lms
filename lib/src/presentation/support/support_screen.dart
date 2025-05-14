import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late SupportViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<SupportViewModel>(
        viewModel: SupportViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'support'.tr,
                style: styleMediumBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              bottom: false,
              child: _buildBody(),
            ),
          );
        });
  }

  Widget _buildBody() {
    return Container(
      color: white,
      child: Column(
        children: [
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16), boxShadow: [
                    BoxShadow(
                      color: black.withAlpha(8),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: grey5,
                              ),
                              child: Image(
                                image: AssetImage(AppImages.png('call')),
                                width: 24,
                              )),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              _viewModel.phoneCall();
                            },
                            child: Text(
                              _viewModel.phoneNumber ?? '',
                              style: styleSmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.0,
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationColor: primary),
                            ),
                          ))
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: const Divider(
                          color: grey5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: grey5,
                              ),
                              child: Image(
                                image: AssetImage(AppImages.png('facebook')),
                                width: 24,
                              )),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              _viewModel.openFacebook();
                            },
                            child: Text(
                              _viewModel.facebook ?? '',
                              style: styleSmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.0,
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationColor: primary),
                            ),
                          ))
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
