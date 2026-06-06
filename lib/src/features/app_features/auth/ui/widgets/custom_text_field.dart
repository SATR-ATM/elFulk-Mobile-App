import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool hasError; // لاظهار الإطار الأحمر عند الخطأ

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.hasError = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscured : false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
        prefixIcon: Icon(widget.prefixIcon, color: Colors.grey[500], size: 20.sp),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[500],
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        // الإطار في الوضع العادي
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: widget.hasError ? Colors.red : Colors.grey.shade300,
          ),
        ),
        // الإطار عند التحديد (Focus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: widget.hasError ? Colors.red : const Color(0xFF2F857D),
          ),
        ),
      ),
    );
  }
}