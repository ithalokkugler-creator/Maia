import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// "1,25" style liters from ml (pt-BR decimal comma, no trailing zeros).
String formatLiters(int ml) {
  final v = ml / 1000;
  var s = v.toStringAsFixed(2);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s.replaceAll('.', ',');
}

/// Cute bottle with animated water fill and a small wave on top.
class WaterBottle extends StatefulWidget {
  const WaterBottle({
    super.key,
    required this.ml,
    required this.goalMl,
    this.height = 140,
  });

  final int ml;
  final int goalMl;
  final double height;

  @override
  State<WaterBottle> createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _wave.stop();
    } else if (!_wave.isAnimating) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final fraction = widget.goalMl <= 0
        ? 0.0
        : (widget.ml / widget.goalMl).clamp(0.0, 1.0);
    final litersLabel =
        '${formatLiters(widget.ml)} de ${formatLiters(widget.goalMl)} '
        '${widget.goalMl == 1000 ? 'litro' : 'litros'}';
    final width = widget.height * 0.56;

    return Semantics(
      label: 'Água: $litersLabel',
      value: '${(fraction * 100).round()}%',
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: widget.height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, level, _) => AnimatedBuilder(
            animation: _wave,
            builder: (context, _) => CustomPaint(
              painter: _BottlePainter(
                level: level,
                phase: reduce ? 0 : _wave.value * 2 * math.pi,
                water: colors.water,
                waterSoft: colors.waterContainer,
                outline: colors.isDark ? colors.water : colors.outlineStrong,
                cap: colors.primary,
                glass: colors.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  _BottlePainter({
    required this.level,
    required this.phase,
    required this.water,
    required this.waterSoft,
    required this.outline,
    required this.cap,
    required this.glass,
  });

  final double level;
  final double phase;
  final Color water;
  final Color waterSoft;
  final Color outline;
  final Color cap;
  final Color glass;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final stroke = math.max(w * 0.05, 2.0);
    final inset = stroke / 2;

    final capH = h * 0.09;
    final neckW = w * 0.42;
    final cx = w / 2;
    final bodyTop = h * 0.26;

    // Bottle outline path (neck + rounded shoulders + rounded body).
    final bottle = Path()
      ..moveTo(cx - neckW / 2, capH)
      ..lineTo(cx - neckW / 2, bodyTop - h * 0.04)
      ..cubicTo(cx - neckW / 2, bodyTop + h * 0.02, inset, bodyTop - h * 0.02,
          inset, bodyTop + h * 0.16)
      ..lineTo(inset, h - w * 0.2)
      ..quadraticBezierTo(inset, h - inset, w * 0.22, h - inset)
      ..lineTo(w - w * 0.22, h - inset)
      ..quadraticBezierTo(w - inset, h - inset, w - inset, h - w * 0.2)
      ..lineTo(w - inset, bodyTop + h * 0.16)
      ..cubicTo(w - inset, bodyTop - h * 0.02, cx + neckW / 2,
          bodyTop + h * 0.02, cx + neckW / 2, bodyTop - h * 0.04)
      ..lineTo(cx + neckW / 2, capH)
      ..close();

    canvas.drawPath(bottle, Paint()..color = glass);

    // Water fill clipped to the bottle.
    canvas.save();
    canvas.clipPath(bottle);
    final innerTop = bodyTop;
    final innerH = h - innerTop;
    final surfaceY = h - innerH * level;
    if (level > 0) {
      final amp = math.min(h * 0.018, 3.0) * (level < 1 ? 1 : 0.5);
      final wave = Path()..moveTo(0, h);
      wave.lineTo(0, surfaceY);
      const steps = 24;
      for (var i = 0; i <= steps; i++) {
        final x = w * i / steps;
        final y = surfaceY + math.sin(i / steps * 2 * math.pi * 1.2 + phase) * amp;
        wave.lineTo(x, y);
      }
      wave.lineTo(w, h);
      wave.close();
      canvas.drawPath(wave, Paint()..color = water.withValues(alpha: 0.85));

      // Little bubbles.
      final bubble = Paint()..color = Colors.white.withValues(alpha: 0.35);
      if (level > 0.15) {
        canvas.drawCircle(Offset(w * 0.30, h - innerH * level * 0.35),
            w * 0.045, bubble);
        canvas.drawCircle(Offset(w * 0.62, h - innerH * level * 0.6),
            w * 0.03, bubble);
        canvas.drawCircle(Offset(w * 0.45, h - innerH * level * 0.18),
            w * 0.025, bubble);
      }
    }
    // Soft glass highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.17, bodyTop + h * 0.14, w * 0.07, h * 0.3),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.restore();

    canvas.drawPath(
      bottle,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Cap.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - neckW / 2 - stroke / 2, 0, neckW + stroke, capH),
        Radius.circular(capH * 0.45),
      ),
      Paint()..color = cap,
    );
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.level != level ||
      old.phase != phase ||
      old.water != water ||
      old.outline != outline;
}
