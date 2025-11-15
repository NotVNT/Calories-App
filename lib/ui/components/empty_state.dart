import 'package:flutter/material.dart';

/// Simple reusable empty state widget used across the app when no data is
/// available. Shows an icon, a title, an optional message and an optional
/// action button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.info_outline,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final maxH = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 200.0;
          final maxW = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 300.0;
          final iconSize = (maxH * 0.35).clamp(28.0, 56.0);
          final buttonWidth = (maxW * 0.6).clamp(96.0, 160.0);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 4),
                Icon(icon, size: iconSize, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW - 48),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxW - 48,
                      maxHeight: maxH * 0.4,
                    ),
                    child: Text(
                      message!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
                SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}
