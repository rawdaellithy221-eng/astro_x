import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../registration/view/registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.brandTitle,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.cyan,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'AstroX',
              style: AppTextStyles.display.copyWith(
                fontSize: 52,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              AppStrings.brandSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.cyan,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text('Preparing mission systems...', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
