import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
// تأكد من صحة مسار الاستيراد بناءً على مجلد مشروعك
import 'package:elfulk/src/features/app_features/auth/ui/widgets/auth_screen_template.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/custom_text_field.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/primary_button.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/divider_with_text.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/auth_footer_text.dart';
import 'package:elfulk/src/features/app_features/auth/ui/widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // النصوص العلوية
          Text(
            'مرحبًا بك في فلك.',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10363A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'سجّل دخولك للوصول إلى لوحة التحكم ومتابعة أطفالك',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),

          // حقل البريد الإلكتروني
          const CustomTextField(
            hintText: 'البريد الإلكتروني',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 14.h),

          // حقل كلمة المرور
          const CustomTextField(
            hintText: 'كلمة المرور',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
          ),
          
          SizedBox(height: 4.h),

          // زر نسيت كلمة المرور؟
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push(Routes.forgetPasswordScreen),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF4DB09E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // زر تسجيل الدخول
          PrimaryButton(
            text: 'تسجيل الدخول',
            icon: Icons.login_outlined,
            onPressed: () {
              // Login logic
            },
          ),
          
          SizedBox(height: 32.h),

          // النص السفلي لإنشاء حساب
          AuthFooterText(
            questionText: 'ليس لديك حساب؟ ',
            actionText: 'أنشئ واحدًا الآن',
            onActionTap: () => context.push(Routes.registerScreen),
          ),

          SizedBox(height: 16.h),

          // الفاصل المعنون
          const DividerWithText(text: 'أو عن طريق'),
          
          SizedBox(height: 16.h),

          // أزرار التسجيل عبر آبل وجوجل
          Row(
            children: [
              Expanded(
                child: SocialButton(
                  iconSize: 22.sp,
                  icon: Icons.apple,
                  type: 'Apple',
                  // appleIconSize: 22.sp,
                  onPressed: () {}, // إضافة منطق تسجيل دخول آبل
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SocialButton(
                  iconSize: 30.sp,
                  icon: Icons.g_mobiledata_rounded,
                  type: 'Google',
                  // googleTextSize: 20.sp,
                  onPressed: () {}, // إضافة منطق تسجيل دخول جوجل
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
