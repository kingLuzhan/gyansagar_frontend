import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';

class FabButton extends StatelessWidget {
  const FabButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.animationValue,
    required this.text,
    required this.translateButton,
  });

  final VoidCallback onPressed;
  final String icon;
  final double animationValue;
  final String text;
  final Animation<double> translateButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Transform(
        transform: Matrix4.translationValues(
          translateButton.value * animationValue,
          0.0,
          0.0,
        ),
        child: Material(
          elevation: 4,
          color: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(40)),
          ),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(40)),
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: <Widget>[
                  Image.asset(icon, height: 20),
                  const SizedBox(width: 8),
                  Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary)),
                ],
              )).ripple(
            onPressed,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(40),
            ),
          ),
        ),
      ),
    );
  }
}