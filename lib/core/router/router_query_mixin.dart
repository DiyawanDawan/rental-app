import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Jalankan inisialisasi yang butuh [GoRouterState] setelah inherited widget siap.
mixin RouterQueryMixin<T extends StatefulWidget> on State<T> {
  bool _routerQueryReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routerQueryReady) return;
    _routerQueryReady = true;
    onRouterQueryReady(GoRouterState.of(context).uri.queryParameters);
  }

  void onRouterQueryReady(Map<String, String> queryParameters);
}
