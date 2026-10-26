import 'package:flutter/material.dart';
import '../core/theme/seen_theme.dart';
import '../features/shell/main_shell.dart';

class SeenApp extends StatelessWidget {
  const SeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سين',
      debugShowCheckedModeBanner: false,
      theme: SeenTheme.light,
      darkTheme: SeenTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const MainShell(),
    );
  }
}
