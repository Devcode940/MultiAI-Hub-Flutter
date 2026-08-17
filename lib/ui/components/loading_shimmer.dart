import 'package:flutter/material.dart';

/// Reusable loading shimmer widget
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: shimmerAnimation(colorScheme.surfaceContainerHighest),
    );
  }

  Widget shimmerAnimation(Color baseColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * value, 0),
              end: Alignment(1 + 2 * value, 0),
              colors: [
                baseColor,
                baseColor.withOpacity(0.3),
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
