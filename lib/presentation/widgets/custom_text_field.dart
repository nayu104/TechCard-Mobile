import 'package:flutter/material.dart';

// 緑系デザインのTextFieldをカスタムしたウィジェット
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText, // ラベル（必須）
    this.hintText, // 入力欄内の説明文
    this.labelStyle, // ラベルの文字スタイル
    this.controller, // 入力値を管理するコントローラ
    this.borderSide, // 通常時の下線スタイル
    this.focusedBorderSide, // フォーカス時の下線スタイル
    this.maxLines = 1, // 入力可能な最大行数（デフォルト1）
    this.maxLength, // ===== ここから追加 =====
    this.keyboardType, // キーボードの種類（文字/数値など）
    this.obscureText = false, // パスワード入力のように隠すか
    this.onChanged, // 入力変化時のコールバック
    this.validator, // フォームバリデーション関数
    this.prefixIcon, // 入力欄の前に表示するアイコン
    this.suffixIcon, // 入力欄の後に表示するアイコン
    this.onSubmitted, // 送信時のコールバック
  });

  final String? labelText; // ラベル文言
  final String? hintText; // 入力補助のヒントテキスト
  final TextStyle? labelStyle; // ラベル文字のスタイル（未指定なら半透明ホワイト）
  final BorderSide? borderSide; // 通常時の下線色設定
  final TextEditingController? controller; // 入力内容を保持・操作するコントローラ
  final BorderSide? focusedBorderSide; // フォーカス時の下線色設定
  final int? maxLines; // 最大行数
  final int? maxLength; // ===== ここから追加 =====
  final TextInputType? keyboardType; // 入力種別（例：email, number）
  final bool obscureText; // 入力内容を非表示にするか
  final void Function(String)? onChanged; // 入力文字が変化したときに呼ばれる
  final String? Function(String?)? validator; // 入力内容を検証する関数
  final Widget? prefixIcon; // アイコン（前）
  final Widget? suffixIcon; // アイコン（後）
  final void Function(String)? onSubmitted; // 送信時の処理

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 現在のテーマを取得
    final onSurface = theme.colorScheme.onSurface; // テーマのonSurface色を参照

    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10), // 左右余白
      child: TextFormField(
        controller: controller, // 入力内容の管理
        validator: validator, // 入力値の検証
        maxLines: maxLines, // 最大行数を反映
        maxLength: maxLength, // ===== ここから追加 =====
        keyboardType: keyboardType, // 入力種別を反映
        obscureText: obscureText, // パスワード入力対応
        onChanged: onChanged, // 入力時のコールバック
        onFieldSubmitted: onSubmitted, // 送信時のコールバック
        style: TextStyle(color: onSurface), // 入力文字の色
        decoration: InputDecoration(
          prefixIcon: prefixIcon, // アイコン（前）を追加
          suffixIcon: suffixIcon, // アイコン（後）を追加
          enabledBorder: UnderlineInputBorder(
            // 通常時の下線
            borderSide: borderSide ??
                BorderSide(
                  color: onSurface.withValues(alpha: 0.5), // 半透明のonSurface色
                ),
          ),
          labelText: labelText, // ラベルを表示
          hintText: hintText, // ヒントを表示
          labelStyle: labelStyle ?? // ラベル文字のスタイル
              TextStyle(
                color: onSurface.withValues(alpha: 0.5), // 半透明のonSurface色
              ),
          hintStyle: TextStyle(
            // ヒント文字のスタイル
            color: onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always, // 常にラベルを上に表示
          focusedBorder: UnderlineInputBorder(
            // フォーカス時の下線
            borderSide: focusedBorderSide ??
                const BorderSide(
                  color: Color.fromARGB(255, 64, 163, 255), // デフォルトは緑色
                ),
          ),
        ),
        cursorColor: const Color.fromARGB(255, 64, 163, 255), // カーソルの色を緑に
      ),
    );
  }
}
