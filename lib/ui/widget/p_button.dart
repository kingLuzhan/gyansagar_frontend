import 'package:flutter/material.dart';

class PFlatButton extends StatelessWidget {
  const PFlatButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.isLoading,
    this.color,
    this.isWraped = false,
    this.isColored = true,
  });

  final VoidCallback onPressed;
  final String label;
  final ValueNotifier<bool> isLoading;
  final bool isWraped;
  final bool isColored;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isWraped ? null : double.infinity,
      child: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, child) {
          return TextButton(
            style: TextButton.styleFrom(
              backgroundColor: !isColored ? null : color ?? Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              disabledForegroundColor: Theme.of(context).disabledColor,
            ),
            onPressed: loading ? null : onPressed,
            child: loading
                ? SizedBox(
              height: 15,
              width: 15,
              child: FittedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).primaryColor),
                ),
              ),
            )
                : child!,
          );
        },
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}