import 'package:flutter/material.dart';
import 'error_widgets.dart';
import '../theme/app_colors.dart';

/// Simple loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Error widget with retry functionality
class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String? title;

  const CustomErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      error: error,
      onRetry: onRetry,
      title: title ?? 'Something went wrong',
    );
  }
}
