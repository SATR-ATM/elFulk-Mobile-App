import 'package:elfulk/src/features/app_features/auth/ui/widgets/auth_footer_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// تأكد من صحة المسار حسب مجلد مشروعك
import 'package:elfulk/src/features/app_features/auth/ui/widgets/auth_screen_template.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/primary_button.dart';

// 1. تعريف الـ Enum لتحديد حالة الشاشة
enum OtpVerificationType {
  emailVerification, // تفقد بريدك الالكتروني
  passwordReset, // أرسلنا لك رمز التحقق
}

class OtpVerificationScreen extends StatefulWidget {
  final OtpVerificationType type;

  const OtpVerificationScreen({super.key, required this.type});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = ''; // الكود المدخل من 5 أرقام

  void _onDigitPress(String digit) {
    if (_otpCode.length < 5) {
      setState(() {
        _otpCode += digit;
      });
    }
  }

  void _onBackspacePress() {
    if (_otpCode.isNotEmpty) {
      setState(() {
        _otpCode = _otpCode.substring(0, _otpCode.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmailActive = widget.type == OtpVerificationType.emailVerification;

    final String titleText = isEmailActive
        ? 'تفقد بريدك الالكتروني.'
        : 'أرسلنا لك رمز التحقق.';
    final String buttonText = isEmailActive
        ? 'تأكيد الرمز'
        : 'اعادة تعين كلمة مرور جديدة';
    final IconData buttonIcon = isEmailActive
        ? Icons.verified
        : Icons.auto_fix_high;

    // استخدام القالب الأساسي للشاشات
    return AuthScreenTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10363A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ادخل الرمز المكون من 5 أرقام الذي أرسلناه.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 24.h),

          // مربعات إدخال الرمز (5 خانات)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            textDirection: TextDirection.ltr, // لضمان ترتيب الخانات من اليسار لليمين
            children: List.generate(5, (index) {
              bool isFilled = index < _otpCode.length;

              return Container(
                width: 50.w,
                height: 55.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isFilled
                        ? const Color(0xFF2F857D)
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  isFilled ? _otpCode[index] : '',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F857D),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // المؤقت
          AuthFooterText(
            countdownSeconds: 63,
            questionText: 'اعادة ارسال الرمز بعد ',
            actionText: "ارسلي",
            onActionTap: () {
              // منطق إعادة إرسال الرمز
            },
          ),
      
          SizedBox(height: 16.h),

          // الزر الرئيسي من مجلد الـ Widgets
          PrimaryButton(
            text: buttonText,
            icon: buttonIcon,
            // الزر سيكون Active فقط إذا تم كتابة الرمز كاملاً
            onPressed: _otpCode.length == 5
                ? () {
                    // منطق التحقق والانتقال
                  }
                : null,
          ),

          SizedBox(height: 32.h), // مساحة بدلاً من Spacer بسبب الـ ScrollView
          // لوحة الأرقام
          _buildCustomKeypad(),
        ],
      ),
    );
  }

  Widget _buildCustomKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        SizedBox(height: 12.h),
        _buildKeypadRow(['4', '5', '6']),
        SizedBox(height: 12.h),
        _buildKeypadRow(['7', '8', '9']),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildKeypadButton(
              icon: Icons.backspace_outlined,
              isBackspace: true,
            ),
            _buildKeypadButton(text: '0'),
            _buildKeypadButton(icon: Icons.refresh),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((digit) => _buildKeypadButton(text: digit)).toList(),
    );
  }

  Widget _buildKeypadButton({
    String? text,
    IconData? icon,
    bool isBackspace = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (text != null) {
          _onDigitPress(text);
        } else if (isBackspace) {
          _onBackspacePress();
        } else {
          setState(() {
            _otpCode = '';
          });
        }
      },
      child: Container(
        width: 100.w,
        height: 42.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: text != null
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10363A),
                  ),
                )
              : Icon(icon, size: 24.sp, color: const Color(0xFF10363A)),
        ),
      ),
    );
  }
}
