import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../features/user/cubit/user_cubit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _astronautIdController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _astronautIdController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<UserCubit>().register(
        _usernameController.text.trim(),
        _astronautIdController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this local profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
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
                            fontSize: 40,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          AppStrings.brandSubtitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space24),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius20,
                            ),
                            border: Border.all(color: AppColors.borderCyan),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Registration',
                                  style: AppTextStyles.title,
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                CustomInputField(
                                  label: 'Username',
                                  controller: _usernameController,
                                  hint: 'ASTRO_01',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Username is required'
                                      : null,
                                ),
                                const SizedBox(height: AppDimensions.space12),
                                CustomInputField(
                                  label: 'Astronaut ID',
                                  controller: _astronautIdController,
                                  hint: 'AST-0427',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Astronaut ID is required'
                                      : null,
                                ),
                                const SizedBox(height: AppDimensions.space20),
                                PrimaryButton(
                                  label: 'Register',
                                  onPressed: _register,
                                  expand: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
