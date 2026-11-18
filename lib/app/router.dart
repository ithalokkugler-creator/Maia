import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/habits_screen.dart';
import '../features/maia/breathing_screen.dart';
import '../features/maia/emergency_screen.dart';
import '../features/maia/maia_screen.dart';
import '../features/meds/meds_screen.dart';
import '../features/mood/mood_calendar_screen.dart';
import '../features/mood/mood_entry_screen.dart';
import '../features/today/today_screen.dart';
import 'responsive/adaptive_scaffold.dart';

/// Route paths. Use with `context.go(...)` / `context.push(...)`.
abstract final class AppRoutes {
  static const today = '/today';
  static const mood = '/mood';
  static const moodEntry = '/mood/entry'; // optional ?date=yyyy-MM-dd
  static const maia = '/maia';
  static const breathing = '/maia/breathing';
  static const emergency = '/maia/emergency';
  static const meds = '/meds';
  static const habits = '/habits';

  /// `/mood/entry` or `/mood/entry?date=yyyy-MM-dd`.
  static String moodEntryFor([DateTime? day]) {
    if (day == null) return moodEntry;
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$moodEntry?date=${day.year}-$m-$d';
  }
}

final GlobalKey<NavigatorState> _rootKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

DateTime? _parseDate(String? s) {
  if (s == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AdaptiveScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (context, state) => const TodayScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.mood,
              builder: (context, state) => const MoodCalendarScreen(),
              routes: [
                GoRoute(
                  path: 'entry',
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => MoodEntryScreen(
                    day: _parseDate(state.uri.queryParameters['date']),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.maia,
              builder: (context, state) => const MaiaScreen(),
              routes: [
                GoRoute(
                  path: 'breathing',
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => const BreathingScreen(),
                ),
                GoRoute(
                  path: 'emergency',
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => const EmergencyScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.meds,
              builder: (context, state) => const MedsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.habits,
              builder: (context, state) => const HabitsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}
