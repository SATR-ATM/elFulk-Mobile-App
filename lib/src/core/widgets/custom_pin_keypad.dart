import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elfulk/src/core/helpers/helpers.dart';

class CustomPinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onClearPressed;

  const CustomPinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final rows = [
      ['3', '2', '1'],
      ['6', '5', '4'],
      ['9', '8', '7'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsets.only(bottom: context.spacing.sm12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row
                  .map(
                    (digit) => _KeypadButton(
                      key: ValueKey('otp-keypad-$digit'),
                      value: digit,
                      onPressed: () => onDigitPressed(digit),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ) ??
                          TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _KeypadButton(
              key: const ValueKey('otp-keypad-delete'),
              onPressed: onBackspacePressed,
              icon: Icons.backspace_outlined,
              flipIcon: true,
              iconColor: theme.colorScheme.onSurface,
            ),
            _KeypadButton(
              key: const ValueKey('otp-keypad-0'),
              value: '0',
              onPressed: () => onDigitPressed('0'),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
            _KeypadButton(
              key: const ValueKey('otp-keypad-clear'),
              onPressed: onClearPressed,
              icon: Icons.refresh,
              iconColor: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? value;
  final IconData? icon;
  final bool flipIcon;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final Color? iconColor;

  const _KeypadButton({
    super.key,
    this.value,
    this.icon,
    this.flipIcon = false,
    required this.onPressed,
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget? iconWidget;
    if (icon != null) {
      final baseIcon = Icon(icon, size: 24.sp, color: iconColor);
      iconWidget = flipIcon
          ? Transform.flip(
              flipX: true,
              child: baseIcon,
            )
          : baseIcon;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100.w,
        height: 42.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(context.radius.xl.r),
        ),
        child: Center(
          child: value != null
              ? Text(value!, style: textStyle)
              : iconWidget,
        ),
      ),
    );
  }
}
