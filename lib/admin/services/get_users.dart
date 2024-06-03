import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shaheen_namaz/admin/models/all_users_response.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

Stream<AllUsersResponse> getUsers() {
  return FirebaseFirestore.instance
      .collection('Users')
      .snapshots()
      .map((snapshot) {
    logger.i("Snapshot received with ${snapshot.docs.length} users");
    for (var doc in snapshot.docs) {
      // logger.i("User ID: ${doc.id}, Data: ${doc.data()}");
    }
    return AllUsersResponse.fromSnapshot(snapshot);
  }).handleError((err) {
    logger.e("Error from getUsers in services: $err");
    throw Exception("Error retrieving users from Firestore.");
  });
}
