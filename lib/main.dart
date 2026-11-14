import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/alert_repository.dart';
import 'data/repositories/health_data_repository.dart';
import 'features/alerts/cubit/alerts_cubit.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/user/cubit/user_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AstroXApp(database: AppDatabase()));
}

class AstroXApp extends StatelessWidget {
  const AstroXApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    final db = database;
    final healthRepository = HealthDataRepository(db);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AlertsCubit(
            repository: AlertRepository(db),
            healthRepository: healthRepository,
          )..load(),
        ),
        BlocProvider(create: (_) => UserCubit(database: db)),
      ],
      child: RepositoryProvider<AppDatabase>.value(
        value: db,
        child: MaterialApp(
          title: 'AstroX',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
