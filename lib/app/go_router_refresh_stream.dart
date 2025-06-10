// lib/app/go_router_refresh_stream.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that listens to a [Stream] and notifies listeners
/// on new stream events. This is useful for `GoRouter`'s `refreshListenable`.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Immediately notify to ensure the initial state is processed.
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
