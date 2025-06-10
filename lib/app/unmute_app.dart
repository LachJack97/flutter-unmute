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
            // This is the corrected creation logic.

            // 1. Create the repository instance, which handles talking to Supabase.
            final authRepository = AuthRepositoryImpl();

            // 2. Create an instance of each use case, passing the repository to them.
            final checkAuthStatus = CheckAuthStatus(authRepository);
            final loginUser = LoginUser(authRepository);
            final logoutUser = LogoutUser(authRepository);
            final signUpUser = SignUpUser(authRepository);

            // 3. Create the AuthBloc, providing the use cases it depends on.
            return AuthBloc(
              checkAuthStatus: checkAuthStatus,
              loginUser: loginUser,
              logoutUser: logoutUser,
              signUpUser: signUpUser,
            )..add(const AuthEvent.checkStatus()); // Dispatch the initial event
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
