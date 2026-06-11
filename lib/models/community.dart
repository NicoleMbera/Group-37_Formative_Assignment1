class Community {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final int memberCount;
  final int postCount;
  final int activityScore;
  final List<String> tags;
  final String campus; // Kigali | Mauritius | Both

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.memberCount,
    required this.postCount,
    required this.activityScore,
    required this.tags,
    required this.campus,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'iconEmoji': iconEmoji,
        'memberCount': memberCount,
        'postCount': postCount,
        'activityScore': activityScore,
        'tags': tags.join(','),
        'campus': campus,
      };

  factory Community.fromMap(Map<String, dynamic> map) => Community(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        iconEmoji: map['iconEmoji'] as String,
        memberCount: map['memberCount'] as int,
        postCount: map['postCount'] as int,
        activityScore: map['activityScore'] as int,
        tags:
            (map['tags'] as String).split(',').where((e) => e.isNotEmpty).toList(),
        campus: map['campus'] as String,
      );
}
