import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../services/api/api_exception.dart';
import '../../services/api/base_api_service.dart';
import '../../services/store_service.dart';
import 'store_form_screen.dart';
import '../../models/store_repository.dart';

class MultiStoreScreen extends StatefulWidget {
  const MultiStoreScreen({super.key});

  @override
  State<MultiStoreScreen> createState() => _MultiStoreScreenState();
}

class _MultiStoreScreenState extends State<MultiStoreScreen> {
  List<Store> _stores = [];
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String? _loadError;
  String? _deletingStoreId;
  int _loadRequestId = 0;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'All Stores'},
    {'value': 'active', 'label': 'Active Only'},
    {'value': 'inactive', 'label': 'Inactive Only'},
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStores({bool showLoading = true}) async {
    final requestId = ++_loadRequestId;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final stores = <Store>[];
      var page = 1;
      var lastPage = 1;

      do {
        final result = await StoreService.instance.getAll(
          queryParams: ListQueryParams(page: page, perPage: 100),
        );
        if (requestId != _loadRequestId) return;
        stores.addAll(result.items);
        lastPage = result.lastPage;
        page++;
      } while (page <= lastPage);

      if (!mounted || requestId != _loadRequestId) return;
      StoreRepository.replaceStores(stores);
      setState(() {
        _stores = stores;
        _isLoading = false;
        _loadError = null;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _isLoading = false;
        _loadError = error.message;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _isLoading = false;
        _loadError =
            'Could not load stores. Check the API connection and retry.';
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  List<Store> get _filteredStores {
    return _stores.where((store) {
      final matchesSearch =
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && store.isActive) ||
          (_selectedFilter == 'inactive' && !store.isActive);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Multi-Store Management',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh stores',
            onPressed: _isLoading ? null : () => _loadStores(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search stores...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  items: _filterOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'],
                      child: Text(option['label']!),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedFilter = value ?? 'all'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Store count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_filteredStores.length} stores',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openStoreForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Store'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Store list
          Expanded(child: _buildStoreList()),
        ],
      ),
    );
  }

  Widget _buildStoreList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _loadStores(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No stores found',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _openStoreForm(),
              child: const Text('Add your first store'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadStores(showLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredStores.length,
        itemBuilder: (context, index) {
          final store = _filteredStores[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: store.isActive
                      ? const Color(0xFF16A34A).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  store.isActive
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  color: store.isActive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFEF4444),
                ),
              ),
              title: Text(
                store.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${store.code} • ${store.location}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: store.isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handlePopupMenuSelection(value, store),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, size: 20),
                      title: Text('Edit Store'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, size: 20),
                      title: Text('Delete Store'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePopupMenuSelection(String action, Store store) {
    if (action == 'edit') {
      _openStoreForm(store: store);
    } else if (action == 'delete') {
      _showDeleteDialog(store);
    }
  }

  Future<void> _openStoreForm({Store? store}) async {
    final savedStore = await Navigator.push<Store>(
      context,
      MaterialPageRoute(builder: (_) => StoreFormScreen(store: store)),
    );

    if (savedStore != null && mounted) {
      await _loadStores(showLoading: false);
    }
  }

  void _showDeleteDialog(Store store) {
    var isDeleting = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Store'),
          content: Text(
            'Are you sure you want to delete "${store.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      await _deleteStore(store, dialogContext);
                      if (dialogContext.mounted) {
                        setDialogState(() => isDeleting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStore(Store store, BuildContext dialogContext) async {
    if (_deletingStoreId != null) return;
    setState(() => _deletingStoreId = store.id);
    try {
      await StoreService.instance.delete(store.id);
      if (!mounted) return;

      Navigator.pop(dialogContext);
      _showMessage('${store.name} deleted successfully');
      await _loadStores(showLoading: false);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Could not delete the store. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _deletingStoreId = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF16A34A),
      ),
    );
  }
}
