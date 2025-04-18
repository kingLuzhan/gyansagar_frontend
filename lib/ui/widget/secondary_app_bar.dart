import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;

  const CustomAppBar(
      this.title, {
        super.key,
      })  : preferredSize = const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: Image.asset(Images.cross),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}