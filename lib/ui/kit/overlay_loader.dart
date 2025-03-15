import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';

class CustomLoader {
  static final CustomLoader _customLoader = CustomLoader._createObject();

  CustomLoader._createObject();

  factory CustomLoader() {
    return _customLoader;
  }

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;

  _buildLoader() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return SizedBox(
            height: AppTheme.fullHeight(context),
            width: AppTheme.fullWidth(context),
            child: buildLoader(context));
      },
    );
  }

  showLoader(BuildContext context) {
    _overlayState = Overlay.of(context);
    _buildLoader();
    _overlayState?.insert(_overlayEntry!);
  }

  hideLoader() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      print("Exception:: $e");
    }
  }

  Widget buildLoader(BuildContext context, {Color backgroundColor = const Color(0xfff8f8f8)}) {
    var height = 140.0;
    return CustomScreenLoader(
      height: height,
      width: height,
      backgroundColor: backgroundColor,
    );
  }
}

class CustomScreenLoader extends StatelessWidget {
  final Color backgroundColor;
  final double height;
  final double width;

  const CustomScreenLoader({
    super.key,
    this.backgroundColor = const Color(0xfff8f8f8),
    this.height = 40,
    this.width = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Platform.isIOS
                  ? const CupertinoActivityIndicator(
                radius: 45,
              )
                  : const CircularProgressIndicator(
                strokeWidth: 2,
              ),
              Center(
                child: Image.asset(
                  AppConfig.of(context)!.config.appIcon,
                  height: 40,
                  width: 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}