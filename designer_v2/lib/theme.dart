import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class const DropdownMenuItemTheme({final IconThemeData? iconTheme})
    with Diagnosticable;

class ThemeConfig() {
  static const double kMinContentWidth = 600.0;
  static const double kMaxContentWidth = 1264.0;

  static const double kHoverFadeFactor = 0.7;
  static const double kMuteFadeFactor = 0.8;

  static Color bodyBackgroundColor(ThemeData theme) =>
      theme.scaffoldBackgroundColor.withValues(alpha: 0.5);

  static Color modalBarrierColor(ThemeData theme) =>
      theme.colorScheme.secondary.withValues(alpha: 0.4);

  static Color containerColor(ThemeData theme) =>
      theme.colorScheme.secondaryContainer.withValues(alpha: 0.3);

  static Color colorPickerInitialColor(ThemeData theme) =>
      theme.colorScheme.primary;

  static TextStyle bodyTextMuted(ThemeData theme) => TextStyle(
    fontSize: 14.0,
    height: 1.35,
    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.65),
  );

  static TextStyle bodyTextBackground(ThemeData theme) => TextStyle(
    fontSize: 14.0,
    height: 1.35,
    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
  );

  static double iconSplashRadius(ThemeData theme) => 24.0;

  static Color sidesheetBackgroundColor(ThemeData theme) =>
      theme.scaffoldBackgroundColor.withValues(alpha: 0.15);

  static InputDecorationThemeData dropdownInputDecorationTheme(
    ThemeData theme,
  ) => theme.inputDecorationTheme.copyWith(
    contentPadding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 14.0),
  );

  static DropdownMenuItemTheme dropdownMenuItemTheme(ThemeData theme) =>
      DropdownMenuItemTheme(
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.4),
          size: 18.0,
        ),
      );
}

class const NoAnimationPageTransitionsBuilder() extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class const WebTransitionBuilder() extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final opacityOldTween = Tween(
      begin: 1.0,
      end: 0.0,
    ).chain(CurveTween(curve: Curves.easeIn));
    final opacityNewTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeIn));

    return FadeTransition(
      opacity: opacityOldTween.animate(secondaryAnimation),
      child: FadeTransition(
        opacity: opacityNewTween.animate(animation),
        child: child,
      ),
    );
  }
}

class ThemeSettingChange({required final ThemeSettings settings})
    extends Notification;

