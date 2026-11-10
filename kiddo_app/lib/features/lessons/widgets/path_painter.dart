import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kiddo_app/core/models/level_model.dart';

class PathNode {
  final Offset position;
  final LevelModel level;

  PathNode({required this.position, required this.level});
}

class PathPainter extends CustomPainter {
  final List<PathNode> nodes;
  final Color pathColor;

  PathPainter({required this.nodes, required this.pathColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodes.first.position.dx, nodes.first.position.dy);

    for (int i = 0; i < nodes.length - 1; i++) {
      final p1 = nodes[i].position;
      final p2 = nodes[i + 1].position;
      
      // Control points for bezier curve to make it "squiggly"
      final dy = p2.dy - p1.dy;
      
      final cp1 = Offset(p1.dx, p1.dy + dy * 0.5);
      final cp2 = Offset(p2.dx, p2.dy - dy * 0.5);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    // Draw dashed path
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 15.0;
    const dashSpace = 15.0;
    
    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = min(dashWidth, pathMetric.length - distance);
        final Path extractPath = pathMetric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.pathColor != pathColor;
  }
}
