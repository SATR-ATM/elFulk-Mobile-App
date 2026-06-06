import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_screen_template.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_footer_text.dart';
import '../widgets/divider_with_text.dart';
import '../widgets/social_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // متغير للتحكم في حالة الموافقة على الشروط
  bool _isTermsAccepted = true;

  @override
  Widget build(BuildContext context) {
    return AuthScreenTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // النصوص العلوية
          Text(
            'ابدأ رحلتك مع الفلك.',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10363A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'أنشئ حسابك في دقيقة وامنح طفلك فضاءً رقميًا آمنًا.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),

          // حقل الاسم الكامل
          const CustomTextField(
            hintText: 'الاسم كامل',
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: 14.h),

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
          SizedBox(height: 16.h),

          // زر الموافقة على الشروط والأحكام
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isTermsAccepted = !_isTermsAccepted;
                  });
                },
                child: Icon(
                  _isTermsAccepted ? Icons.check_circle : Icons.circle_outlined,
                  color: const Color(0xFF2F857D),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'أوافق على ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF10363A),
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'شروط الاستخدام وسياسة الخصوصية.',
                        style: const TextStyle(
                          color: Color(0xFF2F857D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // زر إنشاء الحساب من الـ Widgets
          PrimaryButton(
            text: 'انشاء حساب',
            icon: Icons.login_outlined, // استخدمنا أيقونة مشابهة للتصميم
            onPressed: _isTermsAccepted
                ? () {
                    // منطق التسجيل
                  }
                : null, // تعطيل الزر إذا لم تتم الموافقة
          ),
          
          SizedBox(height: 32.h),

          // النص السفلي للانتقال لتسجيل الدخول
          AuthFooterText(
            questionText: 'لديك حساب بالفعل؟ ',
            actionText: 'سجل الدخول',
            onActionTap: () => context.pop(), // الرجوع لشاشة الدخول
          ),

          SizedBox(height: 16.h),

          // الفاصل المعنون
          const DividerWithText(text: 'او عن طريق'),
          
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
                  onPressed: () {
                    // منطق آبل
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
                    // منطق جوجل
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
