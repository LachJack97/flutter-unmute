import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart'; // <--- Make sure to import ChatEvent
import 'package:unmute/features/chat/presentation/pages/chat_page.dart';
import 'package:unmute/features/auth/presentation/pages/login_page.dart';
import 'package:unmute/features/auth/presentation/pages/register_page.dart';
import 'package:unmute/features/auth/presentation/pages/check_email_page.dart';

// The unused use case imports have been removed.

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
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
          create: (context) {
            final chatService = ChatService();
            return ChatBloc(
              chatService: chatService,
            )..add(const SubscriptionRequested()); // <--- CORRECTED LINE HERE
          },
          child: const ChatPage(),
        );
      },
    ),
  ],
);
