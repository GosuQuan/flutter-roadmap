import 'package:flutter/material.dart';

class TodoStyles {
  static const double defaultPadding = 16.0;
  static const double borderRadius = 15.0;
  static const double inputBorderRadius = 30.0;

  static BoxDecoration get containerDecoration => BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      );

  static BoxDecoration get buttonDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigoAccent, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(inputBorderRadius),
      );

  static InputDecoration get inputDecoration => InputDecoration(
        hintText: '添加新的待办事项...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      );

  static ButtonStyle get addButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
        ),
      );
}
