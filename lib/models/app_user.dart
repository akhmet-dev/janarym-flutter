/// User roles in the app
enum UserRole {
  developer, admin, mentor, parent, child, member;

  bool get isStandardUser => this == UserRole.member || this == UserRole.child;

  String get label {
    switch (this) {
      case UserRole.developer: return 'Developer';
      case UserRole.admin: return 'Admin';
      case UserRole.mentor: return 'Mentor';
      case UserRole.parent: return 'Ата-ана';
      case UserRole.child: return 'Бала';
      case UserRole.member: return 'Пайдаланушы';
    }
  }
}

enum ApplicationStatus { pending, approved, rejected }

/// App user model (mirrors Firestore document)
class AppUser {
  final String id;
  final String email;
  String name;
  UserRole role;
  String? mentorId;
  bool? isDirectApproved;
  String? parentUid;
  List<String> children;
  bool isLinked;
  String? lastPhotoURL;
  String? lastPhotoBase64;

  AppUser({
    required this.id, required this.email, required this.name,
    required this.role, this.mentorId, this.isDirectApproved,
    this.parentUid, this.children = const [], this.isLinked = false,
    this.lastPhotoURL, this.lastPhotoBase64,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String id) {
    return AppUser(
      id: id, email: json['email'] ?? '', name: json['name'] ?? '',
      role: UserRole.values.firstWhere((e) => e.name == json['role'], orElse: () => UserRole.member),
      mentorId: json['mentorId'], isDirectApproved: json['isDirectApproved'],
      parentUid: json['parentUid'], children: List<String>.from(json['children'] ?? []),
      isLinked: json['isLinked'] ?? false, lastPhotoURL: json['lastPhotoURL'],
      lastPhotoBase64: json['lastPhotoBase64'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email, 'name': name, 'role': role.name,
    if (mentorId != null) 'mentorId': mentorId,
    if (isDirectApproved != null) 'isDirectApproved': isDirectApproved,
    if (parentUid != null) 'parentUid': parentUid,
    'children': children, 'isLinked': isLinked,
    if (lastPhotoURL != null) 'lastPhotoURL': lastPhotoURL,
    if (lastPhotoBase64 != null) 'lastPhotoBase64': lastPhotoBase64,
  };
}
