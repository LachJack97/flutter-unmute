import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          // --- THIS IS THE CORRECTED LINE ---
          // It now correctly accepts a single 'user' object of type UserEntity.
          authenticated: (user) {
            context.go('/chat');
          },
          unauthenticated: () {
            context.go('/login');
          },
        );
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
