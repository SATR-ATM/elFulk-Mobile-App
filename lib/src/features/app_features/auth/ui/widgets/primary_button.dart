import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool rtlIcon; // لتحديد اتجاه الأيقونة (يمين أو يسار)

  const PrimaryButton({
    this.rtlIcon = false, // القيمة الافتراضية هي false (الأيقونة على اليسار)
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F857D),
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) ...[
              if (rtlIcon) ...[
                Transform.flip(
                  flipX: true, // قلب أفقي
                  child: Icon(icon, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 8.w),
              ] else ...[
                SizedBox(width: 8.w),
                Icon(icon, color: Colors.white, size: 20.sp),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
