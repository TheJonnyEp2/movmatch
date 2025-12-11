// lib/widgets/gradient_button.dart
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;


  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(
            colors: [Color.fromRGBO(245, 73, 245, 1), Color.fromRGBO(125, 40, 229, 1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Onest',
              fontSize: 20, 
              fontWeight: FontWeight.w600,
              color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}