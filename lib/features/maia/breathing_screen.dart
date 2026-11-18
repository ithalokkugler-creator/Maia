import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/help_bar.dart';
import '../../core/widgets/maia_avatar.dart';

enum _Kind { inhale, holdFull, exhale, holdEmpty }

class _Phase {
  const _Phase(this.kind, this.seconds);
  final _Kind kind;
  final int seconds;

  String get label => switch (kind) {
        _Kind.inhale => 'Inspira…',
        _Kind.exhale => 'Solta…',
        _ => 'Segura…',
      };
}

class _Pattern {
  const _Pattern(this.name, this.phases);
  final String name;
  final List<_Phase> phases;
  int get cycle => phases.fold(0, (s, p) => s + p.seconds);
}

const _slow = _Pattern('Lenta 4-6', [
  _Phase(_Kind.inhale, 4),
  _Phase(_Kind.exhale, 6),
]);

const _box = _Pattern('Caixa 4-4-4-4', [
  _Phase(_Kind.inhale, 4),
  _Phase(_Kind.holdFull, 4),
  _Phase(_Kind.exhale, 4),
  _Phase(_Kind.holdEmpty, 4),
]);

/// Guided breathing (spec 7.4). Pops `true` when finished, `false` otherwise.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _breath = ValueNotifier<double>(0);

  _Pattern _pattern = _slow;
  int _minutes = 2;
  bool _paused = false;
  bool _done = false;

  Duration _accum = Duration.zero; // time before the current ticker run
  Duration _lastElapsed = Duration.zero;

  // What the UI shows (setState only when these change).
  int _phaseIndex = 0;
  int _countdown = 0;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _restartSession();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _breath.dispose();
    super.dispose();
  }

  Duration get _total => Duration(minutes: _minutes);

  void _restartSession() {
    _ticker.stop();
    _accum = Duration.zero;
    _lastElapsed = Duration.zero;
    _paused = false;
    _done = false;
    _phaseIndex = 0;
    _countdown = _pattern.phases.first.seconds;
    _remaining = _total.inSeconds;
    _breath.value = 0;
    _ticker.start();
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    _lastElapsed = elapsed;
    final t = _accum + elapsed;
    if (t >= _total) {
      _ticker.stop();
      _breath.value = 0;
      HapticFeedback.mediumImpact();
      setState(() => _done = true);
      return;
    }
    final ms = t.inMilliseconds;
    final cycleMs = _pattern.cycle * 1000;
    var inCycle = ms % cycleMs;
    var idx = 0;
    for (final p in _pattern.phases) {
      if (inCycle < p.seconds * 1000) break;
      inCycle -= p.seconds * 1000;
      idx++;
    }
    final phase = _pattern.phases[idx];
    final frac = inCycle / (phase.seconds * 1000);
    final eased = Curves.easeInOut.transform(frac);
    _breath.value = switch (phase.kind) {
      _Kind.inhale => eased,
      _Kind.holdFull => 1.0,
      _Kind.exhale => 1 - eased,
      _Kind.holdEmpty => 0.0,
    };
    final cd = ((phase.seconds * 1000 - inCycle) / 1000).ceil();
    final rem = ((_total.inMilliseconds - ms) / 1000).ceil();
    if (idx != _phaseIndex) HapticFeedback.lightImpact();
    if (idx != _phaseIndex || cd != _countdown || rem != _remaining) {
      setState(() {
        _phaseIndex = idx;
        _countdown = cd;
        _remaining = rem;
      });
    }
  }

  void _togglePause() {
    if (_paused) {
      _ticker.start();
      setState(() => _paused = false);
    } else {
      _accum += _lastElapsed;
      _lastElapsed = Duration.zero;
      _ticker.stop();
      setState(() => _paused = true);
    }
  }

  void _close(bool result) => context.pop(result);

  String _fmt(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final avatarSize = math.min(width * 0.6, 260.0);
    final phase = _pattern.phases[_phaseIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(false);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.xs, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child:
                            Text('Respirar junto', style: theme.titleLarge),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _close(false),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                            AppSpacing.minTarget, AppSpacing.minTarget),
                        foregroundColor: colors.textMuted,
                      ),
                      child: Text('Sair', style: theme.bodyLarge),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: AppSpacing.maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ValueListenableBuilder<double>(
                              valueListenable: _breath,
                              builder: (context, v, _) {
                                final avatar = MaiaAvatar(
                                  size: avatarSize,
                                  expression: _done
                                      ? MaiaExpression.happy
                                      : MaiaExpression.calm,
                                  breath: reduce ? 0 : v,
                                );
                                if (!reduce) return avatar;
                                return Opacity(
                                    opacity: 0.55 + 0.45 * v, child: avatar);
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_done) ..._doneContent(theme, colors)
                          else ..._runningContent(theme, colors, phase),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const HelpBar(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _doneContent(TextTheme theme, AppColors colors) => [
        Text(
          'Muito bem. Vamos ver como você está agora?',
          textAlign: TextAlign.center,
          style: theme.titleLarge?.copyWith(color: colors.text),
        ),
        const SizedBox(height: AppSpacing.lg),
        BigButton(label: 'Continuar', onPressed: () => _close(true)),
      ];

  List<Widget> _runningContent(
      TextTheme theme, AppColors colors, _Phase phase) {
    return [
      Semantics(
        liveRegion: true,
        child: Text(
          _paused ? 'Pausado' : phase.label,
          textAlign: TextAlign.center,
          style: theme.displaySmall?.copyWith(color: colors.text),
        ),
      ),
      ExcludeSemantics(
        child: Text(
          _paused ? '' : '$_countdown',
          textAlign: TextAlign.center,
          style: theme.headlineSmall?.copyWith(color: colors.textMuted),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Faltam ${_fmt(_remaining)}',
        textAlign: TextAlign.center,
        style: theme.bodyMedium?.copyWith(color: colors.textMuted),
      ),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final p in [_slow, _box])
            _chip(p.name, _pattern == p, () {
              _pattern = p;
              _restartSession();
            }),
        ],
      ),
      const SizedBox(height: AppSpacing.xs),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final m in [1, 2, 3])
            _chip('$m min', _minutes == m, () {
              _minutes = m;
              _restartSession();
            }),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      BigButton(
        label: _paused ? 'Retomar' : 'Pausar',
        onPressed: _togglePause,
      ),
      const SizedBox(height: AppSpacing.sm),
      BigButton(
        label: 'Parar',
        variant: BigButtonVariant.soft,
        onPressed: () => _close(false),
      ),
    ];
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTarget),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colors.primaryContainer,
        backgroundColor: colors.surfaceSoft,
        side: BorderSide(
            color: selected ? colors.primary : colors.outline),
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  selected ? colors.onPrimaryContainer : colors.text,
              fontSize: 16,
            ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      ),
    );
  }
}
