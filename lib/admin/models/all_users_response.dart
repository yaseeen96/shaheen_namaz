import 'dart:isolate';

class AllUsersResponse {
  List<Users>? users;

  AllUsersResponse({this.users});

  AllUsersResponse.fromJson(Map<String, dynamic> json) {
    if (json["users"] is List) {
      users = json["users"] == null
          ? null
          : (json["users"] as List).map((e) => Users.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (users != null) {
      data["users"] = users?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Users {
  dynamic displayName;
  String? email;
  List<String>? masjidAllocated;
  String? uid;
  bool? isAdmin;
  bool? isStaff;
  bool? isTrustee;

  Users({
    this.displayName,
    this.email,
    this.masjidAllocated,
    this.uid,
    this.isAdmin,
    this.isStaff,
    this.isTrustee,
  });

  Users.fromJson(Map<String, dynamic> json) {
    displayName = json["display_name"];
    if (json["email"] is String) {
      email = json["email"];
    }
    if (json["masjid_allocated"] is List) {
      masjidAllocated = json["masjid_allocated"] == null
          ? null
          : List<String>.from(json["masjid_allocated"]);
    }
    if (json["uid"] is String) {
      uid = json["uid"];
    }
    if (json["is_admin"] is bool) {
      isAdmin = json["is_admin"];
    }
    if (json["is_staff"] is bool) {
      isStaff = json["is_staff"];
    }
    if (json["is_trustee"] is bool) {
      isTrustee = json["is_trustee"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["display_name"] = displayName;
    data["email"] = email;
    if (masjidAllocated != null) {
      data["masjid_allocated"] = masjidAllocated;
    }
    data["uid"] = uid;
    data["is_admin"] = isAdmin;
    data["is_staff"] = isStaff;
    data["is_trustee"] = isTrustee;
    return data;
  }
}
