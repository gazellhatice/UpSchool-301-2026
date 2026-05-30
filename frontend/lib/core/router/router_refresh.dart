import 'dart:async';

import 'package:flutter/foundation.dart';

/// Auth stream değişince go_router redirect'lerini yeniler.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
