import 'store_model.dart';

class StoreRepository {
  static final List<Store> _stores = [];

  static List<Store> get stores => _stores;

  static Store? getStoreById(String id) {
    try {
      return _stores.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addStore(Store store) {
    _stores.add(store);
  }

  static void updateStore(Store store) {
    final index = _stores.indexWhere((s) => s.id == store.id);
    if (index != -1) {
      _stores[index] = store;
    }
  }

  static void deleteStore(String id) {
    _stores.removeWhere((store) => store.id == id);
  }
}
