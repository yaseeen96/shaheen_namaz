// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentData {
  final String uid; // Assuming you want to keep track of the document ID
  final String name;
  final int streak;
  final String guardianNumber;
  final String masjid;
  final String streakLastModified;
  final String guardianName;
  final String age;
  final String studentClass;
  final String address;

  StudentData({
    required this.uid,
    required this.name,
    required this.streak,
    required this.guardianNumber,
    required this.masjid,
    required this.streakLastModified,
    required this.guardianName,
    required this.age,
    required this.studentClass,
    required this.address,
  });

  static Future<StudentData> getStudentDataFromFirestore(
      DocumentSnapshot doc) async {
    Map data = doc.data() as Map;

    return StudentData(
      uid: doc.id,
      name: data['name'] ?? '',
      streak: data['streak'] ?? 0,
      guardianNumber: data['guardianNumber'] ?? '',
      // data['masjid'] is  a DocumentReference. get the name from the document
      masjid: data['masjid'] != null
          ? await (data['masjid'] as DocumentReference).get().then((doc) {
              return (doc.data() as Map<String, dynamic>)['name'];
            })
          : '',
      // streak_last_modified is timestamp in firestore. convert it to string
// translate the streakLastModified to something. current format is 2024-05-20 12:00:00.000
// I want it in format Thursday, 20 May 2024, 12:00 PM
      streakLastModified: data['streak_last_modified'] != null
          ? formatDateTime((data['streak_last_modified'] as Timestamp).toDate())
          : '',
      guardianName: data['guardianName'] ?? '',
      // we have dob as timestamp in firestore. calculate age from it
      age: data['dob'] != null
          ? ((DateTime.now().difference(data['dob'].toDate()).inDays) / 365)
              .floor()
              .toString()
          : '',
      studentClass: data['class'] ?? '',
      address: data['address'] ?? '',
    );
  }

  @override
  String toString() {
    return 'StudentData(uid: $uid, name: $name, streak: $streak, guardianNumber: $guardianNumber, masjid: $masjid, streakLastModified: $streakLastModified, guardianName: $guardianName, age: $age, studentClass: $studentClass, address: $address)';
  }
}

String formatDateTime(DateTime dateTime) {
  // Define the format you want to use
  DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy, hh:mm a');
  // Format the given DateTime object
  return formatter.format(dateTime);
}
