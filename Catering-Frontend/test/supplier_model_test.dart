import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/models/inventory_models.dart';

void main() {
  test('parses supplier rows with nullable database fields and decimal strings',
      () {
    final supplier = Supplier.fromJson({
      'id': 'supplier-id',
      'name': 'North Foods',
      'company': 'North Foods Ltd',
      'contact_person': null,
      'phone': null,
      'email': null,
      'address': null,
      'tax_number': null,
      'status': 'Active',
      'outstanding_balance': '0.00',
    });

    expect(supplier.company, 'North Foods Ltd');
    expect(supplier.contactPerson, isEmpty);
    expect(supplier.phone, isEmpty);
    expect(supplier.email, isEmpty);
    expect(supplier.address, isEmpty);
    expect(supplier.taxNumber, isEmpty);
    expect(supplier.outstandingBalance, 0);
  });
}
