import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remedios/demo/demo_store.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);

  test('seeds moods for current month before today and previous month', () {
    final s = DemoStore(now: now);
    expect(s.todayMood, isNull);
    final values = s.moods.values.toList();
    expect(values.every((v) => v >= 1 && v <= 5), isTrue);
    expect(s.moods.keys.any((d) => d.month == 11), isTrue);
    expect(s.moods.keys.any((d) => d.month == 10), isTrue);
    expect(s.moods.keys.every((d) => d.isBefore(DateTime(2026, 11, 18))), isTrue);
    expect(values.where((v) => v == 1).length, 1);
    expect(values.where((v) => v == 2), isNotEmpty);
    // Some gaps exist.
    expect(s.moods.length, lessThan(17 + 31));
  });

  test('seeding works on the 1st of a month', () {
    final s = DemoStore(now: DateTime(2026, 3, 1));
    expect(s.moods.keys.every((d) => d.month == 2), isTrue);
  });

  test('setMood and moodFor use date-only keys and notify', () {
    final s = DemoStore(now: now);
    var n = 0;
    s.addListener(() => n++);
    s.setMood(DateTime(2026, 11, 18, 22, 30), 4);
    expect(s.moodFor(DateTime(2026, 11, 18)), 4);
    expect(s.todayMood, 4);
    expect(n, 1);
  });

  test('toggleDose flips taken state', () {
    final s = DemoStore(now: now);
    final b = s.doses.firstWhere((d) => d.id == 'b');
    expect(b.taken, isFalse);
    s.toggleDose('b');
    expect(b.taken, isTrue);
    s.toggleDose('b');
    expect(b.taken, isFalse);
    expect(s.doses.any((d) => d.isAsNeeded), isTrue);
  });

  test('water add and undo', () {
    final s = DemoStore(now: now);
    final start = s.waterMl;
    s.addWater(250);
    s.addWater(150);
    expect(s.waterMl, start + 400);
    s.undoWater();
    expect(s.waterMl, start + 250);
    s.undoWater();
    s.undoWater(); // nothing to undo
    expect(s.waterMl, start);
  });

  test('movement', () {
    final s = DemoStore(now: now);
    expect(s.movedToday, isNull);
    s.setMoved(true);
    expect(s.movedToday, isTrue);
  });

  test('meals cycle none -> well -> little -> skipped -> none', () {
    final s = DemoStore(now: now);
    expect(s.meals[Meal.lunch], MealStatus.none);
    s.cycleMeal(Meal.lunch);
    expect(s.meals[Meal.lunch], MealStatus.well);
    s.cycleMeal(Meal.lunch);
    expect(s.meals[Meal.lunch], MealStatus.little);
    s.cycleMeal(Meal.lunch);
    expect(s.meals[Meal.lunch], MealStatus.skipped);
    s.cycleMeal(Meal.lunch);
    expect(s.meals[Meal.lunch], MealStatus.none);
    expect(Meal.breakfast.label, 'Café da manhã');
    expect(MealStatus.well.label, 'Comi bem');
  });

  test('theme mode', () {
    final s = DemoStore(now: now);
    s.setThemeMode(ThemeMode.dark);
    expect(s.themeMode, ThemeMode.dark);
  });
}
