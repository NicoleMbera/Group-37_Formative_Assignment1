import '../models/opportunity.dart';
import '../models/user.dart';

class MatchScoreService {
  /// Pure-Dart match scoring. Returns 0–100.
  ///
  /// Breakdown:
  ///   User interests ∩ opp tags:       +20 each, max 40
  ///   User pathway matches category:   +20
  ///   User skills ∩ opp requiredSkills: +15 each, max 30
  ///   Opp from joined community:       +10  (approximated via organizer)
  ///   Attended similar category before: +10 (via pastCategories set)
  int calculateScore(
    Opportunity opportunity,
    AppUser user, {
    Set<String> pastCategories = const {},
  }) {
    int score = 0;

    // Interest overlap (max 40)
    final userInterestsLower = user.interests.map((i) => i.toLowerCase()).toSet();
    final tagsLower = opportunity.tags.map((t) => t.toLowerCase()).toSet();
    final interestMatches = userInterestsLower.intersection(tagsLower).length;
    score += (interestMatches * 20).clamp(0, 40);

    // Pathway → category match (20)
    if (_pathwayMatchesCategory(user.pathway, opportunity.category, opportunity.tags)) {
      score += 20;
    }

    // Skills overlap (max 30)
    final userSkillsLower = user.skills.map((s) => s.toLowerCase()).toSet();
    final reqSkillsLower =
        opportunity.requiredSkills.map((s) => s.toLowerCase()).toSet();
    final skillMatches = userSkillsLower.intersection(reqSkillsLower).length;
    score += (skillMatches * 15).clamp(0, 30);

    // Joined community organizer match (10)
    if (user.joinedCommunityIds.isNotEmpty &&
        _organizerIsJoinedClub(opportunity.organizer, user.joinedCommunityIds)) {
      score += 10;
    }

    // Past attendance same category (10)
    if (pastCategories.contains(opportunity.category.toLowerCase())) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  bool _pathwayMatchesCategory(String pathway, String category, List<String> tags) {
    final p = pathway.toLowerCase();
    final c = category.toLowerCase();
    final t = tags.map((e) => e.toLowerCase()).toSet();

    if (p.contains('computer science') || p.contains('engineering')) {
      return c.contains('hackathon') || c.contains('workshop') || t.contains('tech');
    }
    if (p.contains('business') || p.contains('entrepreneurship')) {
      return t.contains('entrepreneurship') || t.contains('business') || c.contains('workshop');
    }
    if (p.contains('global challenges') || p.contains('law') || p.contains('health')) {
      return t.contains('social impact') || t.contains('leadership') || t.contains('wellness');
    }
    return false;
  }

  bool _organizerIsJoinedClub(String organizer, List<String> joinedIds) {
    final o = organizer.toLowerCase();
    // Simple heuristic: if organizer name contains a known club keyword
    return o.contains('tech club') ||
        o.contains('entrepreneurship') ||
        o.contains('leadership') ||
        o.contains('design') ||
        o.contains('wellness') ||
        o.contains('environment') ||
        o.contains('student council');
  }
}
