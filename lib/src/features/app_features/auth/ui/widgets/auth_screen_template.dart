import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthScreenTemplate extends StatelessWidget {
  final Widget child;

  const AuthScreenTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // نتحقق إذا كان الكيبورد مفتوحاً أم لا
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3EC),
        // نغيرها إلى true ليتعامل النظام مع الكيبورد بسلاسة مرنة
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false, 
                child: Column(
                  children: [
                    // القسم العلوي (الشعار)
                    // إذا انفتح الكيبورد، يصغر حجم مساحة الشعار تلقائياً ليترك مساحة للمحتوى
                    Flexible(
                      flex: isKeyboardOpen ? 0 : 1,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: isKeyboardOpen ? 10.h : 20.h),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: isKeyboardOpen ? 60.h : 110.h, // يصغر الشعار عند الكتابة
                          child: Image.asset(
                            'assets/images/elFulk.png',
                            width: 140.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // القسم السفلي (المربع الأبيض)
                    // تم إزالة Expanded ليتمدد المحتوى بشكل طبيعي ويتنفس
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.r),
                          topRight: Radius.circular(32.r),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 28.h,
                        bottom: 24.h, // جعلناه ثابتاً لأن الكيبورد يتم معالجته عبر Scaffold
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}