import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class DotsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double dotRadius;
  final double circleRadius;

  DotsPainter({
    required this.progress,
    required this.color,
    required this.dotRadius,
    required this.circleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) + (progress * 2 * pi);
      final dx = center.dx + (cos(angle) * circleRadius);
      final dy = center.dy + (sin(angle) * circleRadius);

      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(DotsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.circleRadius != circleRadius;
  }
}

class CustomDotsProgress extends StatefulWidget {
  final Color? color;
  final double dotRadius;
  final double circleRadius;
  final double size;

  const CustomDotsProgress({
    super.key,
    this.color,
    this.dotRadius = 2.0,
    this.circleRadius = 10.0,
    this.size = 30.0,
  });
  @override
  // ignore: library_private_types_in_public_api
  _CustomSpinnerState createState() => _CustomSpinnerState();
}

class _CustomSpinnerState extends State<CustomDotsProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: DotsPainter(
              progress: _controller.value,
              color: widget.color ?? context.colors.primary,
              dotRadius: widget.dotRadius,
              circleRadius: widget.circleRadius,
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
            ),
          );
        },
      ),
    );
  }
}
