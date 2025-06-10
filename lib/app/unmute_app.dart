// lib/app/unmute_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/app/app_router.dart';
import 'package:unmute/core/theme/app_theme.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unmute/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:unmute/features/auth/domain/usecases/check_auth_status.dart';
import 'package:unmute/features/auth/domain/usecases/login_user.dart';
import 'package:unmute/features/auth/domain/usecases/logout_user.dart';
import 'package:unmute/features/auth/domain/usecases/sign_up_user.dart';

class UnmuteApp extends StatelessWidget {
  const UnmuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authRepository = AuthRepositoryImpl();
            final checkAuthStatus = CheckAuthStatus(authRepository);
            final loginUser = LoginUser(authRepository);
            final logoutUser = LogoutUser(authRepository);
            final signUpUser = SignUpUser(authRepository);

            // Create the AuthBloc and add the initial event.
            // We now use the `AuthAppStarted` class directly.
            return AuthBloc(
              checkAuthStatus: checkAuthStatus,
              loginUser: loginUser,
              logoutUser: logoutUser,
              signUpUser: signUpUser,
            )..add(const AuthAppStarted()); // Dispatch the initial event
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Unmute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
