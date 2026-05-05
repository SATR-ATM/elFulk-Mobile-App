import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:elfulk/src/core/config/routing/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // للتحكم في إظهار أو إخفاء كلمة المرور
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Section 1: Logo & Background (Top Half)
                  Container(
                    height: 250.h,
                    color: const Color(0xFFF7F3EB),
                    child: Center(
                      child: Image.asset(
                        'assets/images/elFulk.png',
                        height: 100.h,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 80.h),
                      ),
                    ),
                  ),

                  // Section 2: Form 
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      transform: Matrix4.translationValues(0.0, -30.h, 0.0),
                      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                            
                            _buildTextField(
                              hint: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                            ),
                            SizedBox(height: 14.h),
                            
                            // حقل كلمة المرور مع زر العين
                            _buildTextField(
                              hint: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            
                            SizedBox(height: 4.h),
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
                            SizedBox(height: 20.h),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Login logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF55B5A6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
                                  ],
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "ليس لديك حساب؟ ",
                                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: () => context.push(Routes.registerScreen),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'أنشئ واحدًا الآن',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF4DB09E),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey[300])),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    'أو عن طريق',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey[300])),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            
                            Row(
                              children: [
                                Expanded(child: _buildSocialButton(Icons.apple, 'Apple', appleIconSize: 22.sp)),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildSocialButton(
                                    Icons.g_mobiledata_rounded, 
                                    'Google', 
                                    googleTextSize: 20.sp 
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        // إذا كان الحقل للباسورد نربطه بمتغير الإخفاء، أما بقية الحقول فلا تُخفى أبداً (false)
        obscureText: isPassword ? _isPasswordHidden : false,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 20.sp), 
          
          // 👇 إضافة أيقونة العين إذا كان الحقل لكلمة المرور فقط
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[500],
                    size: 20.sp,
                  ),
                  onPressed: () {
                    // تغيير حالة العرض
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                )
              : null,

          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w, 
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String type, {double? appleIconSize, double? googleTextSize}) {
    const Color buttonColor = Color(0xFF55B5A6); 

    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: const BorderSide(color: buttonColor, width: 1), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r), 
        ),
      ),
      child: type == 'Google' 
        ? Text(
            'G',
            style: TextStyle(
              fontSize: googleTextSize ?? 20.sp,
              fontWeight: FontWeight.bold,
              color: buttonColor,
            ),
          )
        : Icon(
            icon,
            color: buttonColor,
            size: appleIconSize ?? 22.sp,
          ),
    );
  }
}
