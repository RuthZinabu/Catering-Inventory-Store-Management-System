import 'package:flutter/material.dart';

/// A reusable "See All" button for paginated content
class SeeAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final int? itemsToLoad;
  final bool isLoading;
  final bool isCompact;

  const SeeAllButton({
    super.key,
    required this.onPressed,
    this.label,
    this.itemsToLoad,
    this.isLoading = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label ?? 'See All'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2563EB),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.expand_more_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                const SizedBox(width: 8),
                Text(
                  isLoading ? 'Loading...' : (label ?? 'See All Items'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (itemsToLoad != null && !isLoading) ...[
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
                      'Load $itemsToLoad more',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mixin for handling pagination logic
mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final List<dynamic> items = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  int currentPage = 1;
  int initialItemCount = 15;
  int itemsPerPage = 15;

  /// Override this to implement the actual API call
  Future<List<dynamic>> fetchItems(int page, int perPage);

  /// Load initial items
  Future<void> loadInitialItems() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetchedItems = await fetchItems(1, initialItemCount);
      if (mounted) {
        setState(() {
          items.clear();
          items.addAll(fetchedItems);
          isLoading = false;
          hasMore = fetchedItems.length >= initialItemCount;
          currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  /// Load more items
  Future<void> loadMoreItems() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
      error = null;
    });

    try {
      final nextPage = currentPage + 1;
      final fetchedItems = await fetchItems(nextPage, itemsPerPage);

      if (mounted) {
        setState(() {
          items.addAll(fetchedItems);
          isLoadingMore = false;
          currentPage = nextPage;
          hasMore = fetchedItems.length >= itemsPerPage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoadingMore = false;
        });
      }
    }
  }

  /// Handle refresh
  Future<void> handleRefresh() async {
    await loadInitialItems();
  }
}
