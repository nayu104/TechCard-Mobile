import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← 追加

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.labelStyle,
    this.controller,
    this.borderSide,
    this.focusedBorderSide,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSubmitted,
    this.inputFormatters, // ← 追加
    this.textInputAction, // ← 追加
  });

  final String? labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final BorderSide? borderSide;
  final TextEditingController? controller;
  final BorderSide? focusedBorderSide;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool obscureText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onSubmitted;

  // ← 追加: フィールド定義
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        inputFormatters: inputFormatters, // ← 追加
        textInputAction: textInputAction, // ← 追加
        style: TextStyle(color: onSurface),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          enabledBorder: UnderlineInputBorder(
            borderSide: borderSide ??
                BorderSide(color: onSurface.withValues(alpha: 0.5)),
          ),
          labelText: labelText,
          hintText: hintText,
          labelStyle:
              labelStyle ?? TextStyle(color: onSurface.withValues(alpha: 0.5)),
          hintStyle: TextStyle(
            color: onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          floatingLabelBehavior: hintText == null
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.always,
          focusedBorder: UnderlineInputBorder(
            borderSide:
                focusedBorderSide ?? BorderSide(color: primary, width: 2),
          ),
        ),
        cursorColor: primary,
      ),
    );
  }
}
