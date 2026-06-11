import '../models/community.dart';
import '../models/feedback.dart';
import '../models/message.dart';
import '../models/opportunity.dart';
import '../models/skill_listing.dart';
import '../models/user.dart';

class MockData {
  MockData._();

  // ── Mock user ──────────────────────────────────────────────────────────────
  static final AppUser mockUser = AppUser(
    id: 'user_001',
    fullName: 'Aline Umuhoza',
    email: 'a.umuhoza@alustudent.com',
    campus: 'Kigali',
    role: 'Student',
    interests: ['Tech', 'Entrepreneurship', 'Leadership'],
    pathway: 'BSc Computer Science',
    skills: ['Flutter', 'Public Speaking'],
    joinedCommunityIds: ['com_001', 'com_003'],
  );

  // ── Opportunities (14) ────────────────────────────────────────────────────
  static final List<Opportunity> opportunities = [
    Opportunity(
      id: 'opp_001',
      title: 'ALU Tech Hackathon 2025',
      category: 'Hackathons',
      description:
          'A 48-hour hackathon where teams of 3-5 students build innovative solutions to real-world African challenges. Cash prizes and mentorship sessions with industry leaders.',
      organizer: 'ALU Tech Club',
      date: DateTime.now().add(const Duration(days: 12)),
      time: '08:00 AM',
      location: 'Innovation Hub, Kigali Campus',
      maxParticipants: 80,
      rsvpCount: 67,
      tags: ['Tech', 'Innovation', 'Entrepreneurship'],
      requiredSkills: ['Flutter', 'Python', 'UI/UX'],
    ),
    Opportunity(
      id: 'opp_002',
      title: 'Leadership Summit 2025',
      category: 'Events',
      description:
          'Annual leadership summit featuring keynote speakers, panel discussions, and workshops designed to equip the next generation of African leaders.',
      organizer: 'Student Council',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '09:00 AM',
      location: 'Main Auditorium, Kigali',
      maxParticipants: 150,
      rsvpCount: 98,
      tags: ['Leadership', 'Personal Development', 'Networking'],
      requiredSkills: ['Public Speaking'],
    ),
    Opportunity(
      id: 'opp_003',
      title: 'Google Africa Internship Programme',
      category: 'Internships',
      description:
          'Competitive paid internship at Google\'s offices across Africa. Open to students in Computer Science and related fields with strong programming skills.',
      organizer: 'Career Services',
      date: DateTime.now().add(const Duration(days: 30)),
      time: 'Deadline',
      location: 'Remote / Nairobi',
      maxParticipants: 20,
      rsvpCount: 18,
      tags: ['Tech', 'Career', 'Internship'],
      requiredSkills: ['Python', 'Data Analysis'],
    ),
    Opportunity(
      id: 'opp_004',
      title: 'Entrepreneurship Bootcamp',
      category: 'Workshops',
      description:
          'Intensive 3-day bootcamp on business model design, pitch preparation, and fundraising strategies. Culminates in a demo day with investor judges.',
      organizer: 'ALU Entrepreneurship Centre',
      date: DateTime.now().add(const Duration(days: 8)),
      time: '10:00 AM',
      location: 'Entrepreneurship Lab, Kigali',
      maxParticipants: 40,
      rsvpCount: 31,
      tags: ['Entrepreneurship', 'Business', 'Innovation'],
      requiredSkills: ['Project Management', 'Marketing'],
    ),
    Opportunity(
      id: 'opp_005',
      title: 'Design Thinking Workshop',
      category: 'Workshops',
      description:
          'Learn human-centred design methodology through hands-on exercises. Facilitated by experienced UX designers from top African tech companies.',
      organizer: 'Design Club',
      date: DateTime.now().add(const Duration(days: 3)),
      time: '02:00 PM',
      location: 'Studio B, Kigali Campus',
      maxParticipants: 30,
      rsvpCount: 27,
      tags: ['Design', 'Innovation', 'Tech'],
      requiredSkills: ['UI/UX', 'Graphic Design'],
    ),
    Opportunity(
      id: 'opp_006',
      title: 'Pan-African Debate Championship',
      category: 'Events',
      description:
          'Represent ALU at the inter-university Pan-African debate competition. Teams of 2. Topics focus on governance, economics, and social justice.',
      organizer: 'Debate Society',
      date: DateTime.now().add(const Duration(days: 21)),
      time: '03:00 PM',
      location: 'Conference Hall',
      maxParticipants: 16,
      rsvpCount: 10,
      tags: ['Debate', 'Leadership', 'Social Impact'],
      requiredSkills: ['Public Speaking', 'Writing'],
    ),
    Opportunity(
      id: 'opp_007',
      title: 'Data Science Bootcamp',
      category: 'Workshops',
      description:
          'Hands-on bootcamp covering Python for data analysis, machine learning fundamentals, and real dataset projects. Certificate upon completion.',
      organizer: 'AI & Data Club',
      date: DateTime.now().add(const Duration(days: 15)),
      time: '09:00 AM',
      location: 'Computer Lab 1',
      maxParticipants: 25,
      rsvpCount: 22,
      tags: ['Tech', 'Data Analysis', 'AI'],
      requiredSkills: ['Python', 'Data Analysis'],
    ),
    Opportunity(
      id: 'opp_008',
      title: 'Wellness & Mental Health Fair',
      category: 'Events',
      description:
          'A day dedicated to student wellbeing with yoga sessions, mental health talks, art therapy, and free counselling. Open to all students.',
      organizer: 'Wellness Club',
      date: DateTime.now().add(const Duration(days: 7)),
      time: '10:00 AM',
      location: 'Campus Gardens',
      maxParticipants: 200,
      rsvpCount: 84,
      tags: ['Wellness', 'Mental Health', 'Community'],
      requiredSkills: [],
    ),
    Opportunity(
      id: 'opp_009',
      title: 'Social Impact Startup Competition',
      category: 'Events',
      description:
          'Pitch your social impact startup idea to a panel of judges from top NGOs and impact investors. Top three teams win seed funding.',
      organizer: 'Impact Hub Kigali',
      date: DateTime.now().add(const Duration(days: 25)),
      time: '01:00 PM',
      location: 'Main Hall',
      maxParticipants: 30,
      rsvpCount: 19,
      tags: ['Social Impact', 'Entrepreneurship', 'Innovation'],
      requiredSkills: ['Project Management', 'Marketing'],
    ),
    Opportunity(
      id: 'opp_010',
      title: 'Flutter Mobile Dev Workshop',
      category: 'Workshops',
      description:
          'Build your first Flutter app in one day. This beginner-friendly workshop covers Dart basics, widgets, state management, and deploying to Android.',
      organizer: 'ALU Tech Club',
      date: DateTime.now().add(const Duration(days: 4)),
      time: '09:00 AM',
      location: 'Computer Lab 2',
      maxParticipants: 20,
      rsvpCount: 17,
      tags: ['Tech', 'Flutter', 'Mobile Dev'],
      requiredSkills: ['Flutter'],
    ),
    Opportunity(
      id: 'opp_011',
      title: 'Media & Journalism Internship',
      category: 'Internships',
      description:
          'Join a leading African media house for a 3-month internship covering digital journalism, video production, and social media strategy.',
      organizer: 'Career Services',
      date: DateTime.now().add(const Duration(days: 45)),
      time: 'Deadline',
      location: 'Kigali',
      maxParticipants: 5,
      rsvpCount: 4,
      tags: ['Arts & Culture', 'Media', 'Writing'],
      requiredSkills: ['Writing', 'Video Editing'],
    ),
    Opportunity(
      id: 'opp_012',
      title: 'Climate Action Hackathon',
      category: 'Hackathons',
      description:
          'Build tech solutions for environmental challenges facing Africa. Themes include clean energy, agriculture, and water management.',
      organizer: 'Environment Club',
      date: DateTime.now().add(const Duration(days: 18)),
      time: '08:00 AM',
      location: 'Innovation Hub',
      maxParticipants: 60,
      rsvpCount: 41,
      tags: ['Environment', 'Tech', 'Innovation'],
      requiredSkills: ['Python', 'Data Analysis', 'Project Management'],
    ),
    // Past events (for feedback demo)
    Opportunity(
      id: 'opp_013',
      title: 'ALU Founders Showcase 2024',
      category: 'Events',
      description:
          'Annual showcase of student-founded ventures. Networking with investors and ALU alumni who have successfully launched startups.',
      organizer: 'ALU Entrepreneurship Centre',
      date: DateTime.now().subtract(const Duration(days: 10)),
      time: '02:00 PM',
      location: 'Main Hall',
      maxParticipants: 100,
      rsvpCount: 100,
      tags: ['Entrepreneurship', 'Networking', 'Innovation'],
      requiredSkills: [],
    ),
    Opportunity(
      id: 'opp_014',
      title: 'Tech for Good Conference',
      category: 'Events',
      description:
          'Conference exploring technology\'s role in solving Africa\'s most pressing challenges. Speakers from Google, Andela, Flutterwave, and MTN.',
      organizer: 'ALU Tech Club',
      date: DateTime.now().subtract(const Duration(days: 20)),
      time: '09:00 AM',
      location: 'Main Auditorium',
      maxParticipants: 120,
      rsvpCount: 110,
      tags: ['Tech', 'Social Impact', 'Leadership'],
      requiredSkills: [],
    ),
  ];

