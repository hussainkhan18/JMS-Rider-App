import 'package:flutter/material.dart';
import '../helper/style.dart' as style; 

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator; // 👈 Validator added

  const PasswordField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator, 
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscure = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      validator: widget.validator, // 👈 validator here
      decoration: style
          .inputTextFieldDecoration(
            widget.label,
            Icons.lock_outline,
            suffixIcn: _isObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          )
          .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
    );
  }
}
