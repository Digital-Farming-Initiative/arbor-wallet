import 'package:flutter/material.dart';

class CustomTextEditingController
    extends TextEditingController {
  CustomTextEditingController({String? text})
      : super(text: text);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: value.selection,
      composing: TextRange.empty,
    );
  }
}