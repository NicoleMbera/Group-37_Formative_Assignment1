class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String campus; // Kigali | Mauritius
  final String role;   // Student | Club Leader | Event Organizer | Entrepreneur | Academic Staff
  final List<String> interests;
  final String pathway;
  final List<String> skills;
  final String? avatarUrl;
  final List<String> joinedCommunityIds;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.campus,
    required this.role,
    required this.interests,
    required this.pathway,
    required this.skills,
    this.avatarUrl,
    this.joinedCommunityIds = const [],
  });

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? campus,
    String? role,
    List<String>? interests,
    String? pathway,
    List<String>? skills,
    String? avatarUrl,
    List<String>? joinedCommunityIds,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      interests: interests ?? this.interests,
      pathway: pathway ?? this.pathway,
      skills: skills ?? this.skills,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedCommunityIds: joinedCommunityIds ?? this.joinedCommunityIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'campus': campus,
        'role': role,
        'interests': interests.join(','),
        'pathway': pathway,
        'skills': skills.join(','),
        'avatarUrl': avatarUrl ?? '',
        'joinedCommunityIds': joinedCommunityIds.join(','),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        campus: map['campus'] as String,
        role: map['role'] as String,
        interests: (map['interests'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        pathway: map['pathway'] as String,
        skills: (map['skills'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        avatarUrl:
            (map['avatarUrl'] as String).isEmpty ? null : map['avatarUrl'] as String,
        joinedCommunityIds: (map['joinedCommunityIds'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
      );

  bool get isOrganizer =>
      role == 'Club Leader' ||
      role == 'Event Organizer' ||
      role == 'Academic Staff';
}
