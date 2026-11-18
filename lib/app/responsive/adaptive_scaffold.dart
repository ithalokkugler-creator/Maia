import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/widgets/maia_avatar.dart';
import '../theme/app_colors.dart';

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _maiaIndex = 2;

final List<_Dest> _dests = [
  _Dest('Hoje', PhosphorIconsRegular.house, PhosphorIconsFill.house),
  _Dest('Humor', PhosphorIconsRegular.smiley, PhosphorIconsFill.smiley),
  _Dest('Maiá', PhosphorIconsRegular.heart, PhosphorIconsFill.heart),
  _Dest('Remédios', PhosphorIconsRegular.pill, PhosphorIconsFill.pill),
  _Dest('Hábitos', PhosphorIconsRegular.plant, PhosphorIconsFill.plant),
];

/// Bottom NavigationBar (< 600dp) or NavigationRail (>= 600dp) for the 5 tabs.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colors = context.colors;
    final index = navigationShell.currentIndex;

    if (width >= 600) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: _go,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (var i = 0; i < _dests.length; i++)
                          NavigationRailDestination(
                            icon: _icon(i, false),
                            selectedIcon: _icon(i, true),
                            label: Text(_dests[i].label),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: colors.outline),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    final behavior = width < 320
        ? NavigationDestinationLabelBehavior.alwaysHide
        : width < 360
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow;

    return Scaffold(
      backgroundColor: colors.background,
      body: navigationShell,
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outline)),
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _go,
            labelBehavior: behavior,
            height: 76,
            destinations: [
              for (var i = 0; i < _dests.length; i++)
                NavigationDestination(
                  icon: _icon(i, false),
                  selectedIcon: _icon(i, true),
                  label: _dests[i].label,
                  tooltip: _dests[i].label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(int i, bool selected) {
    if (i == _maiaIndex) return _MaiaNavIcon(selected: selected);
    return PhosphorIcon(
      selected ? _dests[i].selectedIcon : _dests[i].icon,
      size: 24,
    );
  }
}

/// Maiá tab icon: the mascot inside a soft lavender circle, a bit bigger.
class _MaiaNavIcon extends StatelessWidget {
  const _MaiaNavIcon({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Layout box is 24x24 like the other icons (same label baseline); the
    // circle overflows visually.
    return SizedBox(
      width: 24,
      height: 24,
      child: OverflowBox(
        maxWidth: 40,
        maxHeight: 40,
        child: Transform.translate(
          offset: const Offset(0, -3),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer,
              border: Border.all(
                color: selected ? colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: const MaiaAvatar(size: 32),
          ),
        ),
      ),
    );
  }
}
