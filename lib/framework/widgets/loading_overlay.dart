import 'package:flutter/material.dart';

import '../design/app_curves.dart';
import '../design/app_durations.dart';
import '../design/app_radii.dart';
import '../design/app_spacing.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.message,
  });

  final bool visible;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            opacity: visible ? 1 : 0,
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Material(
                  color: colors.surface,
                  borderRadius: AppRadii.brLg,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        if (message != null) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(message!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
