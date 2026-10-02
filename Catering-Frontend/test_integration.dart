import 'dart:io';

void main() async {
  print('Testing Flutter Integration...');
  
  // Test 1: Check if key files exist
  final keyFiles = [
    'lib/main.dart',
    'lib/app_wrapper.dart',
    'lib/services/api_repository.dart',
    'lib/screens/inventory_screen.dart',
    'lib/screens/dashboard_screen.dart',
    'lib/widgets/loading_error_widgets.dart',
    'lib/models/inventory_models.dart',
  ];
  
  print('\n1. Checking key files...');
  for (final file in keyFiles) {
    final exists = await File(file).exists();
    print('  ${exists ? '✓' : '✗'} $file');
  }
  
  // Test 2: Check pubspec.yaml dependencies
  print('\n2. Checking pubspec.yaml...');
  try {
    final pubspec = await File('pubspec.yaml').readAsString();
    final requiredDeps = ['dio', 'flutter_secure_storage', 'json_annotation'];
    
    for (final dep in requiredDeps) {
      final hasDeep = pubspec.contains(dep);
      print('  ${hasDeep ? '✓' : '✗'} $dep dependency');
    }
  } catch (e) {
    print('  ✗ Error reading pubspec.yaml: $e');
  }
  
  // Test 3: Check for common syntax issues
  print('\n3. Checking for basic syntax issues...');
  
  for (final file in keyFiles) {
    try {
      final content = await File(file).readAsString();
      
      // Check for unmatched braces (basic check)
      final openBraces = '{'.allMatches(content).length;
      final closeBraces = '}'.allMatches(content).length;
      
      if (openBraces == closeBraces) {
        print('  ✓ $file - Braces balanced');
      } else {
        print('  ✗ $file - Unmatched braces: $openBraces open, $closeBraces close');
      }
    } catch (e) {
      print('  ✗ Error reading $file: $e');
    }
  }
  
  print('\nIntegration test completed!');
  print('\nNext steps:');
  print('1. Start Laravel backend: cd ../Catering-Backend && php artisan serve');
  print('2. Start Flutter app: flutter run');
  print('3. Test login flow: Login → Dashboard → Inventory screens');
  print('4. Test CRUD: Create → View → Edit → Delete inventory items');
}