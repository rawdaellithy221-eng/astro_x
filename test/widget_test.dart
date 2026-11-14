import 'package:astrox/features/registration/view/registration_screen.dart';
import 'package:astrox/features/splash/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash opens registration after five seconds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Registration'), findsNothing);
    await tester.pump(const Duration(seconds: 4, milliseconds: 900));
    expect(find.text('Registration'), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(RegistrationScreen), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
