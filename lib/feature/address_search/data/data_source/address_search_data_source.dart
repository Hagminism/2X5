import 'package:capstone_2026/feature/address_search/data/model/address_search_item.dart';

abstract interface class AddressSearchDataSource {
  Future<List<AddressSearchItem>> searchAddresses(String query);
}
