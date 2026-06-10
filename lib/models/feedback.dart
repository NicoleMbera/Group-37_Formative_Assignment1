class EventFeedback {
  final String id;
  final String eventId;
  final String userId;
  final int overallRating;       // 1-5
  final int contentRating;       // 1-5
  final int organizationRating;  // 1-5
  final int networkingRating;    // 1-5
  final bool wouldRecommend;
  final String comments;
  final DateTime submittedAt;

  const EventFeedback({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.overallRating,
    required this.contentRating,
    required this.organizationRating,
    required this.networkingRating,
    required this.wouldRecommend,
    required this.comments,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'eventId': eventId,
        'userId': userId,
        'overallRating': overallRating,
        'contentRating': contentRating,
        'organizationRating': organizationRating,
        'networkingRating': networkingRating,
        'wouldRecommend': wouldRecommend ? 1 : 0,
        'comments': comments,
        'submittedAt': submittedAt.millisecondsSinceEpoch,
      };

  factory EventFeedback.fromMap(Map<String, dynamic> map) => EventFeedback(
        id: map['id'] as String,
        eventId: map['eventId'] as String,
        userId: map['userId'] as String,
        overallRating: map['overallRating'] as int,
        contentRating: map['contentRating'] as int,
        organizationRating: map['organizationRating'] as int,
        networkingRating: map['networkingRating'] as int,
        wouldRecommend: (map['wouldRecommend'] as int) == 1,
        comments: map['comments'] as String,
        submittedAt:
            DateTime.fromMillisecondsSinceEpoch(map['submittedAt'] as int),
      );
}
