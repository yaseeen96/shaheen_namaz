import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMasjidProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>(
    (ref) => FirebaseFirestore.instance.collection("Masjid").snapshots());

final getMasjidNameProvider =
    FutureProvider.family<String, String>((ref, masjidId) async {
  final String masjidName = await FirebaseFirestore.instance
      .collection("Masjid")
      .doc(masjidId)
      .get()
      .then((value) => value.data()?["name"] ?? "Masjid Deleted");
  return masjidName;
});
