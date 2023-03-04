import 'package:flutter/material.dart';

class UrlInputTextField extends StatefulWidget {
  const UrlInputTextField({super.key, required this.textEditingController});

  final TextEditingController textEditingController;

  @override
  State<UrlInputTextField> createState() => _UrlInputTextFieldState();
}

class _UrlInputTextFieldState extends State<UrlInputTextField> {
  String? _error;

  void onTextChanged(String? text) {
    setState(() {
      if (Uri.parse(text ?? "").host.isNotEmpty) {
        _error = null;
      } else {
        _error = "Invalid url";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textEditingController,
      maxLines: 1,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: const Text("Enter Url"),
        errorText: _error,
      ),
      onChanged: onTextChanged,
    );
  }
}
