import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 編集中に選択されたスキルの一時状態を保持するProvider。
final AutoDisposeStateProvider<List<String>> editingSkillsProvider =
    StateProvider.autoDispose<List<String>>((ref) => <String>[]);
