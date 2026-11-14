import 'package:flutter/material.dart';

enum AppRoute { dashboard, dailyCheckIn, trends, alerts, assistant }

class NavDestination {
  const NavDestination({
    required this.route,
    required this.label,
    required this.icon,
    this.badgeKey,
  });

  final AppRoute route;
  final String label;
  final IconData icon;
  final String? badgeKey;
}

abstract final class NavDestinations {
  static const List<NavDestination> all = [
    NavDestination(
      route: AppRoute.dashboard,
      label: 'Dashboard',
      icon: Icons.home_outlined,
    ),
    NavDestination(
      route: AppRoute.dailyCheckIn,
      label: 'Daily check-in',
      icon: Icons.fact_check_outlined,
    ),
    NavDestination(
      route: AppRoute.trends,
      label: 'Trends',
      icon: Icons.show_chart_outlined,
    ),
    NavDestination(
      route: AppRoute.alerts,
      label: 'Alerts',
      icon: Icons.notifications_none_outlined,
      badgeKey: 'alerts',
    ),

    NavDestination(
      route: AppRoute.assistant,
      label: 'Assistant',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  static const List<AppRoute> mobilePrimary = [
    AppRoute.dashboard,
    AppRoute.dailyCheckIn,
    AppRoute.trends,
    AppRoute.alerts,
  ];

  static NavDestination byRoute(AppRoute route) {
    return all.firstWhere((item) => item.route == route);
  }

  static String titleFor(AppRoute route) {
    return switch (route) {
      AppRoute.dashboard => 'Good morning, ASTRO_01',
      AppRoute.dailyCheckIn => 'Daily check-in',
      AppRoute.trends => 'Trends',
      AppRoute.alerts => 'Alert and guidance',
      AppRoute.assistant => 'Assistant',
    };
  }

  static String subtitleFor(AppRoute route) {
    return switch (route) {
      AppRoute.dashboard => 'Your latest saved health at a glance.',
      AppRoute.dailyCheckIn =>
        'Complete your daily health measurements and track how you feel.',
      AppRoute.trends => 'Track how your health measurements change over time compared with your personal baseline.',
      AppRoute.alerts => 'Review health alerts, understand what changed, and follow recommended actions.',
      AppRoute.assistant => 'Get assistance with your health readings and daily check-in information.',
    };
  }
}
