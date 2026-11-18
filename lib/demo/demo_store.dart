import 'dart:collection';

import 'package:flutter/material.dart';

enum Meal {
  breakfast('Café da manhã'),
  lunch('Almoço'),
  snack('Lanche'),
  dinner('Jantar');

  const Meal(this.label);
  final String label;
}

enum MealStatus {
  none('—'),
  well('Comi bem'),
  little('Comi pouco'),
  skipped('Pulei');

  const MealStatus(this.label);
  final String label;
}

/// A dose of a medication for today (mock data).
class DemoDose {
  DemoDose({
    required this.id,
    required this.name,
    required this.amount,
    this.time,
    this.instruction,
    required this.color,
    this.taken = false,
  });

  final String id;
  final String name;
  final String amount;

  /// "HH:mm", or null for an "as needed" item.
  final String? time;
  final String? instruction;
  final Color color;
  bool taken;

  bool get isAsNeeded => time == null;

  /// Minutes since midnight, or null for as-needed doses.
  int? get minutesOfDay {
    final t = time;
    if (t == null) return null;
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/// In-memory mock data for the demo. No persistence.
class DemoStore extends ChangeNotifier {
  /// [now] is injectable for tests; defaults to the real current date.
  DemoStore({DateTime? now}) : _now = now ?? DateTime.now() {
    _seedMoods();
  }

  final DateTime _now;

  /// Date-only version of [d].
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Today (date-only).
  DateTime get today => dateOnly(_now);

  // --- profile / theme ------------------------------------------------------

  String nickname = 'Lu';

  void setNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  ThemeMode themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  // --- mood -----------------------------------------------------------------

  final Map<DateTime, int> _moods = {};

  /// Moods keyed by date-only DateTime (read-only view).
  Map<DateTime, int> get moods => UnmodifiableMapView(_moods);

  int? moodFor(DateTime day) => _moods[dateOnly(day)];

  int? get todayMood => moodFor(today);

  void setMood(DateTime day, int level) {
    _moods[dateOnly(day)] = level.clamp(1, 5);
    notifyListeners();
  }

  // Deterministic pattern. 0 = no entry. Mostly 3-4, a few 2s, gaps.
  static const List<int> _pattern = [
    4, 3, 4, 4, 3, 0, 4, 5, 3, 3, 2, 3, 4, 4, 0, 3,
    4, 5, 4, 3, 2, 3, 4, 0, 4, 3, 4, 4, 5, 3, 4,
  ];

  void _seedMoods() {
    final t = today;
    // Current month, days before today.
    for (var d = 1; d < t.day; d++) {
      _putSeed(DateTime(t.year, t.month, d), d - 1);
    }
    // Previous month, all days.
    final prevLast = DateTime(t.year, t.month, 0); // last day of prev month
    for (var d = 1; d <= prevLast.day; d++) {
      _putSeed(DateTime(prevLast.year, prevLast.month, d), d + 9);
    }
    // One "Muito mal" day in the previous month.
    if (prevLast.day >= 13) {
      _moods[DateTime(prevLast.year, prevLast.month, 13)] = 1;
    }
  }

  void _putSeed(DateTime day, int index) {
    final v = _pattern[index % _pattern.length];
    if (v != 0) _moods[day] = v;
  }

  // --- medication -----------------------------------------------------------

  final List<DemoDose> _doses = [
    DemoDose(
      id: 'a',
      name: 'Remédio A',
      amount: '1 comprimido',
      time: '08:00',
      instruction: 'em jejum',
      color: const Color(0xFFCBBFFF),
      taken: true,
    ),
    DemoDose(
      id: 'b',
      name: 'Remédio B',
      amount: '20 gotas',
      time: '14:00',
      color: const Color(0xFFA8DDF5),
    ),
    DemoDose(
      id: 'c',
      name: 'Remédio C',
      amount: '1 comprimido',
      time: '22:00',
      color: const Color(0xFFFFC8A8),
    ),
    DemoDose(
      id: 'd',
      name: 'Remédio D',
      amount: '1 comprimido',
      instruction: 'quando necessário',
      color: const Color(0xFFBFE8C9),
    ),
  ];

  /// Today's doses, scheduled first (by time), then as-needed items.
  List<DemoDose> get doses => List.unmodifiable(_doses);

  int get scheduledDoseCount => _doses.where((d) => !d.isAsNeeded).length;

  int get takenScheduledDoseCount =>
      _doses.where((d) => !d.isAsNeeded && d.taken).length;

  void toggleDose(String id) {
    for (final d in _doses) {
      if (d.id == id) {
        d.taken = !d.taken;
        notifyListeners();
        return;
      }
    }
  }

  // --- water ----------------------------------------------------------------

  int waterMl = 1250;
  final int waterGoalMl = 2000;
  final List<int> _waterLog = [];

  bool get canUndoWater => _waterLog.isNotEmpty;

  void addWater(int ml) {
    waterMl += ml;
    _waterLog.add(ml);
    notifyListeners();
  }

  /// Undoes the last [addWater] (does nothing if there is none).
  void undoWater() {
    if (_waterLog.isEmpty) return;
    waterMl -= _waterLog.removeLast();
    if (waterMl < 0) waterMl = 0;
    notifyListeners();
  }

  // --- movement -------------------------------------------------------------

  bool? movedToday;

  void setMoved(bool value) {
    movedToday = value;
    notifyListeners();
  }

  // --- meals ----------------------------------------------------------------

  final Map<Meal, MealStatus> meals = {
    Meal.breakfast: MealStatus.well,
    Meal.lunch: MealStatus.none,
    Meal.snack: MealStatus.none,
    Meal.dinner: MealStatus.none,
  };

  /// none -> well -> little -> skipped -> none.
  void cycleMeal(Meal m) {
    final cur = meals[m] ?? MealStatus.none;
    meals[m] = MealStatus.values[(cur.index + 1) % MealStatus.values.length];
    notifyListeners();
  }

  void setMeal(Meal meal, MealStatus status) {
    meals[meal] = status;
    notifyListeners();
  }
}

/// Provides the [DemoStore] to the tree.
class DemoScope extends InheritedNotifier<DemoStore> {
  const DemoScope({
    super.key,
    required DemoStore store,
    required super.child,
  }) : super(notifier: store);

  /// Returns the store and rebuilds the caller when it changes.
  static DemoStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DemoScope>();
    assert(scope != null, 'No DemoScope found in context');
    return scope!.notifier!;
  }

  /// Returns the store without subscribing (for callbacks / one-off actions).
  static DemoStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DemoScope>();
    assert(scope != null, 'No DemoScope found in context');
    return scope!.notifier!;
  }
}
