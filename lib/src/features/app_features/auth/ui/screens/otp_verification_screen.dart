import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/app_screen_template.dart';
import 'package:elfulk/src/core/widgets/custom_pin_keypad.dart';
import 'package:elfulk/src/core/widgets/footer_text.dart';
import 'package:elfulk/src/core/widgets/pin_display_row.dart';
import 'package:elfulk/src/core/widgets/primary_button.dart';

enum OtpVerificationType {
  emailVerification,
  passwordReset,
}

class OtpVerificationScreen extends StatefulWidget {
  final OtpVerificationType type;

  const OtpVerificationScreen({super.key, required this.type});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';

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

  void _onClearPress() {
    setState(() {
      _otpCode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEmailActive =
        widget.type == OtpVerificationType.emailVerification;

    final String titleText = isEmailActive
        ? 'تفقد بريدك الالكتروني.'
        : 'أرسلنا لك رمز التحقق.';
    final String buttonText = isEmailActive
        ? 'تأكيد الرمز'
        : 'اعادة تعين كلمة مرور جديدة';

    return AppScreenTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: context.spacing.sm.h),
          Text(
            'ادخل الرمز المكون من 5 أرقام الذي أرسلناه.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: context.spacing.lg.h),

          PinDisplayRow(value: _otpCode, length: 5),
          SizedBox(height: context.spacing.md.h),

          FooterText(
            countdownSeconds: 63,
            questionText: 'اعادة ارسال الرمز بعد ',
            actionText: "ارسلي",
            onActionTap: () {
              // Resend code logic
            },
          ),

          SizedBox(height: context.spacing.md.h),

          PrimaryButton(
            text: buttonText,
            icon: SvgPicture.asset(
              isEmailActive
                  ? AssetsPathHelper.verify
                  : AssetsPathHelper.reset,
            ),
            onPressed: _otpCode.length == 5
                ? () {
                    // Verify logic
                  }
                : null,
          ),

          SizedBox(height: context.spacing.xl.h),
          CustomPinKeypad(
            onDigitPressed: _onDigitPress,
            onBackspacePressed: _onBackspacePress,
            onClearPressed: _onClearPress,
          ),
        ],
      ),
    );
  }
}
