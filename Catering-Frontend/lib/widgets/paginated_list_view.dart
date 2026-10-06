import 'package:flutter/material.dart';

/// A reusable paginated list view that loads items incrementally
class PaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int perPage) loadItems;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function()? errorBuilder;
  final int initialItemCount;
  final int itemsPerPage;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final Widget? header;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PaginatedListView({
    super.key,
    required this.loadItems,
    required this.itemBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.initialItemCount = 15,
    this.itemsPerPage = 15,
    this.scrollController,
    this.padding,
    this.header,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final List<T> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  bool _showingSeeAll = false;

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
  }

  Future<void> _loadInitialItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.loadItems(1, widget.initialItemCount);
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(items);
          _isLoading = false;
          _hasMore = items.length >= widget.initialItemCount;
          _currentPage = 1;
          _showingSeeAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      final nextPage = _currentPage + 1;
      final items = await widget.loadItems(nextPage, widget.itemsPerPage);
      
      if (mounted) {
        setState(() {
          _items.addAll(items);
          _isLoadingMore = false;
          _currentPage = nextPage;
          _hasMore = items.length >= widget.itemsPerPage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleSeeAllPressed() async {
    setState(() {
      _showingSeeAll = true;
    });
    await _loadMoreItems();
  }

  Future<void> _handleRefresh() async {
    await _loadInitialItems();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return widget.emptyBuilder?.call() ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore && !_showingSeeAll ? 1 : 0) + (widget.header != null ? 1 : 0) + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Header
          if (widget.header != null && index == 0) {
            return widget.header!;
          }

          final actualIndex = widget.header != null ? index - 1 : index;

          // Show items
          if (actualIndex < _items.length) {
            return widget.itemBuilder(context, _items[actualIndex], actualIndex);
          }

          // Loading more indicator
          if (_isLoadingMore && actualIndex == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading more items...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          // See All button
          if (_hasMore && !_showingSeeAll && actualIndex == _items.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2563EB),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _handleSeeAllPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.expand_more_rounded,
                            color: Color(0xFF2563EB),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'See All Items',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Load ${widget.itemsPerPage} more',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
