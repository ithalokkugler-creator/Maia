import 'dart:math' as math;

import 'package:flutter/material.dart';

enum MaiaExpression { calm, happy, caring, sleeping }

/// Maiá, the mascot: a round soft lavender creature with a tiny sprout.
///
/// [breath] (0..1) inflates the body up to ~12% for the breathing exercise.
class MaiaAvatar extends StatelessWidget {
  const MaiaAvatar({
    super.key,
    this.size = 96,
    this.expression = MaiaExpression.calm,
    this.breath = 0,
  });

  final double size;
  final MaiaExpression expression;
  final double breath;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Maiá',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _MaiaPainter(
              expression: expression,
              breath: breath.clamp(0.0, 1.0),
              dark: dark,
            ),
          ),
        ),
      ),
    );
  }
}

class _MaiaPainter extends CustomPainter {
  _MaiaPainter({
    required this.expression,
    required this.breath,
    required this.dark,
  });

  final MaiaExpression expression;
  final double breath;
  final bool dark;

  static const _ink = Color(0xFF2D2A3E);
  static const _stem = Color(0xFF5DB57E);
  static const _leaf = Color(0xFF6CCB8F);
  static const _cheek = Color(0xFFF7A8C0);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final k = 1 + 0.12 * breath;
    final w = 0.84 * s * k;
    final h = 0.70 * s * k;
    final cx = s / 2;
    final cy = 0.60 * s;
    final l = cx - w / 2, r = cx + w / 2, t = cy - h / 2, b = cy + h / 2;

    // Body path: dome on top, softly flattened bottom.
    final body = Path()
      ..moveTo(cx, t)
      ..cubicTo(cx + 0.276 * w, t, r, t + 0.25 * h, r, t + 0.55 * h)
      ..cubicTo(r, t + 0.80 * h, r - 0.10 * w, b, r - 0.22 * w, b)
      ..lineTo(l + 0.22 * w, b)
      ..cubicTo(l + 0.10 * w, b, l, t + 0.80 * h, l, t + 0.55 * h)
      ..cubicTo(l, t + 0.25 * h, cx - 0.276 * w, t, cx, t)
      ..close();

