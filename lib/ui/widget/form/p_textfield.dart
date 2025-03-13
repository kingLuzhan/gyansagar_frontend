import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/widget/form/validator.dart';

enum FieldType {
  name,
  email,
  phone,
  password,
  confirmPassword,
  reset,
  text,
  optional
}

class PTextField extends StatelessWidget {
  const PTextField({
    super.key,
    this.controller,
    this.label,
    required this.type,
    this.maxLines = 1,
    this.hintText = '',
    this.height = 70,
    this.onSubmit,
    this.suffixIcon,
    this.onChange,
    this.obscureText = false,
    this.padding = const EdgeInsets.all(0),
  });

  final TextEditingController? controller;
  final String? label, hintText;
  final FieldType type;
  final int maxLines;
  final double height;
  final Widget? suffixIcon;
  final bool obscureText;
  final Function(String)? onSubmit;
  final EdgeInsetsGeometry padding;
  final Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
        ],
        SizedBox(
          height: height,
          child: TextFormField(
            autocorrect: false,
            obscureText: obscureText,
            maxLines: maxLines,
            onChanged: onChange,
            keyboardType: getKeyboardType(type),
            controller: controller,
            decoration: getInputDecoration(
              context,
              hintText: hintText,
              suffixIcon: suffixIcon,
            ),
            textInputAction: (type == FieldType.password ||
                type == FieldType.reset ||
                type == FieldType.confirmPassword)
                ? TextInputAction.done
                : TextInputAction.next,
            validator: (value) => PValidator.buildValidators(context, type)(value),
            onFieldSubmitted: onSubmit,
          ),
        ),
      ],
    );
  }

  InputDecoration getInputDecoration(BuildContext context,
      {String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  TextInputType getKeyboardType(FieldType choice) {
    switch (choice) {
      case FieldType.name:
        return TextInputType.text;
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.password:
      case FieldType.confirmPassword:
        return TextInputType.visiblePassword;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.reset:
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }
}