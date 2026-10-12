import 'package:catering_inventory_store_management_system/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.setEnvironment(Environment.production);
    await AppConfig.clearCustomApiUrl();
  });

  test('saves a normalized custom API URL', () async {
    await AppConfig.setCustomApiUrl('  https://phone.example/api/  ');

    final preferences = await SharedPreferences.getInstance();
    expect(AppConfig.effectiveApiUrl, 'https://phone.example/api');
    expect(
      preferences.getString('custom_api_base_url'),
      'https://phone.example/api',
    );
  });

  test('restores the saved API URL over the default after restart', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'custom_api_base_url',
      'https://saved-phone.example/api',
    );

    await AppConfig.restoreCustomApiUrl();

    expect(AppConfig.effectiveApiUrl, 'https://saved-phone.example/api');
  });

  test('rejects invalid API URLs without replacing the current setting',
      () async {
    await AppConfig.setCustomApiUrl('https://valid.example/api');

    await expectLater(
      AppConfig.setCustomApiUrl('not a URL'),
      throwsA(isA<FormatException>()),
    );

    expect(AppConfig.effectiveApiUrl, 'https://valid.example/api');
  });

  test('clearing a custom URL restores the configured default', () async {
    await AppConfig.setCustomApiUrl('https://phone.example/api');
    await AppConfig.clearCustomApiUrl();

    final preferences = await SharedPreferences.getInstance();
    expect(AppConfig.effectiveApiUrl, AppConfig.apiBaseUrl);
    expect(preferences.containsKey('custom_api_base_url'), isFalse);
  });
}
