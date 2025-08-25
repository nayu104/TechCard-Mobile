// 目的: アプリのビルドが成立する回帰テスト（起動時例外の早期検出）。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intermediate/app/app_root.dart';

void main() {
  // Given: ProviderScope配下でAppRootを起動
  // When: pumpWidgetでビルド
  // Then: MaterialAppが1つ存在
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
