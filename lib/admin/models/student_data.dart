import 'package:cloud_firestore/cloud_firestore.dart';

class StudentData {
  final String uid; // Assuming you want to keep track of the document ID
  final String name;
  final int streak;
  final String guardianNumber;
  final String masjid;

  StudentData({
    required this.uid,
    required this.name,
    required this.streak,
    required this.guardianNumber,
    required this.masjid,
  });

  factory StudentData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StudentData(
      uid: doc.id,
      name: data['name'] ?? '',
      streak: data['streak'] ?? 0,
      guardianNumber: data['guardianNumber'] ?? '',
      masjid: data['masjid'] ?? '',
    );
  }
}
