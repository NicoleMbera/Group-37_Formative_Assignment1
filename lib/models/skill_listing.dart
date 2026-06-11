class SkillListing {
  final String id;
  final String userId;
  final String userName;
  final String userCampus;
  final String skillTitle;
  final String category;
  final String description;
  final String mode; // Online | In-person | Both
  final String availability;
  final int maxSessionsPerWeek;
  final double rating;
  final int sessionCount;
  int requestCount;
  bool isAvailable;
  final DateTime createdAt;

  SkillListing({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userCampus,
    required this.skillTitle,
    required this.category,
    required this.description,
    required this.mode,
    required this.availability,
    required this.maxSessionsPerWeek,
    required this.rating,
    required this.sessionCount,
    required this.requestCount,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userCampus': userCampus,
        'skillTitle': skillTitle,
        'category': category,
        'description': description,
        'mode': mode,
        'availability': availability,
        'maxSessionsPerWeek': maxSessionsPerWeek,
        'rating': rating,
        'sessionCount': sessionCount,
        'requestCount': requestCount,
        'isAvailable': isAvailable ? 1 : 0,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory SkillListing.fromMap(Map<String, dynamic> map) => SkillListing(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        userCampus: map['userCampus'] as String,
        skillTitle: map['skillTitle'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        mode: map['mode'] as String,
        availability: map['availability'] as String,
        maxSessionsPerWeek: map['maxSessionsPerWeek'] as int,
        rating: (map['rating'] as num).toDouble(),
        sessionCount: map['sessionCount'] as int,
        requestCount: map['requestCount'] as int,
        isAvailable: (map['isAvailable'] as int) == 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
