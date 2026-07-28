import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius = 20,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0xB3FFFFFF)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: child,
    );
  }
}