    // Ground shadow.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: dark ? 0.25 : 0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.025);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, math.min(b + s * 0.025, s - s * 0.02)),
        width: w * 0.72,
        height: s * 0.06,
      ),
      shadow,
    );

    // Sprout (behind body top edge).
    _paintSprout(canvas, s, cx, t, k);

    // Body gradient.
    final c1 = dark ? const Color(0xFFC3B8FF) : const Color(0xFFC9BFFF);
    final c2 = dark ? const Color(0xFF9F92F2) : const Color(0xFFB3A6FF);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ).createShader(Rect.fromLTRB(l, t, r, b)),
    );

    // Soft highlight.
    canvas.save();
    canvas.clipPath(body);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 0.22 * w, t + 0.20 * h),
        width: 0.26 * w,
        height: 0.14 * h,
      ),
      Paint()..color = Colors.white.withValues(alpha: dark ? 0.18 : 0.35),
    );
    canvas.restore();

    _paintFace(canvas, s, cx, cy, w, h);
  }

  void _paintSprout(Canvas canvas, double s, double cx, double t, double k) {
    final stroke = math.max(s * 0.03, 1.0);
    final base = Offset(cx, t + s * 0.02);
    final tip = Offset(cx + s * 0.005, t - s * 0.085 * k);
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(cx - s * 0.015, (base.dy + tip.dy) / 2, tip.dx, tip.dy);
    canvas.drawPath(
      stem,
      Paint()
        ..color = _stem
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    Path leaf(Offset from, Offset to, double bulge) {
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final dx = to.dx - from.dx, dy = to.dy - from.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / len, ny = dx / len;
      final c1 = mid + Offset(nx, ny) * bulge;
      final c2 = mid - Offset(nx, ny) * bulge;
      return Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(c1.dx, c1.dy, to.dx, to.dy)
        ..quadraticBezierTo(c2.dx, c2.dy, from.dx, from.dy)
        ..close();
    }

    final paint = Paint()..color = _leaf;
    canvas.drawPath(
      leaf(tip, tip + Offset(-s * 0.115, -s * 0.045), s * 0.04),
      paint,
    );
    canvas.drawPath(
      leaf(tip, tip + Offset(s * 0.115, -s * 0.06), s * 0.04),
      paint,
    );
  }

  void _paintFace(
      Canvas canvas, double s, double cx, double cy, double w, double h) {
    final ink = Paint()..color = _ink;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(s * 0.024, 1.0)
      ..strokeCap = StrokeCap.round;
    final ex = 0.19 * w;
    final ey = cy + 0.03 * h;
    final eyeR = math.max(s * 0.036, 1.1);

    // Cheeks.
    final cheek = Paint()..color = _cheek.withValues(alpha: 0.6);
    for (final sign in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + sign * 0.31 * w, cy + 0.17 * h),
          width: 0.17 * w,
          height: 0.11 * w,
        ),
        cheek,
      );
    }

    // Eyes.
    switch (expression) {
      case MaiaExpression.happy:
        for (final sign in [-1.0, 1.0]) {
          final x = cx + sign * ex;
          final p = Path()
            ..moveTo(x - 0.055 * s, ey + 0.018 * s)
            ..quadraticBezierTo(x, ey - 0.06 * s, x + 0.055 * s, ey + 0.018 * s);
          canvas.drawPath(p, line..strokeWidth = math.max(s * 0.028, 1.1));
        }
      case MaiaExpression.sleeping:
        for (final sign in [-1.0, 1.0]) {
          final x = cx + sign * ex;
          final p = Path()
            ..moveTo(x - 0.05 * s, ey - 0.005 * s)
            ..quadraticBezierTo(x, ey + 0.05 * s, x + 0.05 * s, ey - 0.005 * s);
          canvas.drawPath(p, line..strokeWidth = math.max(s * 0.026, 1.1));
        }
      case MaiaExpression.calm:
      case MaiaExpression.caring:
        canvas.drawCircle(Offset(cx - ex, ey), eyeR, ink);
        canvas.drawCircle(Offset(cx + ex, ey), eyeR, ink);
    }

    // Caring brows: inner ends slightly raised.
    if (expression == MaiaExpression.caring) {
      final brow = Paint()
        ..color = _ink.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(s * 0.018, 1.0)
        ..strokeCap = StrokeCap.round;
      final by = ey - 0.075 * s;
      canvas.drawLine(Offset(cx - ex - 0.045 * s, by + 0.012 * s),
          Offset(cx - ex + 0.045 * s, by - 0.012 * s), brow);
      canvas.drawLine(Offset(cx + ex + 0.045 * s, by + 0.012 * s),
          Offset(cx + ex - 0.045 * s, by - 0.012 * s), brow);
    }

    // Mouth.
    final my = cy + 0.14 * h;
    line.strokeWidth = math.max(s * 0.024, 1.0);
    switch (expression) {
      case MaiaExpression.happy:
        final mw = 0.085 * w;
        final d = 0.11 * h;
        final mouth = Path()
          ..moveTo(cx - mw, my)
          ..lineTo(cx + mw, my)
          ..cubicTo(cx + mw, my + d * 1.2, cx - mw, my + d * 1.2, cx - mw, my)
          ..close();
        canvas.drawPath(mouth, ink);
        canvas.save();
        canvas.clipPath(mouth);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, my + d * 0.85),
            width: mw * 1.2,
            height: d * 0.7,
          ),
          Paint()..color = _cheek,
        );
        canvas.restore();
      case MaiaExpression.sleeping:
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, my + 0.02 * h), width: 0.05 * w, height: 0.05 * w),
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(s * 0.02, 1.0),
        );
      case MaiaExpression.caring:
        final mw = 0.05 * w;
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw, my)
            ..quadraticBezierTo(cx, my + 0.04 * h, cx + mw, my),
          line,
        );
      case MaiaExpression.calm:
        final mw = 0.06 * w;
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw, my)
            ..quadraticBezierTo(cx, my + 0.07 * h, cx + mw, my),
          line,
        );
    }
  }

  @override
  bool shouldRepaint(_MaiaPainter old) =>
      old.expression != expression || old.breath != breath || old.dark != dark;
}
