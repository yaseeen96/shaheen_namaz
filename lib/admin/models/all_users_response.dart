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

  AllUsersResponse copyWith({
    List<Users>? users,
  }) {
    return AllUsersResponse(
      users: users ?? this.users,
    );
  }
}

class Users {
  String? displayName;
  String? email;
  List<String>? masjidAllocated;
  String? uid;
  bool? isAdmin;
  bool? isStaff;
  bool? isTrustee;
  List<MasjidDetails>? masjidDetails;

  Users({
    this.displayName,
    this.email,
    this.masjidAllocated,
    this.uid,
    this.isAdmin,
    this.isStaff,
    this.isTrustee,
    this.masjidDetails,
  });

  Users.fromJson(Map<String, dynamic> json) {
    displayName = json["display_name"];
    email = json["email"];
    masjidAllocated = json["masjid_allocated"] == null
        ? null
        : List<String>.from(json["masjid_allocated"]);
    uid = json["uid"];
    isAdmin = json["isAdmin"];
    isStaff = json["isStaff"];
    isTrustee = json["isTrustee"];
    if (json["masjid_details"] != null) {
      masjidDetails = (json["masjid_details"] as List)
          .map((e) => MasjidDetails.fromJson(e))
          .toList();
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
    if (masjidDetails != null) {
      data["masjid_details"] = masjidDetails?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  Users copyWith({
    String? displayName,
    String? email,
    List<String>? masjidAllocated,
    String? uid,
    bool? isAdmin,
    bool? isStaff,
    bool? isTrustee,
    List<MasjidDetails>? masjidDetails,
  }) {
    return Users(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      masjidAllocated: masjidAllocated ?? this.masjidAllocated,
      uid: uid ?? this.uid,
      isAdmin: isAdmin ?? this.isAdmin,
      isStaff: isStaff ?? this.isStaff,
      isTrustee: isTrustee ?? this.isTrustee,
      masjidDetails: masjidDetails ?? this.masjidDetails,
    );
  }

  @override
  String toString() {
    return 'Users(displayName: $displayName, email: $email, masjidAllocated: $masjidAllocated, uid: $uid, isAdmin: $isAdmin, isStaff: $isStaff, isTrustee: $isTrustee, masjidDetails: $masjidDetails)';
  }
}

class MasjidDetails {
  int? clusterNumber;
  String? masjidId;
  String? masjidName;

  MasjidDetails({this.clusterNumber, this.masjidId, this.masjidName});

  MasjidDetails.fromJson(Map<String, dynamic> json) {
    clusterNumber = json['clusterNumber'];
    masjidId = json['masjidId'];
    masjidName = json['masjidName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clusterNumber'] = clusterNumber;
    data['masjidId'] = masjidId;
    data['masjidName'] = masjidName;
    return data;
  }
}
