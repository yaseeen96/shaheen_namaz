import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMasjidProvider = StateProvider<String?>((ref) => null);

final studentDetailsProvider = StateProvider<Map<String, dynamic>>((ref) => {});
