import 'package:flutter/material.dart';

/// Generic state management for API calls
enum ApiState {
  initial,
  loading,
  success,
  error,
  empty,
}

/// State manager for API operations with UI feedback
class ApiStateManager<T> extends ChangeNotifier {
  ApiState _state = ApiState.initial;
  T? _data;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 1;

  // Getters
  ApiState get state => _state;
  T? get data => _data;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ApiState.loading;
  bool get hasError => _state == ApiState.error;
  bool get hasData => _data != null;
  bool get isEmpty => _state == ApiState.empty;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  /// Execute an API call with automatic state management
  Future<void> execute(
    Future<T> Function() apiCall, {
    bool showLoading = true,
    bool resetData = true,
  }) async {
    try {
      if (showLoading) {
        _setState(ApiState.loading);
      }
      
      if (resetData) {
        _data = null;
        _currentPage = 1;
        _hasMore = true;
      }

      final result = await apiCall();
      
      _data = result;
      _errorMessage = null;
      
      // Check if data is empty (for lists)
      if (result is List && (result as List).isEmpty) {
        _setState(ApiState.empty);
      } else {
        _setState(ApiState.success);
      }
    } catch (error) {
      _errorMessage = error.toString();
      _setState(ApiState.error);
    }
  }

  /// Execute paginated API call
  Future<void> executePaginated(
    Future<PaginatedApiResult<T>> Function(int page) apiCall, {
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh) {
        _setState(ApiState.loading);
        _currentPage = 1;
        _data = null;
      } else if (_currentPage == 1) {
        _setState(ApiState.loading);
      }

      final result = await apiCall(_currentPage);
      
      if (isRefresh || _currentPage == 1) {
        _data = result.data;
      } else {
        // Append data for pagination
        if (_data is List && result.data is List) {
          final currentList = List.from(_data as List);
          currentList.addAll(result.data as List);
          _data = currentList as T;
        }
      }
      
      _hasMore = result.hasMore;
      _currentPage++;
      _errorMessage = null;
      
      // Check if data is empty
      if (result.data is List && (result.data as List).isEmpty) {
        _setState(ApiState.empty);
      } else {
        _setState(ApiState.success);
      }
    } catch (error) {
      _errorMessage = error.toString();
      _setState(ApiState.error);
    }
  }

  /// Load next page for pagination
  Future<void> loadMore(
    Future<PaginatedApiResult<T>> Function(int page) apiCall,
  ) async {
    if (!_hasMore || isLoading) return;

    await executePaginated(apiCall, isRefresh: false);
  }

  /// Refresh data
  Future<void> refresh(
    Future<T> Function() apiCall,
  ) async {
    await execute(apiCall, resetData: true);
  }

  /// Clear state
  void clear() {
    _state = ApiState.initial;
    _data = null;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  /// Set error state
  void setError(String error) {
    _errorMessage = error;
    _setState(ApiState.error);
  }

  /// Set loading state
  void setLoading() {
    _setState(ApiState.loading);
  }

  /// Set success state with data
  void setSuccess(T data) {
    _data = data;
    _errorMessage = null;
    _setState(ApiState.success);
  }

  void _setState(ApiState newState) {
    _state = newState;
    notifyListeners();
  }
}

/// Result wrapper for paginated API calls
class PaginatedApiResult<T> {
  final T data;
  final bool hasMore;
  final int totalCount;
  final int currentPage;

  const PaginatedApiResult({
    required this.data,
    required this.hasMore,
    required this.totalCount,
    required this.currentPage,
  });
}

/// Widget builder for API states
class ApiStateBuilder<T> extends StatelessWidget {
  final ApiStateManager<T> stateManager;
  final Widget Function(BuildContext context, T data) onSuccess;
  final Widget Function(BuildContext context, String error)? onError;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context)? onEmpty;
  final VoidCallback? onRetry;

  const ApiStateBuilder({
    super.key,
    required this.stateManager,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onEmpty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stateManager,
      builder: (context, child) {
        switch (stateManager.state) {
          case ApiState.loading:
            return onLoading?.call(context) ?? 
                   const Center(child: CircularProgressIndicator());
          
          case ApiState.error:
            return onError?.call(context, stateManager.errorMessage ?? 'Unknown error') ??
                   _buildDefaultError(context);
          
          case ApiState.empty:
            return onEmpty?.call(context) ?? 
                   _buildDefaultEmpty(context);
          
          case ApiState.success:
            if (stateManager.data != null) {
              return onSuccess(context, stateManager.data!);
            }
            return _buildDefaultEmpty(context);
          
          case ApiState.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDefaultError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            stateManager.errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}