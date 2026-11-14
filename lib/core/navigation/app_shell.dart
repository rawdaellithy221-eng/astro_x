import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../routing/app_route.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/health_metric_id.dart';
import '../../features/alerts/cubit/alerts_cubit.dart';
import '../../features/user/cubit/user_cubit.dart';
import '../../features/alerts/view/alerts_screen.dart';
import '../../features/assistant/view/assistant_screen.dart';
import '../../features/dashboard/view/dashboard_screen.dart';
import '../../features/daily_check_in/view/daily_check_in_screen.dart';
import '../../features/trends/view/trends_screen.dart';
import '../../features/registration/view/registration_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppRoute _route = AppRoute.dashboard;
  String? _trendsAreaFilter;
  HealthMetricId? _trendsInitialMetric;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<UserCubit>().state.userId;
    if (userId != null) {
      context.read<AlertsCubit>().bind(userId);
    }
  }

  void _navigate(AppRoute route) {
    if (route == AppRoute.trends) {
      _trendsAreaFilter = null;
      _trendsInitialMetric = null;
    }
    setState(() => _route = route);
    Navigator.of(context).maybePop();
  }

  void _openTrends({String? areaFilter, HealthMetricId? metric}) {
    setState(() {
      _trendsAreaFilter = areaFilter;
      _trendsInitialMetric = metric;
      _route = AppRoute.trends;
    });
    Navigator.of(context).maybePop();
  }

  Widget _screenFor(AppRoute route) {
    return switch (route) {
      AppRoute.dashboard => DashboardScreen(
        onNavigateToAlerts: () => _navigate(AppRoute.alerts),
        onOpenTrends: _openTrends,
      ),
      AppRoute.dailyCheckIn => const DailyCheckInScreen(),
      AppRoute.trends => TrendsScreen(
        areaFilter: _trendsAreaFilter,
        initialMetric: _trendsInitialMetric,
      ),
      AppRoute.alerts => const AlertsScreen(),
      AppRoute.assistant => const AssistantScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listenWhen: (previous, current) => previous.userId != current.userId,
      listener: (context, state) {
        final userId = state.userId;
        if (userId != null) {
          context.read<AlertsCubit>().bind(userId);
        }
      },
      builder: (context, userState) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final mobile = AppBreakpoints.isMobile(width);
            final tablet = AppBreakpoints.isTablet(width);

            // Recreate the active screen when the route or signed-in user changes.
            // Without this, a cubit created before the user finishes loading keeps
            // a null/stale userId and silently skips saves.
            Widget content = KeyedSubtree(
              key: ValueKey('${_route.name}:${userState.userId}'),
              child: _screenFor(_route),
            );

            final header = BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                final title = _route == AppRoute.dashboard
                    ? 'Good morning, ${userState.username}'
                    : NavDestinations.titleFor(_route);
                return AppHeader(
                  title: title,
                  subtitle: NavDestinations.subtitleFor(_route),
                  onNotificationTap: () => _navigate(AppRoute.alerts),
                  onSwitchUser: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const RegistrationScreen(),
                    ),
                  ),
                  onMenuTap: mobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                );
              },
            );

            if (mobile) {
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: AppColors.background,
                drawer: _buildDrawer(),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _mobileIndex(),
                  onTap: (i) {
                    if (i < NavDestinations.mobilePrimary.length) {
                      _navigate(NavDestinations.mobilePrimary[i]);
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.sidebar,
                  selectedItemColor: AppColors.cyan,
                  unselectedItemColor: AppColors.textMuted,
                  items: NavDestinations.mobilePrimary
                      .map(
                        (r) => BottomNavigationBarItem(
                          icon: Icon(NavDestinations.byRoute(r).icon),
                          label: NavDestinations.byRoute(r).label,
                        ),
                      )
                      .toList(),
                ),
                body: Column(
                  children: [
                    header,
                    Expanded(child: content),
                  ],
                ),
              );
            }

            final sidebarWidth = tablet
                ? AppDimensions.sidebarCompactWidth
                : AppDimensions.sidebarWidth;
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              body: Row(
                children: [
                  SizedBox(
                    width: sidebarWidth,
                    child: _Sidebar(
                      selected: _route,
                      compact: tablet,
                      onSelect: _navigate,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        header,
                        Expanded(child: content),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _mobileIndex() {
    final i = NavDestinations.mobilePrimary.indexOf(_route);
    return i < 0 ? 0 : i;
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.sidebar,
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.appName,
                style: AppTextStyles.title.copyWith(color: AppColors.cyan),
              ),
            ),
            ...NavDestinations.all.map(
              (d) => ListTile(
                leading: Icon(
                  d.icon,
                  color: _route == d.route
                      ? AppColors.cyan
                      : AppColors.textSecondary,
                ),
                title: Text(d.label, style: AppTextStyles.bodyStrong),
                selected: _route == d.route,
                onTap: () => _navigate(d.route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.compact,
    required this.onSelect,
  });

  final AppRoute selected;
  final bool compact;
  final ValueChanged<AppRoute> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: compact
                ? const Icon(Icons.rocket_launch, color: AppColors.cyan)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.brandTitle,
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                      Text(
                        AppStrings.brandSubtitle,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: NavDestinations.all.map((d) {
                final isSelected = selected == d.route;
                return InkWell(
                  onTap: () => onSelect(d.route),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 0 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.sidebarSelected
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.borderCyan
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: compact
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          d.icon,
                          color: isSelected
                              ? AppColors.cyan
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              d.label,
                              style: AppTextStyles.nav.copyWith(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (d.badgeKey == 'alerts')
                            BlocBuilder<AlertsCubit, AlertsState>(
                              builder: (context, state) {
                                final count = state.alerts
                                    .where((a) => a.isUnread)
                                    .length;
                                if (count == 0) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
