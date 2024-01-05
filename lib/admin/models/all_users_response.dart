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
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (users != null) {
      _data["users"] = users?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Users {
  dynamic displayName;
  String? email;
  List<String>? masjidAllocated;
  String? uid;

  Users({this.displayName, this.email, this.masjidAllocated, this.uid});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["display_name"] = displayName;
    _data["email"] = email;
    if (masjidAllocated != null) {
      _data["masjid_allocated"] = masjidAllocated;
    }
    _data["uid"] = uid;
    return _data;
  }
}
