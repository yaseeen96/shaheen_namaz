import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedItemsProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [];
});
