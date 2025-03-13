import 'package:flutter/material.dart';

class PTitleText extends StatelessWidget {
  const PTitleText(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    final headlineSmall = Theme.of(context).textTheme.headlineSmall;
    return Text(
      text,
      style: headlineSmall?.copyWith(fontSize: 20) ?? TextStyle(fontSize: 20),
    );
  }
}

class PTitleTextBold extends StatelessWidget {
  const PTitleTextBold(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    return Text(
      text,
      style: titleLarge?.copyWith(fontSize: 20) ?? TextStyle(fontSize: 20),
    );
  }
}