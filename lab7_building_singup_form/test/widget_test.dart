import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import đúng package Lab 7 của bạn
import 'package:lab7_building_singup_form/main.dart';

void main() {
  testWidgets('Signup form loads smoke test', (WidgetTester tester) async {
    // Gọi đúng tên class từ file main.dart của Lab 7
    await tester.pumpWidget(const SignupApp());

    // Kiểm tra xem tiêu đề 'Create Account' có xuất hiện trên màn hình không
    expect(find.text('Create Account'), findsOneWidget);
  });
}