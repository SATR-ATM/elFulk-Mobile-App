import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_screen_template.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_footer_text.dart';
import '../widgets/divider_with_text.dart';
import '../widgets/social_button.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10363A),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          
          // حقل إدخال البريد الإلكتروني
          const CustomTextField(
            hintText: 'البريد الإلكتروني',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24.h),
          
          // زر الإرسال الرئيسي
          PrimaryButton(
            text: 'ارسال رمز التحقق',
            rtlIcon: true, // لجعل الأيقونة تظهر على اليمين
            icon: Icons.send_rounded,
            onPressed: () {
              // إضافة منطق إرسال الرمز هنا
            },
          ),
          SizedBox(height: 24.h),
          
          // نص الرجوع لتسجيل الدخول
          AuthFooterText(
            questionText: 'تذكرت كلمة المرور الخاصة بك؟ ',
            actionText: 'سجل الدخول',
            onActionTap: () => context.pop(),
          ),
          SizedBox(height: 32.h),
          
          // فاصل الدخول بطرق أخرى
          const DividerWithText(text: 'او عن طريق'),
          SizedBox(height: 24.h),
          
          // أزرار آبل وجوجل
          Row(
            children: [
              Expanded(
                child: SocialButton(
                  icon: Icons.apple,
                  iconSize: 22.sp,
                  type: 'Apple',
                    // appleIconSize: 22.sp,
                  onPressed: () {
                    // منطق تسجيل الدخول عبر آبل
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SocialButton(
                  iconSize: 30.sp,
                  icon: Icons.g_mobiledata_rounded,
                  type: 'Google',
                  // googleTextSize: 20.sp,
                  onPressed: () {
                    // منطق تسجيل الدخول عبر جوجل
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

