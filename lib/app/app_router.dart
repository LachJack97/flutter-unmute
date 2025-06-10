import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart'; // Keep this
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart'; // Keep this
import 'package:unmute/features/chat/presentation/pages/chat_page.dart'; // Keep this
import 'package:unmute/features/auth/presentation/pages/login_page.dart';
import 'package:unmute/features/auth/presentation/pages/register_page.dart';
//import 'package:unmute/features/auth/presentation/pages/splash_page.dart'; // Corrected path
import 'package:unmute/features/auth/presentation/pages/check_email_page.dart';

// The unused use case imports have been removed.

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // GoRoute(
    //   path: '/splash',
    //   builder: (context, state) => const SplashPage(),
    // ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/check-email',
      builder: (context, state) => const CheckEmailPage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        return BlocProvider(
          // --- THIS IS THE CORRECTED PART ---
          create: (context) {
            // We now only need to create our ChatService.
            final chatService = ChatService();

            // Then, we create the ChatBloc and pass the single service it needs.
            return ChatBloc(
              chatService: chatService,
            )..add(const ChatEvent
                .subscriptionRequested()); // Start listening to messages
          },
          child: const ChatPage(),
        );
      },
    ),
  ],
);
