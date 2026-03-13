import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ThemeData(brightness: Brightness.light).colorScheme.copyWith(
      primary: Color.fromARGB(255, 0, 0, 0),
      surface: Color.fromARGB(255, 255, 255, 255),
      onSurface: Color.fromARGB(255, 0, 0, 0),
      onSurfaceVariant: Color.fromARGB(255, 120, 120, 120),
      surfaceContainer: Color.fromARGB(255, 255, 255, 255),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 246, 246, 246),
      shape: CircleBorder(
        // side: BorderSide(color: Color.fromARGB(255, 205, 205, 205)),
      ),
    ),
    useMaterial3: true,
    fontFamily: kIsWeb ? 'NotoSansJP' : null,
    fontFamilyFallback: kIsWeb ? ['NotoColorEmoji'] : null,
    // textTheme: kIsWeb
    //     ? GoogleFonts.notoSansJpTextTheme(
    //         ThemeData(brightness: Brightness.light).textTheme)
    //     : null,
  );

  static final darkTheme = ThemeData(
    colorScheme: ThemeData(brightness: Brightness.dark).colorScheme.copyWith(
      primary: Color.fromARGB(255, 255, 255, 255),
      surface: Color.fromARGB(255, 0, 0, 0),
      onSurface: Color.fromARGB(255, 244, 244, 244),
      onSurfaceVariant: Color.fromARGB(255, 129, 129, 129),
      surfaceContainer: Color.fromARGB(255, 0, 0, 0),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 33, 33, 33),
      shape: CircleBorder(
        // side: BorderSide(color: Color.fromARGB(255, 86, 86, 86)),
      ),
    ),
    appBarTheme: ThemeData(brightness: Brightness.dark).appBarTheme.copyWith(
      // TODO:
    ),
    useMaterial3: true,
    fontFamily: kIsWeb ? 'NotoSansJP' : null,
    fontFamilyFallback: kIsWeb ? ['NotoColorEmoji'] : null,
    // textTheme: kIsWeb
    //     ? GoogleFonts.notoSansJpTextTheme(
    //         ThemeData(brightness: Brightness.dark).textTheme)
    //     : null,
  );
}
