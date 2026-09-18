import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

/// Base card surface used across the app for grouped content (event cards,
/// list items, dashboard panels, etc.). Wraps [Theme.cardTheme] so styling
/// changes propagate everywhere automatically.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.space16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? cardTheme.color,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(
          color: (cardTheme.shape as RoundedRectangleBorder?)?.side.color ??
              Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        child: content,
      ),
    );
  }
}
