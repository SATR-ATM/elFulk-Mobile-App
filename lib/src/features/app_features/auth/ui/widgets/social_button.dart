import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String type;
  final VoidCallback onPressed;
  final double? iconSize; // وحدنا مسمى الحجم للأيقونات

  const SocialButton({
    super.key,
    required this.icon,
    required this.type,
    required this.onPressed,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xFF55B5A6);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // تحديد ارتفاع ثابت وموحد للزرين لمنع أي تلاعب بسبب المحتوى
        minimumSize: Size(double.infinity, 48.h), 
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: const BorderSide(color: buttonColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      // الآن كلا الزرين يستخدمان نفس نوع الـ Widget (Icon) لتتطابق الأبعاد تماماً
      child: Icon(
        icon,
        color: buttonColor,
        size: iconSize ?? 22.sp,
      ),
    );
  }
}