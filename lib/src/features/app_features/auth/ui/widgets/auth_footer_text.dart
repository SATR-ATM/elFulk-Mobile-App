import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthFooterText extends StatefulWidget {
  final String questionText;
  final String actionText; // النص الذي سيظهر كحالة افتراضية أو بعد انتهاء العداد
  final VoidCallback onActionTap;
  final int? countdownSeconds; // إذا تم تمرير قيمة هنا (مثال: 60)، سيتحول إلى عداد تلقائياً

  const AuthFooterText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onActionTap,
    this.countdownSeconds,
  });

  @override
  State<AuthFooterText> createState() => _AuthFooterTextState();
}

class _AuthFooterTextState extends State<AuthFooterText> {
  Timer? _timer;
  int _currentSeconds = 0;
  bool _isCountdownActive = false;

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير عداد تنازلي، نقوم بتفعيله فوراً عند بناء الـ Widget
    if (widget.countdownSeconds != null && widget.countdownSeconds! > 0) {
      _startCountdown(widget.countdownSeconds!);
    }
  }

  void _startCountdown(int seconds) {
    setState(() {
      _currentSeconds = seconds;
      _isCountdownActive = true;
    });

    _timer?.cancel(); // إلغاء أي مؤقت قديم لتفادي تسريب الذاكرة (Memory Leak)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds == 1) {
        setState(() {
          _isCountdownActive = false;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _currentSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // تنظيف الـ Timer فوراً عند الخروج من الشاشة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد النص المعروض بناءً على حالة العداد
    // إذا كان العداد نشطاً يعرض الوقت المتبقي بصيغة (0:45 مثلاً)، وإلا يعرض النص الثابت الافتراضي
    final String displayActionText = _isCountdownActive
        ? '${(_currentSeconds ~/ 60)}:${(_currentSeconds % 60).toString().padLeft(2, '0')}'
        : widget.actionText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.questionText,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: _isCountdownActive
              ? null // تجميد وتعطيل الضغط تماماً أثناء عمل العداد التنازلي
              : () {
                  widget.onActionTap();
                  // إذا أردت إعادة تشغيل العداد تلقائياً فور الضغط على "إعادة الإرسال"
                  if (widget.countdownSeconds != null) {
                    _startCountdown(widget.countdownSeconds!);
                  }
                },
          child: Text(
            displayActionText,
            style: TextStyle(
              fontSize: 13.sp,
              // تغيير اللون إلى الرمادي ليعطي انطباعاً بصرياً بأنه غير قابل للضغط (Disabled) أثناء العد
              color: _isCountdownActive ? Colors.grey[400] : const Color(0xFF2F857D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}