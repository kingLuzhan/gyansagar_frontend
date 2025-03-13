import 'package:flutter/material.dart';

class AnimatedFabButton extends StatelessWidget {
  const AnimatedFabButton({
    Key? key,
    required this.showFabButton,
    required this.children,
  }) : super(key: key);

  final ValueNotifier<bool> showFabButton;
  final List<Widget> children;

  Widget _floatingActionButtonColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showFabButton,
      builder: (BuildContext context, bool value, Widget? child) {
        return AnimatedPositioned(
          bottom: 16 + 60.0,
          right: 25,
          duration: Duration(milliseconds: 500),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: value ? 1 : 0,
            child: _floatingActionButtonColumn(),
          ),
        );
      },
    );
  }
}