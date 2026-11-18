import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/mood_palette.dart';

/// Round face in the mood color. Expression differs per level (never color-only):
/// 5 = happy arcs + open smile, 4 = smile, 3 = flat mouth,
/// 2 = slight frown, 1 = frown + worried brows.
class MoodFace extends StatelessWidget {
  const MoodFace({
    super.key,
    required this.level,
    this.size = 48,
    this.selected = false,
  });

  final int level;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Humor $level, ${MoodPalette.label(level)}',
      image: true,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: selected ? 1.1 : 1.0,
        duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _MoodFacePainter(
              level: level.clamp(1, 5),
              fill: MoodPalette.color(level, brightness),
              ink: MoodPalette.onColor(brightness),
              ring: selected ? context.colors.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodFacePainter extends CustomPainter {
  _MoodFacePainter({
    required this.level,
    required this.fill,
    required this.ink,
    required this.ring,
  });

  final int level;
  final Color fill;
  final Color ink;
  final Color? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    canvas.drawCircle(c, s / 2, Paint()..color = fill);
    if (ring != null) {
      canvas.drawCircle(
        c,
        s / 2 + math.max(s * 0.06, 2),
        Paint()
          ..color = ring!
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(s * 0.06, 2.5),
      );
    }

    final stroke = math.max(s * 0.05, 1.2);
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = ink;

    final ex = 0.22 * s;
    final ey = c.dy - 0.07 * s;
    final eyeR = math.max(s * 0.05, 1.2);

    // Cheeks.
    final cheek = Paint()..color = const Color(0xFFF7A8C0).withValues(alpha: 0.55);
    for (final sign in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + sign * 0.31 * s, c.dy + 0.12 * s),
          width: 0.16 * s,
          height: 0.1 * s,
        ),
        cheek,
      );
    }

    // Eyes.
    if (level == 5) {
      for (final sign in [-1.0, 1.0]) {
        final x = c.dx + sign * ex;
        canvas.drawPath(
          Path()
            ..moveTo(x - 0.07 * s, ey + 0.025 * s)
            ..quadraticBezierTo(x, ey - 0.09 * s, x + 0.07 * s, ey + 0.025 * s),
          line,
        );
      }
    } else {
      canvas.drawCircle(Offset(c.dx - ex, ey), eyeR, dot);
      canvas.drawCircle(Offset(c.dx + ex, ey), eyeR, dot);
    }

    // Worried brows for level 1 (inner ends raised).
    if (level == 1) {
      final brow = Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(s * 0.035, 1.0)
        ..strokeCap = StrokeCap.round;
      final by = ey - 0.11 * s;
      canvas.drawLine(Offset(c.dx - ex - 0.07 * s, by + 0.03 * s),
          Offset(c.dx - ex + 0.06 * s, by - 0.02 * s), brow);
      canvas.drawLine(Offset(c.dx + ex + 0.07 * s, by + 0.03 * s),
          Offset(c.dx + ex - 0.06 * s, by - 0.02 * s), brow);
    }

    // Mouth.
    switch (level) {
      case 5:
        final top = c.dy + 0.12 * s;
        final mouth = Path()
          ..moveTo(c.dx - 0.16 * s, top)
          ..lineTo(c.dx + 0.16 * s, top)
          ..cubicTo(c.dx + 0.15 * s, top + 0.26 * s, c.dx - 0.15 * s,
              top + 0.26 * s, c.dx - 0.16 * s, top)
          ..close();
        canvas.drawPath(mouth, dot);
      case 4:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 0.14 * s, c.dy + 0.15 * s)
            ..quadraticBezierTo(
                c.dx, c.dy + 0.30 * s, c.dx + 0.14 * s, c.dy + 0.15 * s),
          line,
        );
      case 3:
        canvas.drawLine(Offset(c.dx - 0.11 * s, c.dy + 0.22 * s),
            Offset(c.dx + 0.11 * s, c.dy + 0.22 * s), line);
      case 2:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 0.11 * s, c.dy + 0.25 * s)
            ..quadraticBezierTo(
                c.dx, c.dy + 0.18 * s, c.dx + 0.11 * s, c.dy + 0.25 * s),
          line,
        );
      default:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 0.14 * s, c.dy + 0.29 * s)
            ..quadraticBezierTo(
                c.dx, c.dy + 0.15 * s, c.dx + 0.14 * s, c.dy + 0.29 * s),
          line,
        );
    }
  }

  @override
  bool shouldRepaint(_MoodFacePainter old) =>
      old.level != level ||
      old.fill != fill ||
      old.ink != ink ||
      old.ring != ring;
}
