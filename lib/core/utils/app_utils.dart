import 'package:arbor/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';

AuthAction? authAction;

class AppUtils {
  static showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1000),
        backgroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.all(
          10,
        ), // Inner padding for SnackBar content.
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
