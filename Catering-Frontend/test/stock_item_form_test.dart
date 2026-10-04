import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/screens/stock/catering_stock_form_screen.dart';
import 'package:catering_inventory_store_management_system/screens/stock/electronics_stock_form_screen.dart';
import 'package:catering_inventory_store_management_system/screens/stock/food_stock_form_screen.dart';
import 'package:catering_inventory_store_management_system/screens/stock/stock_form_screen.dart';
import 'package:catering_inventory_store_management_system/screens/stock/stock_screen.dart';
import 'package:catering_inventory_store_management_system/services/api/api_client.dart';

const _supplierId = '11111111-1111-4111-8111-111111111111';
const _storeId = '22222222-2222-4222-8222-222222222222';

void main() {
  late Dio dio;
  late HttpClientAdapter originalAdapter;
  late _StockFormApiAdapter adapter;

  setUp(() {
    dio = ApiClient.instance.dio;
    originalAdapter = dio.httpClientAdapter;
    adapter = _StockFormApiAdapter();
    dio.httpClientAdapter = adapter;
  });

  tearDown(() {
    dio.httpClientAdapter = originalAdapter;
  });

  final createScenarios = <_CreateScenario>[
    _CreateScenario(
      name: 'food',
      itemType: 'food',
      totalSteps: 2,
      form: () => const FoodStockFormScreen(),
    ),
    _CreateScenario(
      name: 'catering',
      itemType: 'catering',
      totalSteps: 3,
      form: () => const CateringStockFormScreen(subtype: 'permanent'),
    ),
    _CreateScenario(
      name: 'electronics',
      itemType: 'electronics',
      totalSteps: 3,
      form: () => const ElectronicsStockFormScreen(),
    ),
  ];

  for (final scenario in createScenarios) {
    testWidgets(
      '${scenario.name} item creation selects and submits supplier and store',
      (tester) async {
        await tester.pumpWidget(MaterialApp(home: scenario.form()));
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
        final itemCode = _textField('Item Code');
        final itemName = _textField('Item Name');
        await tester.ensureVisible(itemCode);
        await tester.enterText(itemCode, 'TEST-${scenario.itemType}');
        await tester.enterText(itemName, 'Test inventory item');

        await _selectDropdownOption(
          tester,
          index: 0,
          option: 'Fresh Foods Ltd',
        );
        await _selectDropdownOption(
          tester,
          index: 1,
          option: 'Central Kitchen (KITCHEN-01)',
        );

        for (var step = 1; step < scenario.totalSteps; step++) {
          final next = find.text('Next').last;
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        final upload = find.text('Upload item').last;
        await tester.ensureVisible(upload);
        await tester.tap(upload);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final supplierRequests = adapter.requests
            .where((request) => request.path.endsWith('/suppliers'))
            .toList();
        final storeRequests = adapter.requests
            .where((request) => request.path.endsWith('/stores'))
            .toList();
        final createRequest = adapter.requests.singleWhere(
          (request) => request.method == 'POST',
        );

        expect(
          supplierRequests
              .map(
                (request) => int.tryParse(
                  request.queryParameters['page']?.toString() ?? '',
                ),
              )
              .toList(),
          [1, 2],
        );
        expect(
          storeRequests
              .map(
                (request) => int.tryParse(
                  request.queryParameters['page']?.toString() ?? '',
                ),
              )
              .toList(),
          [1, 2],
        );
        expect(
          supplierRequests.every(
            (request) =>
                request.queryParameters['status'] == 'Active' &&
                request.queryParameters['per_page'] == 100,
          ),
          isTrue,
        );
        expect(
          storeRequests.every(
            (request) =>
                request.queryParameters['active'] == true &&
                request.queryParameters['per_page'] == 100,
          ),
          isTrue,
        );
        expect(
          createRequest.path,
          endsWith('/stores/$_storeId/stock/items'),
        );

        final body = _asJsonMap(createRequest.data);
        final item = Map<String, dynamic>.from(body['item'] as Map);
        expect(item['item_type'], scenario.itemType);
        expect(item['supplier_id'], _supplierId);
        expect(body['location_description'], 'Central Kitchen');
      },
    );
  }

  for (final subtype in ['Permanent', 'Temporary']) {
    testWidgets(
      '$subtype catering choice opens the matching catering form',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: StockScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('New Item'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Catering').last);
        await tester.pumpAndSettle();

        expect(find.text('Catering Type'), findsOneWidget);
        await tester.tap(find.text(subtype).last);
        await tester.pumpAndSettle();

        expect(find.text('New Catering Item'), findsOneWidget);
        expect(find.text('Add New Item'), findsNothing);
        expect(find.text('Catering Type'), findsNothing);
        final form = tester.widget<CateringStockFormScreen>(
          find.byType(CateringStockFormScreen),
        );
        expect(form.subtype, subtype.toLowerCase());
      },
    );
  }

  for (final category in ['food', 'catering', 'electronics']) {
    testWidgets(
      'shared $category stock form stays within its available steps',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StockFormScreen(category: category),
                        ),
                      );
                    },
                    child: const Text('Open stock form'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open stock form'));
        await tester.pumpAndSettle();

        final totalSteps = category == 'food' ? 2 : 3;
        for (var step = 1; step < totalSteps; step++) {
          final next = find.text('Next').last;
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        expect(find.text('Upload item'), findsOneWidget);
        await tester.tap(find.text('Upload item').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Finder _textField(String label) {
  // TextFormField does not expose a public `decoration` getter.
  // Instead, find a TextFormField that is an ancestor of the label Text widget.
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
}

Future<void> _selectDropdownOption(
  WidgetTester tester, {
  required int index,
  required String option,
}) async {
  final dropdown = find.byType(DropdownButtonFormField<String>).at(index);
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }
  if (value is List<int>) {
    return Map<String, dynamic>.from(jsonDecode(utf8.decode(value)) as Map);
  }
  throw StateError('Unexpected API request body: ${value.runtimeType}');
}

class _CreateScenario {
  final String name;
  final String itemType;
  final int totalSteps;
  final Widget Function() form;

  const _CreateScenario({
    required this.name,
    required this.itemType,
    required this.totalSteps,
    required this.form,
  });
}

class _RecordedRequest {
  final String method;
  final String path;
  final Map<String, dynamic> queryParameters;
  final dynamic data;

  _RecordedRequest(RequestOptions options, dynamic requestData)
      : method = options.method,
        path = options.uri.path,
        queryParameters = Map<String, dynamic>.from(options.queryParameters),
        data = requestData;
}

class _StockFormApiAdapter implements HttpClientAdapter {
  final List<_RecordedRequest> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final streamBody = requestStream == null
        ? null
        : Uint8List.fromList(
            await requestStream.expand((chunk) => chunk).toList(),
          );
    final requestData = options.data ?? streamBody;
    requests.add(_RecordedRequest(options, requestData));
    final path = options.uri.path;

    if (path.endsWith('/suppliers')) {
      final page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
      return _jsonResponse({
        'suppliers': [
          {
            'id': page == 1
                ? '11111111-1111-4111-8111-111111111112'
                : _supplierId,
            'name': page == 1 ? 'First Supplier' : 'Fresh Foods Ltd',
            'company': page == 1 ? 'First Supplier Ltd' : 'Fresh Foods Ltd',
            'contact_person': 'Taylor',
            'phone': '555-0100',
            'email': 'supplier@example.test',
            'address': 'Market Road',
            'tax_number': 'TAX-001',
            'status': 'Active',
            'outstanding_balance': 0,
          },
        ],
        'pagination': _pagination(page),
      });
    }

    if (path.endsWith('/stores')) {
      final page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
      final store = page == 1
          ? {
              ..._store,
              'id': '22222222-2222-4222-8222-222222222223',
              'name': 'North Warehouse',
              'code': 'WAREHOUSE-01',
            }
          : _store;
      return _jsonResponse({
        'items': [store],
        'stores': [store],
        'pagination': _pagination(page),
      });
    }

    if (options.method == 'GET' && path.endsWith('/stock')) {
      return _jsonResponse({
        'items': <Map<String, dynamic>>[],
        'pagination': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 100,
          'total': 0,
        },
      });
    }

    if (options.method == 'POST' && path.endsWith('/stock/items')) {
      final body = _asJsonMap(requestData);
      final item = Map<String, dynamic>.from(body['item'] as Map);
      return _jsonResponse({
        'id': '33333333-3333-4333-8333-333333333333',
        'item': {
          ...item,
          'id': '44444444-4444-4444-8444-444444444444',
          'supplier': {
            'id': _supplierId,
            'name': 'Fresh Foods Ltd',
            'company': 'Fresh Foods Ltd',
          },
        },
        'store': _store,
        'quantity': body['quantity'] ?? 0,
        'min_quantity': body['min_quantity'] ?? 0,
        'max_quantity': body['max_quantity'] ?? 0,
        'location_description': body['location_description'],
        'status': 'Healthy',
        'updated_at': '2026-10-04T12:00:00.000000Z',
      });
    }

    return ResponseBody.fromString(
      jsonEncode({'success': false, 'message': 'Unexpected test API request'}),
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> data) {
  return ResponseBody.fromString(
    jsonEncode({'success': true, 'data': data}),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _pagination(int page) => {
      'current_page': page,
      'last_page': 2,
      'per_page': 100,
      'total': 2,
    };

const _store = {
  'id': _storeId,
  'name': 'Central Kitchen',
  'code': 'KITCHEN-01',
  'location': 'Main Building',
  'is_active': true,
  'created_at': '2026-10-04T12:00:00.000000Z',
  'updated_at': '2026-10-04T12:00:00.000000Z',
};
