import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Rive を用いた汎用ローダー
/// - assetPath: 例 'assets/sample_loaders.riv'
/// - animationName: 例 'Animation 1'
class RiveLoader extends StatelessWidget {
  const RiveLoader(
      {super.key,
      required this.assetPath,
      required this.animationName,
      this.size = 240});
  final String assetPath;
  final String animationName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RiveAnimation.asset(
        assetPath,
        fit: BoxFit.contain,
        animations: [animationName],
      ),
    );
  }
}
