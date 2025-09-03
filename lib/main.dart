// 役割: アプリのエントリポイント。環境初期化→DI(Riverpod)→AppRoot(MaterialApp)の起動。
// runApp前にFlutterバインディングを初期化し、副作用の順序を安定化。
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_root.dart';
import 'firebase_options.dart';

/// アプリのエントリポイント。
/// Env/プラグイン初期化 → DIルート(ProviderScope) → AppRoot起動 の順で実行。
Future<void> main() async {
  // アプリ起動前の初期化。プラグイン利用やFirebase初期化のために必須。
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseの初期化。
  // flutterfire configure により生成された firebase_options.dart を使用し、
  // 端末プラットフォームに応じた設定で初期化する。
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Riverpodのルート（ProviderScope）配下にMaterialApp(AppRoot)を配置して起動。
  runApp(const ProviderScope(child: AppRoot()));
}