  // ── Communities (6) ──────────────────────────────────────────────────────
  static final List<Community> communities = [
    const Community(
      id: 'com_001',
      name: 'ALU Tech Club',
      description:
          'The home for all things technology at ALU. We host hackathons, workshops, coding nights, and connect students with tech industry opportunities.',
      iconEmoji: '💻',
      memberCount: 234,
      postCount: 47,
      activityScore: 95,
      tags: ['Tech', 'Coding', 'Innovation'],
      campus: 'Both',
    ),
    const Community(
      id: 'com_002',
      name: 'Entrepreneurship Hub',
      description:
          'A community for aspiring entrepreneurs to share ideas, get mentorship, collaborate on ventures, and access funding opportunities.',
      iconEmoji: '🚀',
      memberCount: 189,
      postCount: 38,
      activityScore: 88,
      tags: ['Entrepreneurship', 'Business', 'Startups'],
      campus: 'Both',
    ),
    const Community(
      id: 'com_003',
      name: 'Leadership Circle',
      description:
          'Develop your leadership skills through workshops, guest lectures, and a mentorship programme connecting students with African leaders.',
      iconEmoji: '🌟',
      memberCount: 156,
      postCount: 29,
      activityScore: 72,
      tags: ['Leadership', 'Personal Development'],
      campus: 'Kigali',
    ),
    const Community(
      id: 'com_004',
      name: 'Arts & Culture Society',
      description:
          'Celebrating African culture through art, music, dance, film, and creative expression. Monthly showcases and collaborative projects.',
      iconEmoji: '🎨',
      memberCount: 98,
      postCount: 22,
      activityScore: 61,
      tags: ['Arts & Culture', 'Creative'],
      campus: 'Both',
    ),
    const Community(
      id: 'com_005',
      name: 'Environment & Sustainability',
      description:
          'Driving climate action and sustainable living at ALU. Tree planting drives, clean-up campaigns, and green policy advocacy.',
      iconEmoji: '🌿',
      memberCount: 112,
      postCount: 18,
      activityScore: 54,
      tags: ['Environment', 'Sustainability'],
      campus: 'Mauritius',
    ),
    const Community(
      id: 'com_006',
      name: 'Wellness & Mindfulness',
      description:
          'Your mental and physical health matters. Weekly yoga, meditation sessions, wellness talks, and peer support circles.',
      iconEmoji: '🧘',
      memberCount: 87,
      postCount: 14,
      activityScore: 45,
      tags: ['Wellness', 'Mental Health'],
      campus: 'Kigali',
    ),
  ];

