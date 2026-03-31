import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flap/widgets/home.dart';
import 'package:flap/theme.dart';

Future<void> main() async {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.INFO;
  }
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('Dart ${record.level.name}: ${record.time}: ${record.message}');
  });
  Logger.root.onLevelChanged.listen((level) {
    // ignore: avoid_print
    print('The new log level is $level');
  });
  // GoogleFonts.config.allowRuntimeFetching = true;

  if (kIsWeb) {
    const runningOnWasm = bool.fromEnvironment('dart.tool.dart2wasm');
    Logger.root.info('${runningOnWasm ? 'WASM' : 'JS'} MODE');
  } else {
    Logger.root.info('NATIVE MODE');
  }
  Logger.root.info('OS: ${defaultTargetPlatform.name}');

  usePathUrlStrategy();

  // WidgetsFlutterBinding.ensureInitialized();
  // await GoogleFonts.pendingFonts([
  //   GoogleFonts.notoSansJpTextTheme(),
  //   GoogleFonts.notoColorEmoji(),
  // ]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'flap';
    return MaterialApp(
      title: title,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Home(title: title),
    );
  }
}
