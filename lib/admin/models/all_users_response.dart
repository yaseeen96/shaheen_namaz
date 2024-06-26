import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsersResponse {
  List<User> users;

  AllUsersResponse({required this.users});

  factory AllUsersResponse.fromSnapshot(QuerySnapshot snapshot) {
    List<User> userList =
        snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    return AllUsersResponse(users: userList);
  }
}

class User {
  String uid;
  String email;
  String? phoneNumber;
  String? displayName;
  bool isAdmin;
  bool isStaff;
  bool isTrustee;
  String jamaatName;
  List<String> masjidAllocated;
  List<MasjidDetails> masjidDetails;
  Map<String, dynamic>? imamDetails; // Optional field

  User({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    required this.isAdmin,
    required this.isStaff,
    required this.isTrustee,
    required this.jamaatName,
    required this.masjidAllocated,
    required this.masjidDetails,
    this.imamDetails,
  });

  factory User.fromJson(String uid, Map<String, dynamic> json) {
    return User(
      uid: uid,
      email: json['email'] ?? '',
      phoneNumber: json['phone_number']?.toString(),
      displayName: json['name'] as String?,
      isAdmin: json['isAdmin'] ?? false,
      isStaff: json['isStaff'] ?? false,
      isTrustee: json['isTrustee'] ?? false,
      jamaatName: json['jamaat_name'] ?? '',
      masjidAllocated: (json['masjid_allocated'] is List<dynamic>?)
          ? (json['masjid_allocated'] as List<dynamic>?)
                  ?.map((item) => item.toString())
                  .toList() ??
              []
          : [json['masjid_allocated']],
      masjidDetails: (json['masjid_details'] as List<dynamic>?)
              ?.map((item) =>
                  MasjidDetails.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      imamDetails: json['imam_details'] as Map<String, dynamic>?,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromJson(doc.id, data);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'isAdmin': isAdmin,
      'isStaff': isStaff,
      'isTrustee': isTrustee,
      'jamaat_name': jamaatName,
      'masjid_allocated': masjidAllocated,
      'masjid_details': masjidDetails.map((masjid) => masjid.toJson()).toList(),
      if (imamDetails != null) 'imam_details': imamDetails,
    };
  }
}

class MasjidDetails {
  int clusterNumber;
  String masjidId;
  String masjidName;

  MasjidDetails({
    required this.clusterNumber,
    required this.masjidId,
    required this.masjidName,
  });

  factory MasjidDetails.fromJson(Map<String, dynamic> json) {
    return MasjidDetails(
      clusterNumber: json['clusterNumber'] ?? 0,
      masjidId: json['masjidId'] ?? '',
      masjidName: json['masjidName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clusterNumber': clusterNumber,
      'masjidId': masjidId,
      'masjidName': masjidName,
    };
  }
}