  // ── Skill listings (10) ──────────────────────────────────────────────────
  static final List<SkillListing> skillListings = [
    SkillListing(
      id: 'skill_001',
      userId: 'user_042',
      userName: 'Kwame Mensah',
      userCampus: 'Kigali',
      skillTitle: 'Flutter Mentoring',
      category: 'Tech',
      description:
          'I can help you build your first Flutter app or review your existing codebase. Covers Dart, widgets, Provider, and Firebase integration.',
      mode: 'Both',
      availability: 'Weekends and Tuesday evenings',
      maxSessionsPerWeek: 3,
      rating: 4.9,
      sessionCount: 24,
      requestCount: 7,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SkillListing(
      id: 'skill_002',
      userId: 'user_015',
      userName: 'Amina Diallo',
      userCampus: 'Kigali',
      skillTitle: 'CV Review & Career Coaching',
      category: 'Career',
      description:
          'Alumni with 2 years at Google. I\'ll help polish your CV, prep for interviews, and find the right opportunities in African tech.',
      mode: 'Online',
      availability: 'Weekday mornings',
      maxSessionsPerWeek: 5,
      rating: 4.8,
      sessionCount: 42,
      requestCount: 12,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    SkillListing(
      id: 'skill_003',
      userId: 'user_078',
      userName: 'Chidi Okafor',
      userCampus: 'Mauritius',
      skillTitle: 'Graphic Design (Figma & Canva)',
      category: 'Design',
      description:
          'Proficient in Figma and Canva for UI design, branding, social media graphics, and pitch deck visuals. Portfolio available.',
      mode: 'Online',
      availability: 'Flexible — book via chat',
      maxSessionsPerWeek: 4,
      rating: 4.7,
      sessionCount: 18,
      requestCount: 5,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    SkillListing(
      id: 'skill_004',
      userId: 'user_033',
      userName: 'Fatima Al-Hassan',
      userCampus: 'Kigali',
      skillTitle: 'Public Speaking Practice',
      category: 'Speaking',
      description:
          'Former national debate champion. I run mock debates, TEDx-style talk prep, and help with presentation confidence and vocal delivery.',
      mode: 'In-person',
      availability: 'Thursdays and Saturdays',
      maxSessionsPerWeek: 4,
      rating: 5.0,
      sessionCount: 31,
      requestCount: 9,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    SkillListing(
      id: 'skill_005',
      userId: 'user_055',
      userName: 'Tunde Adeyemi',
      userCampus: 'Kigali',
      skillTitle: 'Python & Data Analysis Tutoring',
      category: 'Tech',
      description:
          'Covering Python basics through pandas, NumPy, and matplotlib. Great for beginners and students working on data science projects.',
      mode: 'Both',
      availability: 'Monday to Friday evenings',
      maxSessionsPerWeek: 5,
      rating: 4.6,
      sessionCount: 29,
      requestCount: 11,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    SkillListing(
      id: 'skill_006',
      userId: 'user_021',
      userName: 'Zanele Dlamini',
      userCampus: 'Mauritius',
      skillTitle: 'Academic Essay Writing',
      category: 'Writing',
      description:
          'Help with structure, argumentation, citations, and proofreading for academic papers. Especially good at Global Challenges essays.',
      mode: 'Online',
      availability: 'Weekends only',
      maxSessionsPerWeek: 3,
      rating: 4.5,
      sessionCount: 15,
      requestCount: 4,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    SkillListing(
      id: 'skill_007',
      userId: 'user_066',
      userName: 'Emmanuel Nkurunziza',
      userCampus: 'Kigali',
      skillTitle: 'Video Editing (Premiere Pro)',
      category: 'Design',
      description:
          'Professional-level video editing for vlogs, event recap videos, short documentaries, and social media reels.',
      mode: 'In-person',
      availability: 'Weekends',
      maxSessionsPerWeek: 2,
      rating: 4.8,
      sessionCount: 11,
      requestCount: 3,
      isAvailable: false,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    SkillListing(
      id: 'skill_008',
      userId: 'user_044',
      userName: 'Sophie Bergeron',
      userCampus: 'Mauritius',
      skillTitle: 'French Language Exchange',
      category: 'Speaking',
      description:
          'Native French speaker offering conversation practice, grammar help, and preparation for DELF/DALF exams. English in return!',
      mode: 'Both',
      availability: 'Tuesdays and Fridays',
      maxSessionsPerWeek: 4,
      rating: 4.9,
      sessionCount: 22,
      requestCount: 8,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    SkillListing(
      id: 'skill_009',
      userId: 'user_091',
      userName: 'Obinna Eze',
      userCampus: 'Kigali',
      skillTitle: 'Excel & Financial Modeling',
      category: 'Career',
      description:
          'Advanced Excel, pivot tables, financial modeling, and basic VBA. Ideal for Business and Entrepreneurship students.',
      mode: 'Online',
      availability: 'Weekday afternoons',
      maxSessionsPerWeek: 4,
      rating: 4.4,
      sessionCount: 17,
      requestCount: 6,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    SkillListing(
      id: 'skill_010',
      userId: 'user_037',
      userName: 'Laila Benali',
      userCampus: 'Mauritius',
      skillTitle: 'Pitch Deck Design',
      category: 'Design',
      description:
          'Helped 8 startups raise pre-seed funding with compelling pitch decks. Covers storytelling, slide design, and investor psychology.',
      mode: 'Online',
      availability: 'Flexible — book 48hrs in advance',
      maxSessionsPerWeek: 3,
      rating: 4.9,
      sessionCount: 26,
      requestCount: 14,
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
  ];

  // ── Chat messages per community ──────────────────────────────────────────
  static List<ChatMessage> messagesForThread(String threadId) {
    final names = ['Kwame', 'Fatima', 'Tunde', 'Zanele', 'Aline', 'Chidi'];
    final contents = [
      'Hey everyone! Excited for the upcoming event 🎉',
      'Same here! Are we meeting beforehand to coordinate?',
      'I think we should. How about Thursday at 4pm?',
      'Thursday works for me!',
      "Can't make Thursday. Can we do Friday morning?",
      'Friday morning is perfect. 10am at the Hub?',
      '10am confirmed ✅',
      'Great, see you all then. Bring your laptops!',
      'Will the slides be shared afterwards?',
      "Yes, I'll post them in this chat after 👍",
    ];
    return List.generate(10, (i) {
      final isOwn = i == 4 || i == 8;
      return ChatMessage(
        id: '${threadId}_msg_$i',
        threadId: threadId,
        senderId: isOwn ? 'user_001' : 'user_0${10 + i}',
        senderName: isOwn ? 'Aline' : names[i % names.length],
        content: contents[i],
        timestamp: DateTime.now().subtract(Duration(minutes: (10 - i) * 15)),
        isOwn: isOwn,
      );
    });
  }

  // ── Mock feedback (2 past events) ────────────────────────────────────────
  static final List<EventFeedback> mockFeedback = [
    // opp_013 — ALU Founders Showcase
    for (int i = 0; i < 24; i++)
      EventFeedback(
        id: 'fb_013_$i',
        eventId: 'opp_013',
        userId: 'user_${100 + i}',
        overallRating: [4, 5, 5, 4, 5, 4, 3, 5, 5, 4, 5, 5, 4, 4, 5, 4, 5, 3, 5, 4, 5, 5, 4, 4][i],
        contentRating: [4, 5, 4, 4, 5, 4, 3, 5, 4, 4, 5, 5, 4, 3, 5, 4, 5, 3, 4, 4, 5, 5, 4, 4][i],
        organizationRating: [5, 5, 5, 4, 5, 5, 4, 5, 5, 5, 5, 5, 4, 4, 5, 5, 5, 4, 5, 5, 5, 5, 5, 4][i],
        networkingRating: [4, 4, 5, 3, 5, 4, 3, 4, 5, 4, 5, 4, 4, 4, 5, 3, 5, 3, 4, 4, 5, 4, 4, 3][i],
        wouldRecommend: i != 6 && i != 17,
        comments: i % 5 == 0
            ? 'Amazing event, very well organised!'
            : i % 5 == 1
                ? 'Great networking opportunities with investors.'
                : i % 5 == 2
                    ? 'Could have more time for Q&A.'
                    : i % 5 == 3
                        ? 'Loved the startup pitches!'
                        : '',
        submittedAt: DateTime.now().subtract(Duration(days: i)),
      ),
    // opp_014 — Tech for Good
    for (int i = 0; i < 30; i++)
      EventFeedback(
        id: 'fb_014_$i',
        eventId: 'opp_014',
        userId: 'user_${200 + i}',
        overallRating: [5, 4, 5, 5, 4, 5, 4, 4, 5, 3, 5, 5, 4, 5, 4, 5, 5, 4, 5, 5, 4, 5, 5, 4, 3, 5, 5, 4, 5, 5][i],
        contentRating: [5, 5, 5, 4, 4, 5, 4, 4, 5, 4, 5, 5, 4, 5, 4, 4, 5, 4, 5, 5, 4, 5, 5, 4, 3, 5, 4, 4, 5, 5][i],
        organizationRating: [4, 4, 5, 4, 4, 5, 3, 4, 5, 3, 5, 4, 4, 5, 4, 5, 5, 4, 4, 5, 4, 5, 5, 3, 3, 5, 5, 4, 5, 5][i],
        networkingRating: [5, 4, 4, 5, 3, 4, 4, 3, 5, 3, 4, 5, 4, 5, 4, 4, 5, 3, 5, 5, 3, 4, 5, 4, 3, 5, 4, 3, 4, 5][i],
        wouldRecommend: i != 9 && i != 24,
        comments: i % 6 == 0
            ? 'World-class speakers, very inspiring!'
            : i % 6 == 1
                ? 'Flutterwave speaker was the highlight.'
                : i % 6 == 2
                    ? 'More interactive sessions next time please.'
                    : i % 6 == 3
                        ? 'Best conference I have attended at ALU.'
                        : i % 6 == 4
                            ? 'Venue was a bit crowded.'
                            : '',
        submittedAt: DateTime.now().subtract(Duration(days: i)),
      ),
  ];

  // ── Campus Pulse data ─────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> clubActivity = [
    {'id': 'com_001', 'name': 'ALU Tech Club', 'emoji': '💻', 'postCount': 47, 'activityScore': 95},
    {'id': 'com_002', 'name': 'Entrepreneurship Hub', 'emoji': '🚀', 'postCount': 38, 'activityScore': 88},
    {'id': 'com_003', 'name': 'Leadership Circle', 'emoji': '🌟', 'postCount': 29, 'activityScore': 72},
    {'id': 'com_004', 'name': 'Arts & Culture Society', 'emoji': '🎨', 'postCount': 22, 'activityScore': 61},
    {'id': 'com_005', 'name': 'Environment Club', 'emoji': '🌿', 'postCount': 18, 'activityScore': 54},
    {'id': 'com_006', 'name': 'Wellness Club', 'emoji': '🧘', 'postCount': 14, 'activityScore': 45},
  ];

  static final List<Map<String, dynamic>> trendingEvents = [
    {'id': 'opp_001', 'title': 'ALU Tech Hackathon 2025', 'rsvpCount': 67, 'capacity': 80},
    {'id': 'opp_002', 'title': 'Leadership Summit 2025', 'rsvpCount': 98, 'capacity': 150},
    {'id': 'opp_004', 'title': 'Entrepreneurship Bootcamp', 'rsvpCount': 31, 'capacity': 40},
  ];

  static final List<Map<String, dynamic>> discussedOpportunities = [
    {'id': 'opp_001', 'title': 'ALU Tech Hackathon 2025', 'commentCount': 34},
    {'id': 'opp_010', 'title': 'Flutter Mobile Dev Workshop', 'commentCount': 27},
    {'id': 'opp_002', 'title': 'Leadership Summit 2025', 'commentCount': 24},
    {'id': 'opp_004', 'title': 'Entrepreneurship Bootcamp', 'commentCount': 19},
    {'id': 'opp_012', 'title': 'Climate Action Hackathon', 'commentCount': 16},
  ];

  static final List<Map<String, dynamic>> fillingUpEvents = [
    {'id': 'opp_001', 'title': 'ALU Tech Hackathon 2025', 'rsvpCount': 67, 'capacity': 80},
    {'id': 'opp_005', 'title': 'Design Thinking Workshop', 'rsvpCount': 27, 'capacity': 30},
    {'id': 'opp_007', 'title': 'Data Science Bootcamp', 'rsvpCount': 22, 'capacity': 25},
    {'id': 'opp_010', 'title': 'Flutter Mobile Dev Workshop', 'rsvpCount': 17, 'capacity': 20},
  ];

  static const Map<String, int> campusMoodVotes = {
    'fire': 45,
    'happy': 32,
    'neutral': 12,
    'chill': 8,
  };

  // ── Mock notifications ───────────────────────────────────────────────────
  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'notif_001',
      'title': 'RSVP Reminder',
      'body': 'Leadership Summit 2025 is in 2 days. You\'re going! 🎉',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': 'notif_002',
      'title': 'New Message',
      'body': 'Kwame sent a message in ALU Tech Club',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': false,
    },
    {
      'id': 'notif_003',
      'title': 'Skill Request',
      'body': 'Someone requested your Flutter Mentoring skill',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
    {
      'id': 'notif_004',
      'title': 'Event Filling Up',
      'body': 'Design Thinking Workshop is 90% full — only 3 spots left!',
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'isRead': true,
    },
    {
      'id': 'notif_005',
      'title': 'New Opportunity',
      'body': 'A new internship matching your profile was posted',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
  ];
}
