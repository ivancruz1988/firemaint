import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adaptador estandar de go_router: convierte un [Stream] en un [Listenable]
/// para que `GoRouter.redirect` se vuelva a evaluar cuando cambia la sesion.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
