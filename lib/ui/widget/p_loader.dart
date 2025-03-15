import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Ploader extends StatelessWidget {
  final double stroke;

  const Ploader({super.key, this.stroke = 4});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isAndroid
          ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        strokeWidth: stroke,
      )
          : const CupertinoActivityIndicator(),
    );
  }
}

class PCLoader extends StatelessWidget {
  final double stroke;

  const PCLoader({super.key, this.stroke = 1});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 60,
      child: SizedBox(
        height: 30,
        width: 30,
        child: Ploader(stroke: stroke),
      ),
    );
  }
}