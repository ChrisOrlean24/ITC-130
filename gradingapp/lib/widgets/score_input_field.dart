import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ScoreInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const ScoreInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '0',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
        ),
        counterText: '',
      ),
      maxLength: 4,
    );
  }
}
