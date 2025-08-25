// 役割: アプリのエントリポイント。環境初期化→DI(Riverpod)→AppRoot(MaterialApp)の起動。
// runApp前にFlutterバインディングを初期化し、副作用の順序を安定化。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_root.dart';

/// アプリのエントリポイント。
/// Env/プラグイン初期化 → DIルート(ProviderScope) → AppRoot起動 の順で実行。
Future<void> main() async {
  // Env読込やプラグイン初期化が必要な場合に備え、先に初期化。
  WidgetsFlutterBinding.ensureInitialized();
  // DIのルート（ProviderScope）を用意してからMaterialAppを起動。
  runApp(const ProviderScope(child: AppRoot()));
}
