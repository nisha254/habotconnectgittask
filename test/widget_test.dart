// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app/app.dart';

void main() {
  testWidgets('DigiVir app renders LSA Verification screen labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DigiVirApp());
    await tester.pump();

    // Branding visible in header
    expect(find.text('DigiVir'), findsOneWidget);

    // Core form labels must be present somewhere in the widget tree
    // (findsWidgets = at least one, avoids failures on duplicate text)
    expect(find.text('Full Name'), findsWidgets);
    expect(find.text('Email Address'), findsWidgets);
    expect(find.text('Phone Number'), findsWidgets);
    expect(find.text('Profile Category'), findsWidgets);
  });

  testWidgets('Submit button triggers inline validation on empty form',
      (WidgetTester tester) async {
    // Set a phone-like viewport so the full form fits / can be scrolled
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DigiVirApp());
    await tester.pumpAndSettle();

    // Scroll the Scrollable until the submit button is visible
    await tester.scrollUntilVisible(
      find.text('Submit Verification'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Tap submit with all fields empty
    await tester.tap(find.text('Submit Verification'));
    await tester.pump();

    // Inline validation errors must appear
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
  });
}
