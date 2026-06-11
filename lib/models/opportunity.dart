class Opportunity {
  final String id;
  final String title;
  final String category; // Events | Hackathons | Internships | Workshops
  final String description;
  final String organizer;
  final DateTime date;
  final String time;
  final String location;
  final int maxParticipants;
  final int rsvpCount;
  final List<String> tags;
  final List<String> requiredSkills;
  final String? imageAsset; // category icon key, not a real file
  int matchScore; // calculated at runtime

  Opportunity({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.organizer,
    required this.date,
    required this.time,
    required this.location,
    required this.maxParticipants,
    required this.rsvpCount,
    required this.tags,
    required this.requiredSkills,
    this.imageAsset,
    this.matchScore = 0,
  });

  bool get isPast => date.isBefore(DateTime.now());
  double get capacityRatio => maxParticipants > 0 ? rsvpCount / maxParticipants : 0;
  bool get isFillingUp => capacityRatio >= 0.8;
  int get spotsLeft => maxParticipants - rsvpCount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'organizer': organizer,
        'date': date.millisecondsSinceEpoch,
        'time': time,
        'location': location,
        'maxParticipants': maxParticipants,
        'rsvpCount': rsvpCount,
        'tags': tags.join(','),
        'requiredSkills': requiredSkills.join(','),
        'imageAsset': imageAsset ?? '',
        'matchScore': matchScore,
      };

  factory Opportunity.fromMap(Map<String, dynamic> map) => Opportunity(
        id: map['id'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        organizer: map['organizer'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        time: map['time'] as String,
        location: map['location'] as String,
        maxParticipants: map['maxParticipants'] as int,
        rsvpCount: map['rsvpCount'] as int,
        tags: (map['tags'] as String).split(',').where((e) => e.isNotEmpty).toList(),
        requiredSkills: (map['requiredSkills'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        imageAsset:
            (map['imageAsset'] as String).isEmpty ? null : map['imageAsset'] as String,
        matchScore: map['matchScore'] as int? ?? 0,
      );

  Opportunity copyWith({int? matchScore, int? rsvpCount}) => Opportunity(
        id: id,
        title: title,
        category: category,
        description: description,
        organizer: organizer,
        date: date,
        time: time,
        location: location,
        maxParticipants: maxParticipants,
        rsvpCount: rsvpCount ?? this.rsvpCount,
        tags: tags,
        requiredSkills: requiredSkills,
        imageAsset: imageAsset,
        matchScore: matchScore ?? this.matchScore,
      );
}
