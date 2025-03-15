import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';

class PChip extends StatelessWidget {
  const PChip({
    super.key,
    required this.label,
    this.backgroundColor = Colors.white, // Default value
    this.isCrossIcon = false, // Default value
    this.onDeleted, // Optional parameter
    this.style, // Optional parameter
    this.borderColor = Colors.black54,
  });

  final String label;
  final Color backgroundColor;
  final bool isCrossIcon;
  final Function? onDeleted;
  final Color borderColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: AppTheme.outline(context).copyWith(
        borderRadius: BorderRadius.circular(30),
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Wrap(
        children: <Widget>[
          Text(label, style: style ?? const TextStyle()), // Default TextStyle if none provided
          if (isCrossIcon && onDeleted != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.cancel, size: 17).ripple(() => onDeleted!()),
          ],
        ],
      ),
    );
  }
}