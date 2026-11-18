import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';

class _Step {
  const _Step(this.count, this.text);
  final int count;
  final String text;
}

const _steps = [
  _Step(5, '5 coisas que você vê'),
  _Step(4, '4 coisas que você pode tocar'),
  _Step(3, '3 coisas que você ouve'),
  _Step(2, '2 coisas que você sente o cheiro'),
  _Step(1, '1 coisa que você pode saborear'),
];

/// Inline 5-4-3-2-1 grounding: one step at a time, tappable dots to count.
class GroundingView extends StatefulWidget {
  const GroundingView({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<GroundingView> createState() => _GroundingViewState();
}

class _GroundingViewState extends State<GroundingView> {
  int _step = 0;
  late List<bool> _marked = List.filled(_steps[0].count, false);

  void _next() {
    if (_step >= _steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _step++;
      _marked = List.filled(_steps[_step].count, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final step = _steps[_step];
    final last = _step == _steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(step.text,
              textAlign: TextAlign.center, style: theme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Toque numa bolinha cada vez que encontrar uma.',
          textAlign: TextAlign.center,
          style: theme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _marked.length; i++)
              Semantics(
                button: true,
                checked: _marked[i],
                label: 'Bolinha ${i + 1} de ${_marked.length}',
                excludeSemantics: true,
                child: InkResponse(
                  radius: 28,
                  onTap: () => setState(() => _marked[i] = !_marked[i]),
                  child: SizedBox(
                    width: AppSpacing.minTarget + 4,
                    height: AppSpacing.minTarget + 4,
                    child: Center(
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _marked[i]
                              ? colors.primary
                              : colors.surfaceSoft,
                          border: Border.all(
                            color: _marked[i]
                                ? colors.primary
                                : colors.outlineStrong,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        BigButton(
          label: last ? 'Terminar' : 'Próximo',
          onPressed: _next,
        ),
      ],
    );
  }
}
