import 'package:cloud_firestore/cloud_firestore.dart';

class Conversions {
  static String firestoreTimestampToDateString(Timestamp firestoreTimestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = firestoreTimestamp.toDate();
    // Format DateTime to a string in the desired format
    String dateString =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    return dateString;
  }

  static Timestamp convertDateStringToTimestamp(String dateString) {
    // Parse the date string to a DateTime object
    DateTime dateTime = DateTime.parse(dateString);
    // Convert the DateTime object to a Firestore Timestamp
    Timestamp timestamp = Timestamp.fromDate(dateTime);
    return timestamp;
  }
}
