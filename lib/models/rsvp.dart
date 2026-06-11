enum RsvpStatus { going, interested, none }

class Rsvp {
  final String eventId;
  final RsvpStatus status;
  final DateTime rsvpedAt;

  const Rsvp({
    required this.eventId,
    required this.status,
    required this.rsvpedAt,
  });
}
