import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';

class ArborThemeData {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,

    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.transparent,
    brightness: Brightness.light,
    canvasColor: Colors.grey,

    highlightColor: Colors.transparent,
    dividerColor: Colors.grey,
    iconTheme: const IconThemeData(color: Colors.black),
    fontFamily: 'GalleryIcons',

    appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.white,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
    ),
    accentColor: const Color(0xFF1F1F1F),
    colorScheme: ColorScheme.light(
      primary: ArborColors.green,
      secondary: const Color(0xffFDEFFD),
      //primaryVariant: PokerColors.purple,
      secondaryVariant: Colors.black,
      //onPrimary: PokerColors.purple,
      background: ArborColors.green,
      //error: TolaColours.white,
      surface: Colors.white,
      onSurface: Colors.grey[400]!,
    ),
    //textTheme: _lightTextTheme,
  );

/*static final ThemeData darkTheme = ThemeData(
    primaryColor: PokerColors.black,
    primarySwatch: MaterialColor(
      0xFF000000,
      const <int, Color>{
        50: const Color(0xFF000000),
        100: const Color(0xFF000000),
        200: const Color(0xFF000000),
        300: const Color(0xFF000000),
        400: const Color(0xFF000000),
        500: const Color(0xFF000000),
        600: const Color(0xFF000000),
        700: const Color(0xFF000000),
        800: const Color(0xFF000000),
        900: const Color(0xFF000000),
      },
    ),
    scaffoldBackgroundColor: PokerColors.black,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    brightness: Brightness.dark,
    canvasColor: Colors.white,
    dividerColor: PokerColors.hintTextColor,
    textSelectionColor: PokerColors.white.withOpacity(0.2),
    textSelectionHandleColor: PokerColors.white,
    iconTheme: IconThemeData(color: PokerColors.white),
    fontFamily: 'DMSans',
    appBarTheme: AppBarTheme(
      color: PokerColors.black,
      iconTheme: IconThemeData(color: PokerColors.white),
    ),
    accentColor: Color(0xFF1F1F1F),
    colorScheme: ColorScheme.dark(
      primary: Color(0xff85C341),
      secondary: Color(0xff1E1E1E),
      primaryVariant: PokerColors.green,
      secondaryVariant: PokerColors.purple,
      onPrimary: PokerColors.green,
      background: PokerColors.black,
      error: PokerColors.error,
      surface: Color(0xff3F3F3F),
      onSurface: PokerColors.white,
    ),
    //textTheme: _darkTextTheme,
  );*/
}
