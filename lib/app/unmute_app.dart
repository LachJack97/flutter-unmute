// lib/app/unmute_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unmute/app/go_router_refresh_stream.dart'; // Import the new utility
import 'package:unmute/core/theme/app_theme.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unmute/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:unmute/features/auth/domain/usecases/check_auth_status.dart';
import 'package:unmute/features/auth/domain/usecases/login_user.dart';
import 'package:unmute/features/auth/domain/usecases/logout_user.dart';
import 'package:unmute/features/auth/domain/usecases/sign_up_user.dart';
// Import pages and other necessary components for router configuration
import 'package:unmute/features/auth/presentation/pages/login_page.dart';
import 'package:unmute/features/auth/presentation/pages/register_page.dart';
import 'package:unmute/features/auth/presentation/pages/check_email_page.dart';
import 'package:unmute/features/chat/presentation/pages/chat_page.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart'; // Import PhraseBookBloc
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart'; // Import PhraseBookEvent
import 'package:unmute/features/chat/presentation/pages/phrase_book_page.dart'; // Import PhraseBookPage
import 'package:unmute/features/chat/data/repositories/chat_service.dart';

class UnmuteApp extends StatefulWidget {
  const UnmuteApp({super.key});

  @override
  State<UnmuteApp> createState() => _UnmuteAppState();
}

class _UnmuteAppState extends State<UnmuteApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final PhraseBookBloc _phraseBookBloc; // Declare PhraseBookBloc
  late final GoRouterRefreshStream _authBlocRefreshStream;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepositoryImpl();
    _authBloc = AuthBloc(
      checkAuthStatus: CheckAuthStatus(authRepository),
      loginUser: LoginUser(authRepository),
      logoutUser: LogoutUser(authRepository),
      signUpUser: SignUpUser(authRepository),
    )..add(const AuthAppStarted());

    _authBlocRefreshStream = GoRouterRefreshStream(_authBloc.stream);

    // Initialize PhraseBookBloc
    final chatService =
        ChatService(); // You might already have this instance or create a new one
    _phraseBookBloc = PhraseBookBloc(chatService: chatService)
      ..add(const LoadFavoritePhrases());

    _router = GoRouter(
      initialLocation: '/login', // Initial route
      refreshListenable: _authBlocRefreshStream,
      redirect: (BuildContext context, GoRouterState state) {
        final authState = _authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;

        final publicRoutes = ['/login', '/register', '/check-email'];
        final isOnPublicRoute = publicRoutes.contains(state.matchedLocation);

        // Debugging prints (optional, can be removed after verification)
        debugPrint(// Changed print to debugPrint
            '[GoRouter Redirect] AuthState: $authState, Location: ${state.matchedLocation}, IsLoggedIn: $isLoggedIn, IsOnPublicRoute: $isOnPublicRoute');

        if (!isLoggedIn && !isOnPublicRoute) {
          // If not logged in and trying to access a protected route, redirect to login
          debugPrint(
              '[GoRouter Redirect] Not logged in, redirecting to /login'); // Changed print to debugPrint
          return '/login';
        }
        if (isLoggedIn && isOnPublicRoute) {
          // If logged in and on a public route (e.g., login page), redirect to chat
          debugPrint(// Changed print to debugPrint
              '[GoRouter Redirect] Logged in, on public page, redirecting to /chat');
          return '/chat';
        }
        // No redirect needed
        return null;
      },
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
              // Provide ChatBloc specifically for ChatPage
              create: (context) {
                final chatService = ChatService();
                return ChatBloc(
                  chatService: chatService,
                )..add(const SubscriptionRequested());
              },
              child: const ChatPage(),
            );
          },
        ),
        GoRoute(
          path: '/phrase-book',
          builder: (context, state) => const PhraseBookPage(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _phraseBookBloc.close(); // Dispose PhraseBookBloc
    _authBlocRefreshStream.dispose();
    // _router.dispose(); // GoRouter itself doesn't have a public dispose method.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<PhraseBookBloc>.value(
            value: _phraseBookBloc), // Provide PhraseBookBloc
      ],
      child: MaterialApp.router(
        title: 'Unmute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
