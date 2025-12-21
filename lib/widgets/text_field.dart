import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onSuffixPressed;
  final double borderRadius;
  final Color fillColor;
  final double? width;
  final double? height;
  final bool fixedHeight;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSuffixPressed,
    this.borderRadius = 7,
    this.fillColor = const Color(0xFFF5F5F5),
    this.width,
    this.height,
    this.fixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: fixedHeight ? (height ?? 20.0) : null,
      margin: const EdgeInsets.only(bottom: 7),
      child: IntrinsicHeight(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? fillColor : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: enabled ? Colors.black87 : Colors.grey,
            ),
            suffixIcon: suffixIcon != null
              ? IconButton(
                icon: Icon(
                  suffixIcon,
                    color: Colors.grey,
                  ),
                  onPressed: onSuffixPressed,
                )
              : null,
            isCollapsed: fixedHeight,
            errorStyle: fixedHeight
                ? const TextStyle(
                    fontSize: 12,
                    height: 1,
                  )
                : null,
            errorMaxLines: 2,
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(158, 158, 158, 1),
          ),
        ),
      ),
    );
  }
}