import 'package:flutter/widgets.dart';

// 入力: v=対象値, min=下限, max=上限
// 返り値: min ≤ v ≤ max を満たす値
double clamp(double v, double min, double max) {
  // v が下限より小さければ、下限に丸める
  if (v < min) {
    return min;
  }
  // v が上限より大きければ、上限に丸める
  if (v > max) {
    return max;
  }
  // それ以外（範囲内）は、そのまま返す
  return v;
}

double responsiveFontSize(
  BuildContext context, //  第1引数 Flutter のウィジェットツリーの情報を持ってるオブジェクト。
  double baseFontSize, {
  //  第2引数
  double min = 12.0,
  double max = 20.0,
  double designWidth = 390.0,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final screenScale = width / designWidth; // 幅だけでスケール
  final v = baseFontSize * screenScale;
  // 手書き clamp（double で返る）
  final clamped = clamp(v, min, max);
  return clamped;
}
