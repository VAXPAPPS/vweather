import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:vweather/core/venom_layout.dart';
import 'package:vweather/core/theme/vaxp_theme.dart';

class VenomGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const VenomGlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.15, // More subtle default
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      child: VaxpGlass(
        blur: blur,
        opacity: opacity,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }
    return content;
  }
}
