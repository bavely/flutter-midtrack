import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';

class CylindricalOverlay extends StatefulWidget {
  const CylindricalOverlay({super.key});

  @override
  State<CylindricalOverlay> createState() => _CylindricalOverlayState();
}

class _CylindricalOverlayState extends State<CylindricalOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CylindricalGuidancePainter(
        rotationAnimation: _rotationController,
        pulseAnimation: _pulseController,
      ),
      size: Size.infinite,
    );
  }
}

class CylindricalGuidancePainter extends CustomPainter {
  final Animation<double> rotationAnimation;
  final Animation<double> pulseAnimation;

  CylindricalGuidancePainter({
    required this.rotationAnimation,
    required this.pulseAnimation,
  }) : super(repaint: Listenable.merge([rotationAnimation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Clear scanning area (oval shape for bottle)
    final scanAreaWidth = size.width * 0.6;
    final scanAreaHeight = size.height * 0.4;
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanAreaWidth,
      height: scanAreaHeight,
    );

    // Cut out the scanning area
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.drawOval(scanRect, clearPaint);

    // Draw scanning frame
    _drawScanningFrame(canvas, scanRect);

    // Draw rotation guides
    _drawRotationGuides(canvas, center, scanAreaWidth / 2);

    // Draw corner guides
    _drawCornerGuides(canvas, scanRect);
  }

  void _drawScanningFrame(Canvas canvas, Rect rect) {
    final framePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw oval frame
    canvas.drawOval(rect, framePaint);

    // Draw pulsing accent
    final pulsePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(
        0.3 + (pulseAnimation.value * 0.4),
      )
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawOval(rect, pulsePaint);
  }

  void _drawRotationGuides(Canvas canvas, Offset center, double radius) {
    final guidePaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const int numberOfGuides = 12;
    for (int i = 0; i < numberOfGuides; i++) {
      final angle = (i * 2 * math.pi / numberOfGuides) + 
                   (rotationAnimation.value * 2 * math.pi);
      
      final startRadius = radius + 20;
      final endRadius = radius + 40;
      
      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius * 0.6, // Flatten for bottle shape
      );
      
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius * 0.6,
      );

      // Fade based on position
      final opacity = (math.sin(angle - rotationAnimation.value * 2 * math.pi) + 1) / 2;
      final fadedPaint = Paint()
        ..color = AppTheme.accentColor.withOpacity(opacity * 0.8)
        ..strokeWidth = 2;

      canvas.drawLine(start, end, fadedPaint);
    }

    // Draw rotation arrow
    _drawRotationArrow(canvas, center, radius);
  }

  void _drawRotationArrow(Canvas canvas, Offset center, double radius) {
    final arrowPaint = Paint()
      ..color = AppTheme.secondaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw curved arrow
    final rect = Rect.fromCenter(
      center: center,
      width: (radius + 60) * 2,
      height: (radius + 60) * 1.2, // Flattened for bottle shape
    );

    final startAngle = -math.pi / 4;
    final sweepAngle = math.pi / 2;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);

    // Draw arrow head
    final arrowHeadAngle = startAngle + sweepAngle;
    final arrowCenter = Offset(
      center.dx + math.cos(arrowHeadAngle) * (radius + 60),
      center.dy + math.sin(arrowHeadAngle) * (radius + 60) * 0.6,
    );

    _drawArrowHead(canvas, arrowCenter, arrowHeadAngle + math.pi / 2, arrowPaint);
  }

  void _drawArrowHead(Canvas canvas, Offset center, double angle, Paint paint) {
    final arrowSize = 12.0;
    
    final p1 = Offset(
      center.dx + math.cos(angle) * arrowSize,
      center.dy + math.sin(angle) * arrowSize,
    );
    
    final p2 = Offset(
      center.dx + math.cos(angle + 2.5) * arrowSize,
      center.dy + math.sin(angle + 2.5) * arrowSize,
    );
    
    final p3 = Offset(
      center.dx + math.cos(angle - 2.5) * arrowSize,
      center.dy + math.sin(angle - 2.5) * arrowSize,
    );

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p3.dx, p3.dy);

    canvas.drawPath(path, paint);
  }

  void _drawCornerGuides(Canvas canvas, Rect rect) {
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;
    
    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CylindricalGuidancePainter oldDelegate) {
    return rotationAnimation != oldDelegate.rotationAnimation ||
           pulseAnimation != oldDelegate.pulseAnimation;
  }
}