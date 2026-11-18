import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/responsive/window_class.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/big_button.dart';
import '../../core/widgets/help_bar.dart';
import '../../core/widgets/maia_avatar.dart';
import 'grounding_view.dart';
import 'intensity_scale.dart';
import 'maia_actions.dart';
import 'maia_demo_script.dart';

class _Entry {
  const _Entry.maia(this.text) : fromUser = false;
  const _Entry.user(this.text) : fromUser = true;
  final String text;
  final bool fromUser;
}

/// Maiá tab: scripted crisis conversation (demo, no AI, no persistence).
class MaiaScreen extends StatefulWidget {
  const MaiaScreen({super.key});

  @override
  State<MaiaScreen> createState() => _MaiaScreenState();
}

class _MaiaScreenState extends State<MaiaScreen> {
  final _scroll = ScrollController();
  final _log = <_Entry>[];

  String _nodeId = MaiaScriptIds.opening;
  bool _typing = false;
  bool _ready = false;
  bool _reduce = false;
  int _gen = 0;

  // Conversation state.
  String _path = 'unknown';
  bool _risk = false;
  int _before = 0;
  int _after = 0;
  bool _lastToolWasBreathing = false;

  ScriptNode get _node => maiaDemoScript[_nodeId]!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enter(MaiaScriptIds.opening);
    });
  }

  @override
  void dispose() {
    _gen++;
    _scroll.dispose();
    super.dispose();
  }

  void _restart() {
    _gen++;
    setState(() {
      _log.clear();
      _typing = false;
      _ready = false;
      _path = 'unknown';
      _risk = false;
      _before = 0;
      _after = 0;
    });
    _enter(MaiaScriptIds.opening);
  }

  String _resolve(String id) {
    switch (id) {
      case MaiaScriptIds.routeTool:
        return (_path == 'anxiety' || _path == 'anger')
            ? MaiaScriptIds.breathingOffer
            : MaiaScriptIds.grounding;
      case MaiaScriptIds.toolAlt:
        _before = _after; // measure progress from where the person is now
        return _lastToolWasBreathing
            ? MaiaScriptIds.grounding
            : MaiaScriptIds.breathingOffer;
      case MaiaScriptIds.checkProgress:
        final improved = _after < _before && _after < 7;
        return (improved && !_risk)
            ? MaiaScriptIds.closing
            : MaiaScriptIds.referral;
    }
    return id;
  }

  Future<void> _enter(String id) async {
    final resolved = _resolve(id);
    if (resolved != id) return _enter(resolved);
    final gen = ++_gen;
    final node = maiaDemoScript[id]!;
    setState(() {
      _nodeId = id;
      _ready = false;
    });
    if (node.kind == NodeKind.grounding) _lastToolWasBreathing = false;
    for (final m in node.messages) {
      if (!_reduce) {
        setState(() => _typing = true);
        _scrollToEnd();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!mounted || gen != _gen) return;
      }
      setState(() {
        _typing = false;
        _log.add(_Entry.maia(m));
      });
      _scrollToEnd();
      if (!_reduce) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted || gen != _gen) return;
      }
    }
    setState(() => _ready = true);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      if (_reduce) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(end,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  void _say(String text) {
    setState(() => _log.add(_Entry.user(text)));
  }

  Future<void> _choose(ScriptOption o) async {
    switch (o.effect) {
      case OptionEffect.openSafetyPlan:
        showSafetyPlanSheet(context);
        return;
      case OptionEffect.openTrusted:
        showTrustedContactSheet(context);
        return;
      case OptionEffect.restart:
        _restart();
        return;
      case OptionEffect.goToday:
        context.go(AppRoutes.today);
        return;
      case OptionEffect.none:
      case OptionEffect.openEmergency:
      case OptionEffect.runBreathing:
      case OptionEffect.openMood:
        break;
    }
    _gen++; // lock the current step while a screen is open
    setState(() => _ready = false);
    _say(o.label);
    if (o.path != null) _path = o.path!;
    if (o.risk) _risk = true;
    switch (o.effect) {
      case OptionEffect.openEmergency:
        await context.push<void>(AppRoutes.emergency);
      case OptionEffect.runBreathing:
        _lastToolWasBreathing = true;
        await context.push<bool>(AppRoutes.breathing);
      case OptionEffect.openMood:
        await context.push<void>(AppRoutes.moodEntryFor());
      default:
        break;
    }
    if (!mounted) return;
    _enter(o.next);
  }

  void _answerScale(int value) {
    _say('$value de 10');
    if (_nodeId == MaiaScriptIds.intensityBefore) {
      _before = value;
    } else {
      _after = value;
    }
    _enter(_node.next);
  }

  void _runAction(ScriptAction a) {
    switch (a) {
      case ScriptAction.callSamu:
        dialHelp(context, '192');
      case ScriptAction.callCvv:
        dialHelp(context, '188');
      case ScriptAction.openCaps:
        openCaps(context);
      case ScriptAction.trustedContact:
        showTrustedContactSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _reduce = MediaQuery.disableAnimationsOf(context);
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final gutter = AppSpacing.gutter(context.windowClass);
    final node = _node;

    final showActions =
        node.actions.isNotEmpty && (_ready || node.actionsFirst);

    final interactive = <Widget>[
      if (showActions)
        for (final a in node.actions) ...[
          _ActionButton(action: a, onPressed: () => _runAction(a)),
          const SizedBox(height: AppSpacing.sm),
        ],
      if (_ready && node.kind == NodeKind.scale)
        IntensityScale(onSelected: _answerScale),
      if (_ready && node.kind == NodeKind.grounding)
        GroundingView(
          onDone: () {
            _say('Terminei');
            _enter(node.next);
          },
        ),
      if (_ready && node.kind == NodeKind.message)
        for (final o in node.options) ...[
          BigButton(
            label: o.label,
            variant: BigButtonVariant.soft,
            onPressed: () => _choose(o),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, AppSpacing.xs, gutter, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text('Maiá', style: theme.headlineSmall),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _restart,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(
                              AppSpacing.minTarget, AppSpacing.minTarget),
                          foregroundColor: colors.textMuted,
                        ),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Recomeçar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LayoutBuilder(builder: (context, c) {
              final size = (MediaQuery.sizeOf(context).height * 0.16)
                  .clamp(64.0, 112.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: MaiaAvatar(size: size, expression: node.expression),
              );
            }),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(
                    gutter, AppSpacing.xs, gutter, AppSpacing.lg),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: AppSpacing.maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final e in _log) _Bubble(entry: e),
                          if (_typing) const _TypingBubble(),
                          if (interactive.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            ...interactive,
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const HelpBar(),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.entry});
  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final user = entry.fromUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Semantics(
          container: true,
          label: user ? 'Você: ${entry.text}' : 'Maiá: ${entry.text}',
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: user ? AppSpacing.xs : AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: user ? colors.primaryContainer : colors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusBubble),
              ),
              child: Text(
                entry.text,
                style: user
                    ? theme.bodyMedium
                        ?.copyWith(color: colors.onPrimaryContainer)
                    : theme.bodyLarge?.copyWith(color: colors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: 'Maiá está escrevendo',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusBubble),
              ),
              child: Text('…',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colors.textMuted)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onPressed});

  final ScriptAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (label, variant) = switch (action) {
      ScriptAction.callSamu => (
          'Ligar para o SAMU (192)',
          BigButtonVariant.help
        ),
      ScriptAction.callCvv => (
          'Ligar para o CVV (188)',
          BigButtonVariant.help
        ),
      ScriptAction.openCaps => (
          'Encontrar um CAPS perto de mim',
          BigButtonVariant.soft
        ),
      ScriptAction.trustedContact => (
          'Falar com alguém de confiança',
          BigButtonVariant.soft
        ),
    };
    return BigButton(label: label, variant: variant, onPressed: onPressed);
  }
}
