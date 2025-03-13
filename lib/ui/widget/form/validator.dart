import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';

class PValidator {
  static FormFieldValidator<String>? buildValidators(BuildContext context, FieldType type) {
    switch (type) {
      case FieldType.name:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Name is required';
          }
          return null;
        };
      case FieldType.email:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email address';
          }
          return null;
        };
      case FieldType.phone:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Phone number is required';
          }
          final phoneRegex = RegExp(r'^\d{10}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Enter a valid phone number';
          }
          return null;
        };
      case FieldType.password:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        };
      case FieldType.confirmPassword:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Confirm your password';
          }
          return null;
        };
      case FieldType.reset:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email address';
          }
          return null;
        };
      case FieldType.text:
        return (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        };
      case FieldType.optional:
        return (value) => null;
      default:
        return (value) => null;
    }
  }
}