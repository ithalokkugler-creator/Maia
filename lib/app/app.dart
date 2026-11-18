import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../demo/demo_store.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RemediosApp extends StatefulWidget {
  const RemediosApp({super.key});

  @override
  State<RemediosApp> createState() => _RemediosAppState();
}

class _RemediosAppState extends State<RemediosApp> {
  final DemoStore _store = DemoStore();
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScope(
      store: _store,
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'Maiá',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: DemoScope.of(context).themeMode,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        ),
      ),
    );
  }
}
