import 'package:flutter/material.dart';

import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'app_loading_view.dart';

/// Unified loading / error / empty / data builder for async UI.
class AsyncStateBuilder<T> extends StatelessWidget {
  const AsyncStateBuilder({
    required this.isLoading,
    required this.data,
    required this.builder,
    this.isEmpty,
    this.loading,
    this.errorMessage,
    this.onRetry,
    this.empty,
    super.key,
  });

  final bool isLoading;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final Widget? loading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return loading ?? const AppLoadingView();
    }

    if (errorMessage != null && onRetry != null) {
      return AppErrorState(
        title: 'Gagal memuat',
        message: errorMessage!,
        onRetry: onRetry!,
      );
    }

    final value = data;
    if (value == null) {
      return empty ?? const AppLoadingView();
    }

    if (isEmpty != null && isEmpty!(value)) {
      return empty ?? const SizedBox.shrink();
    }

    return builder(context, value);
  }
}
