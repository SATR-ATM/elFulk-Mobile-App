import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elfulk/src/core/helpers/helpers.dart';

class PinDisplayRow extends StatelessWidget {
  final String value;
  final int length;

  const PinDisplayRow({
    super.key,
    required this.value,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      textDirection: TextDirection.ltr,
      children: List.generate(length, (index) {
        final bool isFilled = index < value.length;
        final String digit = isFilled ? value[index] : '';

        return Container(
          width: 50.w,
          height: 55.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(context.radius.lg.r),
            border: Border.all(
              color: isFilled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Text(
            digit,
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ) ??
                TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
          ),
        );
      }),
    );
  }
}
