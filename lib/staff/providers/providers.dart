import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMasjidProvider = StateProvider<String?>((ref) => null);

final studentDetailsProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final selectedFaceIdProvider = StateProvider<String?>((ref) => null);
