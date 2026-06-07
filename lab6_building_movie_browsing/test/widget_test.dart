import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Đảm bảo tên package khớp với tên project của bạn
import 'package:lab6_building_movie_browsing/main.dart'; 

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Gọi đúng tên class từ file main.dart
    await tester.pumpWidget(const ResponsiveMovieApp());

    // Kiểm tra xem tiêu đề "Find a Movie" có xuất hiện trên màn hình không
    expect(find.text('Find a Movie'), findsOneWidget);
  });
}