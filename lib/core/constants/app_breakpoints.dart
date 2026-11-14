import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double mobile = 800;
  static const double desktop = 1200;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

enum AppLayoutSize { mobile, tablet, desktop }

abstract final class LayoutHelper {
  static AppLayoutSize sizeFor(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    if (AppBreakpoints.isMobile(width)) return AppLayoutSize.mobile;
    if (AppBreakpoints.isTablet(width)) return AppLayoutSize.tablet;
    return AppLayoutSize.desktop;
  }

  static int contentColumns(AppLayoutSize size) {
    return switch (size) {
      AppLayoutSize.mobile => 1,
      AppLayoutSize.tablet => 2,
      AppLayoutSize.desktop => 3,
    };
  }
}
