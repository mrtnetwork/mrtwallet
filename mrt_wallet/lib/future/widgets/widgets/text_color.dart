import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef QuickColorWidget = Function({
  required BuildContext context,
  required Color color,
  required TextStyle? bodyMedium,
  required TextStyle? bodyLarge,
  required TextStyle? bodySmall,
  required TextStyle? titleLarge,
  required TextStyle? titleMedium,
  required TextStyle? labelLarge,
});

class QuickTextColor extends StatelessWidget {
  const QuickTextColor({required this.builder, required this.color, super.key});
  final QuickColorWidget builder;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return builder(
      context: context,
      color: color,
      bodyLarge: context.textTheme.bodyLarge?.copyWith(color: color),
      bodyMedium: context.textTheme.bodyMedium?.copyWith(color: color),
      bodySmall: context.textTheme.bodySmall?.copyWith(color: color),
      labelLarge: context.textTheme.labelLarge?.copyWith(color: color),
      titleLarge: context.textTheme.titleLarge?.copyWith(color: color),
      titleMedium: context.textTheme.titleMedium?.copyWith(color: color),
    );
  }
}
