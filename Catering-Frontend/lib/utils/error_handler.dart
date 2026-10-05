import 'package:flutter/material.dart';
import '../services/api/api_exception.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Convert API exceptions to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.runtimeType) {
        case NetworkException:
          return 'No internet connection. Please check your network and try again.';
        case AuthenticationException:
          return 'Your session has expired. Please log in again.';
        case AuthorizationException:
          return 'You don\'t have permission to perform this action.';
        case ValidationException:
          final validationError = error as ValidationException;
          return validationError.allErrors.first;
        case NotFoundException:
          return 'The requested item was not found.';
        case RateLimitException:
          return 'Too many requests. Please wait a moment and try again.';
        case ServerException:
          return 'Server error occurred. Please try again later.';
        case TimeoutException:
          return error.message;
        default:
          return error.message;
      }
    }

    return error.toString();
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(dynamic error) {
    if (error is ApiException) {
      switch (error.runtimeType) {
        case NetworkException:
          return Icons.wifi_off;
        case AuthenticationException:
        case AuthorizationException:
          return Icons.lock_outline;
        case ValidationException:
          return Icons.error_outline;
        case NotFoundException:
          return Icons.search_off;
        case RateLimitException:
          return Icons.schedule;
        case ServerException:
          return Icons.cloud_off;
        case TimeoutException:
          return Icons.timer_off;
        default:
          return Icons.error_outline;
      }
    }

    return Icons.error_outline;
  }

  /// Get error color based on severity
  static Color getErrorColor(dynamic error) {
    if (error is ApiException) {
      switch (error.runtimeType) {
        case NetworkException:
        case TimeoutException:
          return Colors.orange;
        case AuthenticationException:
        case AuthorizationException:
          return Colors.red;
        case ValidationException:
          return Colors.amber;
        case NotFoundException:
          return Colors.blue;
        case RateLimitException:
          return Colors.purple;
        case ServerException:
          return Colors.red;
        default:
          return Colors.red;
      }
    }

    return Colors.red;
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    final icon = getErrorIcon(error);
    final color = getErrorColor(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info message
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    final message = getErrorMessage(error);
    final icon = getErrorIcon(error);
    final color = getErrorColor(error);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 32),
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('RETRY'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show validation errors dialog
  static Future<void> showValidationErrorsDialog(
    BuildContext context,
    ValidationException error,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.amber, size: 32),
        title: const Text('Validation Errors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            const SizedBox(height: 8),
            ...error.allErrors.map((errorMsg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(errorMsg)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle API errors with automatic UI feedback
  static Future<T?> handleApiCall<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    String? successMessage,
    String? errorTitle,
    bool showErrorDialog = false,
    bool showSuccess = true,
    VoidCallback? onRetry,
  }) async {
    try {
      final result = await apiCall();

      if (successMessage != null && showSuccess) {
        showSuccessSnackBar(context, successMessage);
      }

      return result;
    } catch (error) {
      if (showErrorDialog) {
        await ErrorHandler.showErrorDialog(
          context,
          error,
          title: errorTitle,
          onRetry: onRetry,
        );
      } else if (error is ValidationException) {
        await showValidationErrorsDialog(context, error);
      } else {
        showErrorSnackBar(context, error);
      }

      return null;
    }
  }

  /// Check if error requires re-authentication
  static bool requiresReauth(dynamic error) {
    return error is AuthenticationException;
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error is NetworkException || error is TimeoutException;
  }

  /// Check if error is user recoverable
  static bool isRecoverable(dynamic error) {
    if (error is ApiException) {
      switch (error.runtimeType) {
        case NetworkException:
        case TimeoutException:
        case RateLimitException:
        case ServerException:
          return true;
        default:
          return false;
      }
    }
    return false;
  }
}
