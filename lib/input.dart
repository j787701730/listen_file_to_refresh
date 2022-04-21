import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final String? value;
  final String? hintText;
  final int? maxLines;
  final int? maxLength;

  const Input({
    Key? key,
    required this.onChanged,
    this.onSubmitted,
    this.value,
    this.maxLines,
    this.maxLength,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _style = const TextStyle(fontSize: 14);
    double height = 30;
    var textPainter = TextPainter(
      text: TextSpan(
        text: '道',
        style: _style,
      ),
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )..layout();
    return SizedBox(
      height: maxLines == null || maxLines == 1 ? height : null,
      child: TextField(
        controller: TextEditingController(text: value ?? ''),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFdddddd), width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF409EFF), width: 1),
          ),
          contentPadding: maxLines == null || maxLines == 1
              ? EdgeInsets.symmetric(horizontal: 8, vertical: (height - textPainter.height) / 2)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          counterText: '',
          hintText: hintText,
        ),
        style: _style,
        maxLength: maxLength,
        maxLines: maxLines,
      ),
    );
  }
}