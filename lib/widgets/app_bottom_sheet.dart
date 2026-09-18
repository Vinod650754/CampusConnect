import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

/// Standard bottom sheet chrome (drag handle + padding). Feature modules
/// pass their content in; this widget owns the consistent shell.
class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXLarge)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.space20,
            right: AppDimens.space20,
            top: AppDimens.space12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.space20,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.space16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}
