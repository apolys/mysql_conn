
import 'package:flutter/material.dart';
import 'package:mysql_conn/common/theme/color/abs_theme_colors.dart';
import 'package:mysql_conn/common/theme/custom_theme.dart';
import 'package:mysql_conn/common/theme/shadows/abs_theme_shadows.dart';

import '../common.dart';

class CustomThemeHolder extends InheritedWidget {
  final AbstractThemeColors appColors;
  final AbsThemeShadows appShadows;
  final CustomTheme theme;
  final Function(CustomTheme) changeTheme;

  CustomThemeHolder({
    required Widget child,
    required this.theme,
    required this.changeTheme,
    Key? key,
  })  : appColors = theme.appColors,
        appShadows = theme.appShadows,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CustomThemeHolder oldWidget) {
    final old = oldWidget.theme;
    final current = theme;
    final need = old != current;
    return need;
  }

  static CustomThemeHolder of(BuildContext context) {
    CustomThemeHolder inherited =
    (context.dependOnInheritedWidgetOfExactType<CustomThemeHolder>())!;
    return inherited;
  }
}
