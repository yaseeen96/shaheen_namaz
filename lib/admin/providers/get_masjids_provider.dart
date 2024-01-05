import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMasjidProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>(
    (ref) => FirebaseFirestore.instance.collection("Masjid").snapshots());
