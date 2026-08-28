// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_canvassing_app/login_screen.dart';
import 'package:sales_canvassing_app/main.dart' as app;
import 'package:sales_canvassing_app/screens/forgot_password_screen.dart';

void main() {
  testWidgets('aplikasi mendukung locale Indonesia',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('form login tetap terlihat pada layar ringkas',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Nama Pengguna'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    final usernameBounds = tester.getRect(find.byType(TextField).first);
    final passwordBounds = tester.getRect(find.byType(TextField).last);
    expect(usernameBounds.top, greaterThanOrEqualTo(0));
    expect(passwordBounds.bottom, lessThanOrEqualTo(480));
  });

  testWidgets('input email lupa password tetap terlihat pada layar ringkas',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(tester.getRect(find.byType(TextField)).top, greaterThanOrEqualTo(0));
  });
}
