import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 現在のボトムタブインデックス（0:MyCard/1:Contacts/2:Exchange/3:Settings）。
final bottomNavProvider = StateProvider<int>((ref) => 0);

/// マイ名刺の編集モードON/OFF。
final isEditingProvider = StateProvider<bool>((ref) => false);

/// 現在のThemeMode。永続ストレージと同期。
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
