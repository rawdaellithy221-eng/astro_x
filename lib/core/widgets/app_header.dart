import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../../features/alerts/cubit/alerts_cubit.dart';
import '../../features/user/cubit/user_cubit.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onNotificationTap,
    this.onMenuTap,
    this.onSwitchUser,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSwitchUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.display.copyWith(fontSize: 22),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          BlocBuilder<AlertsCubit, AlertsState>(
            builder: (context, state) {
              final unread = state.alerts.where((a) => a.isUnread).length;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 14, color: AppColors.green),
                  const SizedBox(width: 6),
                  Text('Works offline', style: AppTextStyles.caption),
                  const SizedBox(width: 12),
                  Text('Last Earth sync 09:12', style: AppTextStyles.caption),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onNotificationTap,
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none_outlined,
                          color: AppColors.textSecondary,
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, userState) {
                      return InkWell(
                        onTap: onSwitchUser,
                        borderRadius: BorderRadius.circular(20),
                        child: Tooltip(
                          message: 'Switch user',
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.cyanMuted,
                            child: Text(
                              userState.initials,
                              style: const TextStyle(
                                color: AppColors.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
