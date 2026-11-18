import '../../core/widgets/maia_avatar.dart';

/// Lightweight preview of the future JSON script engine (spec 7.3 / App. A).
/// Texts are demo copy, still to be reviewed by a mental-health professional.

enum NodeKind { message, scale, grounding }

/// Buttons shown with a node (calls and links).
enum ScriptAction { callSamu, callCvv, openCaps, trustedContact }

/// What happens when an option is chosen.
enum OptionEffect {
  /// Just show the answer and go to [ScriptOption.next].
  none,

  /// Push the emergency screen, then continue at [ScriptOption.next].
  openEmergency,

  /// Open the breathing screen (await), then continue at [ScriptOption.next].
  runBreathing,

  /// Open the mood entry screen, then continue at [ScriptOption.next].
  openMood,

  /// Opens the safety plan sheet; the options stay on screen.
  openSafetyPlan,

  /// Opens the trusted-contact sheet; the options stay on screen.
  openTrusted,

  /// Starts the conversation over.
  restart,

  /// Leaves for the "Hoje" tab.
  goToday,
}

class ScriptOption {
  const ScriptOption(
    this.label, {
    this.next = '',
    this.effect = OptionEffect.none,
    this.path,
    this.risk = false,
  });

  final String label;
  final String next;
  final OptionEffect effect;

  /// Remembers the chosen feeling (anxiety, sadness, anger, unknown).
  final String? path;

  /// Marks the conversation as a risk path (always ends with referral).
  final bool risk;
}

class ScriptNode {
  const ScriptNode({
    this.kind = NodeKind.message,
    this.expression = MaiaExpression.calm,
    this.messages = const [],
    this.actions = const [],
    this.actionsFirst = false,
    this.options = const [],
    this.next = '',
  });

  final NodeKind kind;
  final MaiaExpression expression;
  final List<String> messages;
  final List<ScriptAction> actions;

  /// Show the action buttons immediately, before the messages finish.
  final bool actionsFirst;
  final List<ScriptOption> options;

  /// For scale / grounding nodes: where to go afterwards.
  final String next;
}

abstract final class MaiaScriptIds {
  static const opening = 'opening';
  static const riskCheck = 'risk_check';
  static const riskSafe = 'risk_safe';
  static const intensityBefore = 'intensity_before';
  // Branch nodes (resolved in code by the screen):
  static const routeTool = 'route_tool';
  static const toolAlt = 'tool_alt';
  static const checkProgress = 'check_progress';

  static const breathingOffer = 'breathing_offer';
  static const grounding = 'grounding';
  static const intensityAfter = 'intensity_after';
  static const closing = 'closing';
  static const referral = 'referral';
  static const end = 'end';
}

const maiaDemoScript = <String, ScriptNode>{
  MaiaScriptIds.opening: ScriptNode(
    messages: ['Oi. Eu tô aqui com você.', 'O que está mais forte agora?'],
    options: [
      ScriptOption('Ansiedade ou pânico',
          next: MaiaScriptIds.intensityBefore, path: 'anxiety'),
      ScriptOption('Tristeza ou vazio',
          next: MaiaScriptIds.intensityBefore, path: 'sadness'),
      ScriptOption('Raiva ou agitação',
          next: MaiaScriptIds.intensityBefore, path: 'anger'),
      ScriptOption('Pensamentos de me machucar ou de morrer',
          next: MaiaScriptIds.riskCheck, risk: true),
      ScriptOption('Não sei, só preciso de ajuda',
          next: MaiaScriptIds.intensityBefore, path: 'unknown'),
    ],
  ),
  MaiaScriptIds.riskCheck: ScriptNode(
    expression: MaiaExpression.caring,
    messages: [
      'Que bom que você me contou. Você não precisa passar por isso sem ajuda.',
      'Você está em perigo agora ou já se machucou?',
    ],
    actions: [ScriptAction.callSamu, ScriptAction.callCvv],
    actionsFirst: true,
    options: [
      ScriptOption('Sim',
          next: MaiaScriptIds.riskSafe, effect: OptionEffect.openEmergency),
      ScriptOption('Não', next: MaiaScriptIds.riskSafe),
    ],
  ),
  MaiaScriptIds.riskSafe: ScriptNode(
    expression: MaiaExpression.caring,
    messages: [
      'Fico feliz que você esteja em segurança neste momento.',
      'O CVV atende 24 horas pelo 188, de graça, se quiser conversar com alguém agora.',
    ],
    actions: [ScriptAction.callCvv],
    options: [
      ScriptOption('Abrir meu plano de segurança',
          effect: OptionEffect.openSafetyPlan),
      ScriptOption('Respirar junto com o Maiá',
          next: MaiaScriptIds.breathingOffer, path: 'anxiety'),
      ScriptOption('Falar com alguém de confiança',
          effect: OptionEffect.openTrusted),
    ],
  ),
  MaiaScriptIds.intensityBefore: ScriptNode(
    kind: NodeKind.scale,
    expression: MaiaExpression.caring,
    messages: ['De 0 a 10, quão forte está isso agora?'],
    next: MaiaScriptIds.routeTool,
  ),
  MaiaScriptIds.breathingOffer: ScriptNode(
    messages: ['Vamos respirar juntos?'],
    options: [
      ScriptOption('Vamos',
          next: MaiaScriptIds.intensityAfter,
          effect: OptionEffect.runBreathing),
      ScriptOption('Prefiro outra coisa', next: MaiaScriptIds.grounding),
    ],
  ),
  MaiaScriptIds.grounding: ScriptNode(
    kind: NodeKind.grounding,
    messages: [
      'Tudo bem sentir isso. Vamos olhar ao redor, um passo de cada vez.',
    ],
    next: MaiaScriptIds.intensityAfter,
  ),
  MaiaScriptIds.intensityAfter: ScriptNode(
    kind: NodeKind.scale,
    expression: MaiaExpression.caring,
    messages: ['E agora, de 0 a 10?'],
    next: MaiaScriptIds.checkProgress,
  ),
  MaiaScriptIds.closing: ScriptNode(
    expression: MaiaExpression.happy,
    messages: [
      'Você fez algo importante por você agora.',
      'Quer registrar como está se sentindo?',
    ],
    options: [
      ScriptOption('Registrar humor',
          next: MaiaScriptIds.end, effect: OptionEffect.openMood),
      ScriptOption('Agora não', next: MaiaScriptIds.end),
    ],
  ),
  MaiaScriptIds.referral: ScriptNode(
    expression: MaiaExpression.caring,
    messages: [
      'Tá tudo bem se ainda estiver difícil. Às vezes a gente precisa de mais gente junto.',
      'Quer chamar alguém?',
    ],
    actions: [
      ScriptAction.callCvv,
      ScriptAction.openCaps,
      ScriptAction.trustedContact,
    ],
    options: [
      ScriptOption('Tentar outra ferramenta', next: MaiaScriptIds.toolAlt),
      ScriptOption('Abrir meu plano de segurança',
          effect: OptionEffect.openSafetyPlan),
      ScriptOption('Terminar por aqui', next: MaiaScriptIds.end),
    ],
  ),
  MaiaScriptIds.end: ScriptNode(
    messages: ['Tudo bem. Eu fico por aqui se você precisar.'],
    options: [
      ScriptOption('Conversar de novo', effect: OptionEffect.restart),
      ScriptOption('Ir para Hoje', effect: OptionEffect.goToday),
    ],
  ),
};
