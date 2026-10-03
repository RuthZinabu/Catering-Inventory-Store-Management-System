# Catering-Inventory-Store-Management-System
A Food Catering Inventory &amp; Store Management System is designed to manage raw materials, kitchen supplies, finished products, stock movements, suppliers, purchasing, and inventory reports for catering businesses. The system helps reduce food waste, control costs, and ensure that ingredients are always available.

## API connection

The Flutter app signs in against the Laravel API and stores the Sanctum session locally. Configure the API root when running the app:

```sh
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```

For an Android emulator, use `http://10.0.2.2:8000/api`; for a physical device, use the host machine's reachable IP address. Run the backend migrations after installing Composer dependencies before using purchases or suppliers.
