import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import 'store_form_screen.dart';
import '../../models/store_repository.dart';

class MultiStoreScreen extends StatefulWidget {
  const MultiStoreScreen({super.key});

  @override
  State<MultiStoreScreen> createState() => _MultiStoreScreenState();
}

class _MultiStoreScreenState extends State<MultiStoreScreen> {
  List<Store> _stores = StoreRepository.stores;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  Store? _selectedStore;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'All Stores'},
    {'value': 'active', 'label': 'Active Only'},
    {'value': 'inactive', 'label': 'Inactive Only'},
  ];

  final List<String> _defaultStoreNames = [
    'Main Warehouse',
    'Dry Food Store',
    'Cold Room',
    'Freezer Store',
    'Beverage Store',
    'Kitchen Store',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with default stores if empty
    if (_stores.isEmpty) {
      _initializeDefaultStores();
    }
  }

  void _initializeDefaultStores() {
    if (StoreRepository.stores.isNotEmpty) return;

    final now = DateTime.now();

    for (int i = 0; i < _defaultStoreNames.length; i++) {
      StoreRepository.addStore(
        Store(
          id: 'STORE-${i + 1}',
          name: _defaultStoreNames[i],
          code: 'SW-${(i + 1).toString().padLeft(3, '0')}',
          description: _defaultStoreNames[i],
          location: i % 2 == 0 ? 'Main Building' : 'Secondary Building',
          phone: '+1-555-${1000 + i}',
          email: 'store${i + 1}@company.com',
          manager: 'Store Manager ${i + 1}',
          isActive: i != 2,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  List<Store> get _filteredStores {
    return _stores.where((store) {
      final matchesSearch =
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              store.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && store.isActive) ||
          (_selectedFilter == 'inactive' && !store.isActive);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Multi-Store Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search stores...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => setState(() => _searchQuery = ''),
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
                      borderSide:
                          const BorderSide(color: Color(0xFF2563EB), width: 2),
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
                      setState(() => _selectedFilter = value!),
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
                      borderSide:
                          const BorderSide(color: Color(0xFF2563EB), width: 2),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF64748B)),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStoreSheet(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Store'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
          Expanded(
            child: _filteredStores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 80,
                          color: const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stores found',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddStoreSheet(),
                          child: const Text('Add your first store'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                            onSelected: (value) =>
                                _handlePopupMenuSelection(value, store),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, size: 20),
                                  title: Text('Edit Store'),
                                ),
                              ),
                              const PopupMenuItem(
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
          ),
        ],
      ),
    );
  }

  void _handlePopupMenuSelection(String action, Store store) {
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreFormScreen(store: store),
        ),
      ).then((_) => setState(() {}));
    } else if (action == 'delete') {
      _showDeleteDialog(store);
    }
  }

  void _showAddStoreSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StoreFormScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  void _showDeleteDialog(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Store'),
        content: Text(
          'Are you sure you want to delete "${store.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              StoreRepository.deleteStore(store.id);
              setState(() {
                _stores = StoreRepository.stores;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${store.name} deleted successfully'),
                  backgroundColor: const Color(0xFF16A34A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