// ignore: prefer_const_constructors_in_immutables
class ThemeProvider({
  super.key,
  required final ValueNotifier<ThemeSettings> settings,
  required final ColorScheme? lightDynamic,
  required final ColorScheme? darkDynamic,
  required super.child,
}) extends InheritedWidget {
  final pageTransitionsTheme = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      // Only populates the map if running on Web
      if (kIsWeb)
        for (final platform in TargetPlatform.values)
          platform: const WebTransitionBuilder(),
    },
  );

  /*
  // Keep this in case we want to add custom animations for other platforms in the future
  final pageTransitionsTheme = PageTransitionsTheme(
    builders: kIsWeb
        ? <TargetPlatform, PageTransitionsBuilder>{
            // Animation when running on Web
            for (final platform in TargetPlatform.values)
              platform: const WebTransitionBuilder(),
          }
        : const <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
          },
  );*/

  Color custom(CustomColor custom) {
    if (custom.blend) {
      return blend(custom.color);
    } else {
      return custom.color;
    }
  }

  Color blend(Color targetColor) {
    return Color(
      Blend.harmonize(
        targetColor.toARGB32(),
        settings.value.sourceColor.toARGB32(),
      ),
    );
  }

  Color source(Color? target) {
    Color source = settings.value.sourceColor;
    if (target != null) {
      source = blend(target);
    }
    return source;
  }

  ColorScheme colors(Brightness brightness, Color? targetColor) {
    final dynamicPrimary = brightness == Brightness.light
        ? lightDynamic?.primary
        : darkDynamic?.primary;
    final scheme = SchemeFidelity(
      sourceColorHct: dynamicPrimary != null
          ? Hct.fromInt(dynamicPrimary.toARGB32())
          : Hct.fromInt(source(targetColor).toARGB32()),
      isDark: false,
      contrastLevel: 0.0,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: dynamicPrimary ?? source(targetColor),
      brightness: brightness,
    );
    return colorScheme.copyWith(
      primary: Color(MaterialDynamicColors.primary.getArgb(scheme)),
    );
  }

  ShapeBorder get shapeMedium =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  CardThemeData cardThemeData() {
    return CardThemeData(
      elevation: 0,
      shape: shapeMedium,
      clipBehavior: Clip.antiAlias,
    );
  }

  ListTileThemeData listTileTheme(ColorScheme colors) {
    return ListTileThemeData(
      shape: shapeMedium,
      style: ListTileStyle.drawer,
      selectedColor: colors.primary,
    );
  }

  AppBarTheme appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      elevation: 2,
      //backgroundColor: Colors.transparent,
      //backgroundColor: colors.surface.withValues(alpha: 0.1),
      backgroundColor: Colors.white,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.white,
      shadowColor: colors.primaryContainer.withValues(alpha: 0.3),
      /*
      shape: Border(
          bottom: BorderSide(
              color: colors.secondary.withValues(alpha: 0.1),
              width: 1
          )
      ),
       */
    );
  }

  SnackBarThemeData snackBarThemeData(ColorScheme colors) {
    return SnackBarThemeData(
      actionTextColor: colors.onPrimary,
      backgroundColor: colors.primary,
      elevation: 1,
    );
  }

  TabBarThemeData tabBarThemeData(ColorScheme colors) {
    return TabBarThemeData(
      labelColor: colors.primary,
      unselectedLabelColor: colors.onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.primary, width: 2)),
      ),
    );
  }

  BottomAppBarThemeData bottomAppBarThemeData(ColorScheme colors) {
    return BottomAppBarThemeData(color: colors.surface, elevation: 0);
  }

  BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.surfaceContainerHighest,
      selectedItemColor: colors.onSurface,
      unselectedItemColor: colors.onSurfaceVariant,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  SwitchThemeData switchTheme(ColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return colors.primary.withValues(alpha: 0.6);
          }
          return colors.primary;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withValues(alpha: 0.6);
        }
        return Colors.white;
      }),
      trackColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return colors.primary.withValues(alpha: 0.5 * 0.6);
          }
          return colors.primary.withValues(alpha: 0.5);
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: 0.3 * 0.6);
        }
        return colors.onSurface.withValues(alpha: 0.3);
      }),
    );
  }

  InputDecorationTheme inputDecorationTheme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hoverColor: Colors.white,
      focusColor: Colors.white,
      isDense: true,
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: colors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: colors.error),
      ),
    );
  }

  TextTheme textTheme(ColorScheme colors) {
    // TODO: migrate to 2021 term set across the codebase
    // See https://stackoverflow.com/questions/72271461/cannot-mix-2018-and-2021-terms-in-call-to-texttheme-constructor
    final headlineColor = colors.onSurfaceVariant;

    return TextTheme(
      labelLarge: TextStyle(
        fontSize: 14.0,
        color: colors.onSurface.withValues(alpha: 0.9),
      ),
      bodySmall: TextStyle(
        fontSize: 14.0,
        height: 1.35,
        //withOpacity(0.9)
        color: colors.onSurface.withValues(alpha: 0.9),
      ), // Form Labels
      titleMedium: TextStyle(
        fontSize: 14.0,
        height: 1.35,
        color: colors.onSurface.withValues(alpha: 0.9),
      ), // TextInput
      bodyLarge: TextStyle(
        fontSize: 14.0,
        height: 1.35,
        color: colors.onSurface.withValues(alpha: 0.9),
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        height: 1.35,
        color: colors.onSurface.withValues(alpha: 0.8),
      ),
      titleLarge: TextStyle(
        fontSize: 15.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 22.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: 26.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 36.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
      displayLarge: TextStyle(
        fontSize: 48.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  DividerThemeData dividerTheme(ColorScheme colors) {
    return DividerThemeData(
      thickness: 0.5,
      color: colors.onPrimaryContainer.withValues(alpha: 0.15),
    );
  }

  NavigationRailThemeData navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  DrawerThemeData drawerTheme(ColorScheme colors) {
    return const DrawerThemeData();
  }

  IconThemeData iconTheme(ColorScheme colors) {
    return IconThemeData(color: colors.onSurface, opacity: 0.8, size: 17.0);
  }

  CheckboxThemeData checkboxTheme(ColorScheme colors) {
    return CheckboxThemeData(
      splashRadius: 18.0,
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return colors.primary.withValues(alpha: 0.5 * 1.0);
          }
          return colors.primary.withValues(alpha: 1.0);
        }
        return Colors.transparent;
      }),
      side: BorderSide(
        color: colors.secondary.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );
  }

  RadioThemeData radioTheme(ColorScheme colors) {
    return RadioThemeData(
      splashRadius: 18.0,
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: 0.9);
        }
        return null;
      }),
    );
  }

  TooltipThemeData tooltipTheme(ColorScheme colors) {
    return TooltipThemeData(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 11.0),
      textStyle: textTheme(colors).bodySmall!.copyWith(color: colors.onPrimary),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(2.0),
        boxShadow: [
          BoxShadow(
            color: colors.primaryContainer.withValues(alpha: 0.1),
            blurRadius: 1,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: colors.secondary.withValues(alpha: 0.3),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  ThemeData light([Color? targetColor]) {
    final colorScheme = colors(Brightness.light, targetColor);
    return ThemeData.light().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardThemeData(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarThemeData(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarThemeData(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      snackBarTheme: snackBarThemeData(colorScheme),
      scaffoldBackgroundColor: colorScheme.primaryContainer.withValues(
        alpha: 0.15,
      ),
      dividerTheme: dividerTheme(colorScheme),
      //splashColor: colorScheme.secondary.withValues(alpha: 0.4),
      //highlightColor: colorScheme.secondary.withValues(alpha: 0.3),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      switchTheme: switchTheme(colorScheme),
      textTheme: textTheme(colorScheme),
      iconTheme: iconTheme(colorScheme),
      checkboxTheme: checkboxTheme(colorScheme),
      radioTheme: radioTheme(colorScheme),
      tooltipTheme: tooltipTheme(colorScheme),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.5),
      shadowColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
    );
  }

  ThemeData dark([Color? targetColor]) {
    final colorScheme = colors(Brightness.dark, targetColor);
    return ThemeData.dark().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardThemeData(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarThemeData(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarThemeData(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      snackBarTheme: snackBarThemeData(colorScheme),
      scaffoldBackgroundColor: colorScheme.surface,
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      switchTheme: switchTheme(colorScheme),
      textTheme: textTheme(colorScheme),
      iconTheme: iconTheme(colorScheme),
      checkboxTheme: checkboxTheme(colorScheme),
      radioTheme: radioTheme(colorScheme),
      tooltipTheme: tooltipTheme(colorScheme),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.5),
      shadowColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
    );
  }

  ThemeMode themeMode() {
    return settings.value.themeMode;
  }

  ThemeData theme(BuildContext context, [Color? targetColor]) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? light(targetColor)
        : dark(targetColor);
  }

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant ThemeProvider oldWidget) {
    return oldWidget.settings != settings;
  }
}

class ThemeSettings({
  required final Color sourceColor,
  required final ThemeMode themeMode,
});

Color randomColor() {
  return Color(Random().nextInt(0xFFFFFFFF));
}

// Custom Colors
const linkColor = CustomColor(name: 'Link Color', color: Color(0xFF00B0FF));

class const CustomColor({
  required final String name,
  required final Color color,
  final bool blend = true,
}) {
  Color value(ThemeProvider provider) {
    return provider.custom(this);
  }
}
