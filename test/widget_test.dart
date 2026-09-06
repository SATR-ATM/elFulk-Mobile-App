import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elfulk/src/core/widgets/custom_pin_keypad.dart';
import 'package:elfulk/src/core/widgets/pin_display_row.dart';
import 'package:elfulk/src/features/app_features/auth/ui/screens/otp_verification_screen.dart';

void main() {
  testWidgets('otp screen renders reusable pin widgets and updates input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => const MaterialApp(
          home: OtpVerificationScreen(
            type: OtpVerificationType.emailVerification,
          ),
        ),
      ),
    );

    expect(find.byType(PinDisplayRow), findsOneWidget);
    expect(find.byType(CustomPinKeypad), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('otp-keypad-1')));
    await tester.tap(find.byKey(const ValueKey('otp-keypad-2')));
    await tester.tap(find.byKey(const ValueKey('otp-keypad-3')));
    await tester.pump();

    expect(
      tester.widget<PinDisplayRow>(find.byType(PinDisplayRow)).value,
      '123',
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('otp-keypad-delete')));
    await tester.pump();

    expect(
      tester.widget<PinDisplayRow>(find.byType(PinDisplayRow)).value,
      '12',
    );

    await tester.tap(find.byKey(const ValueKey('otp-keypad-clear')));
    await tester.pump();

    expect(
      tester.widget<PinDisplayRow>(find.byType(PinDisplayRow)).value,
      '',
    );
  });
}
