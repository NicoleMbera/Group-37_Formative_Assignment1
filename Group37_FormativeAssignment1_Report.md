# ALU Connect: Technical Report

**Group 37 | Mobile Application Development | June 2026**

---

## 1. Overview

ALU students find out about events through WhatsApp groups, forwarded emails, and whoever happens to mention something in the hallway. If you are not in the right chat, you miss things. We wanted a single place for all of it.

The app lets club leaders, organizers, and student entrepreneurs post opportunities. Students browse, RSVP, message people, and track what they have attended. The basics (login, feed, RSVP, chat, profiles, navigation) are there.

**Core thesis:** The right opportunity, shown to the right student, at the right time, without requiring them to search for it.

On top of that, we built four things we think matter:

**Opportunity Match Score.** The feed ranks events based on who you are: your interests, pathway, skills, communities, and what you have attended before. A CS major sees hackathons near the top. A Global Challenges student sees policy events. The algorithm is weighted matching in pure Dart with five axes. It means the feed does not feel like noise.

**Campus Pulse.** A dashboard that shows what is active: which clubs are getting engagement, which events are filling up, what people are talking about, and a daily campus mood poll. The Pulse tab is deliberately not a chronological feed. It is a curated snapshot ranked by activity score, capacity urgency, and comment count. This pushes students toward trending content instead of passive scrolling.

**Skill Exchange Marketplace.** Students post what they can help with and what they need. Flutter, CV writing, public speaking, design. This kind of peer help happens at ALU already. The marketplace just makes it findable.

**Event Feedback Analytics.** After events, attendees rate and give feedback. Organizers get aggregated scores and attendance data. Right now, nobody at ALU systematically knows whether their event worked. This closes that loop.

---

## 2. UI/UX Decisions

We used a light theme with **ALU Red (#C8102E)** as the primary colour and **Gold (#FFB300)** for accents and badges. Poppins is the typeface across the app at 10sp to 28sp. Cards are white on a light grey surface (#F5F5F5) with subtle borders and no elevation. Keeps things clean without material shadow clutter. The colour system lives in a single `AppColors` constants file with named tokens for category colours, match score thresholds, and semantic roles (error, subtle text) [1].

The bottom navigation has six destinations: **Home, Explore, Skills, Clubs, Pulse, and Profile**. A floating action button sits in a centre notch for posting opportunities. Most event apps hide posting in a menu. We did not. At ALU, the person attending an event and the person organising one is often the same student on a different day. The design should not separate those roles. Though posting is role-gated (only organisers, club leaders, and staff can create opportunities). Students who tap the FAB see a bottom sheet explaining the restriction instead of a dead end.

We used an **IndexedStack** to preserve tab state when switching between nav destinations. Early on we rebuilt screens on every tab switch and lost scroll position and loaded data. IndexedStack keeps each tab alive so the feed, pulse dashboard, and skill listings stay exactly where the user left them.

We also thought about accessibility. Text sits on contrasting surfaces. Tap targets stay at 48x48dp minimum, following Material Design guidance [2]. Font sizes start at 12sp for labels and go up to 28sp for headers. We have not run the app through a screen reader or high-contrast mode. That is a real gap, and I do not want to pretend otherwise. But the foundations are there.

Event detail screens show attendee avatars and RSVP counts right below the cover image. Students at ALU decide whether to go to something partly based on who else is going. Making that visible without extra taps felt worth the screen space.

---

## 3. Technical Architecture

### Stack

| Component | Choice | Why |
|---|---|---|
| Language | Dart + Flutter | Course requirement |
| State management | Provider (9 ChangeNotifiers) | Lightweight, no boilerplate, right for this scale [3] |
| Local database | sqflite | Persistent feed, messages, feedback, and skills |
| Key-value storage | SharedPreferences | Onboarding progress, RSVPs, user profile, mood vote |
| Charts | fl_chart | Feedback analytics bar charts and trends |
| Loading skeletons | Shimmer | Card-shaped placeholders instead of a spinner |
| Typography | Google Fonts (Poppins) | Consistent with ALU brand feel |

### Provider Layer

We split state into nine single-responsibility providers, each extending `ChangeNotifier`:

- **AuthProvider** — Mock account login (email/password), user profile persistence via SharedPreferences
- **FeedProvider** — Opportunity list, filtering, search, and match score calculation
- **RsvpProvider** — RSVP state (going/interested), persisted per event
- **CommunityProvider** — Club directory, joined communities
- **ChatProvider** — Per-thread messages via sqflite
- **FeedbackProvider** — Event feedback submissions, analytics (averages, distributions, recommendation rate)
- **SkillProvider** — Skill listings, filter and search, availability toggling
- **CampusPulseProvider** — Daily mood voting, club activity scores, trending events
- **NotificationProvider** — In-app notification badges

This separation means changing RSVPs does not rebuild the feed. Chat messages update only the active conversation. The match score runs in `FeedProvider` but reads user data from `AuthProvider` through consumer widgets.

### Match Score Algorithm

The `MatchScoreService` calculates a 0-100 score per opportunity using five axes:

1. **Interest overlap (max 40)** — +20 per matching tag between the user's interests and the opportunity's tags
2. **Pathway match (20)** — +20 if the user's academic pathway maps to the opportunity category (e.g., CS to hackathons, Business to entrepreneurship workshops)
3. **Skills overlap (max 30)** — +15 per matching skill between the user's skills and the opportunity's required skills
4. **Community connection (10)** — +10 if the opportunity is posted by a club the user has joined
5. **Past attendance (10)** — +10 if the user has attended a similar category before

The score is recalculated every time the feed loads. Change your interests or skills, the feed re-ranks immediately. There is no machine learning. It is weighted matching in a Dart service class. That is all it needs to be.

### Data Layer

The app uses dual local persistence: sqflite for structured content (opportunities, messages, feedback, skills) and SharedPreferences for key-value state (onboarding, RSVPs, user profile, daily mood vote). Mock data is seeded into sqflite on first launch with 14 opportunities, 6 communities with chat threads, 10 skill listings, and feedback entries for 2 past events. The `DatabaseService` mirrors a real API surface (typed models, `Future`-based queries, async loading) so swapping in a backend later means replacing the data source, not rebuilding the UI.

---

## 4. Standout Features

### Campus Pulse

Instead of a static event list, the Pulse tab shows club activity scores, trending events, opportunities being discussed, events filling up, and a daily campus mood poll. The `CampusPulseProvider` merges mock data with the user's own vote (one per day, persisted in SharedPreferences). fl_chart renders the mood distribution and activity rankings as bar charts.

### Skills Marketplace

Students list skills they can teach and skills they want to learn. Each listing shows availability, session limits, and ratings. The SkillProvider supports category filtering and search. Chats open directly from a skill listing so students can arrange sessions without leaving the app.

### Event Feedback Analytics

Organisers see post-event analytics for their past events: average ratings across four categories (overall, content, organisation, networking), rating distribution, and recommendation percentage. The `FeedbackProvider` calculates these from sqflite-stored feedback entries. Students submit feedback through a multi-step form after events end.

### Role-Split Dashboard

The Home tab renders differently depending on the user's role. Students see a search bar, category chips, matched opportunities, their RSVPs, and the latest feed. Organisers see event statistics (total events, total RSVPs, past events), a "Post Now" CTA, their posted events with RSVP capacity bars, and analytics shortcuts for past events. This is a single tab that switches between two widget trees based on `user.isOrganizer`.

---

## 5. Design Decisions & Challenges

**Mock accounts instead of real auth.** We used a `_mockAccounts` map with seven preset users (Fatima the organiser, Kwame the club leader, Dr. Nkosi the staff member) keyed by email. This let us test different roles, campuses, and permission levels without building a backend. The trade-off: anyone can log in as anyone by knowing the email. For a prototype it was the right call. For production this would move to Firebase Auth or a custom API.

**Client-side match scoring.** The algorithm runs entirely in Dart on the mock data. Keeps the prototype self-contained, but the match score is recalculated on every feed load instead of queried from a database. With 14 opportunities the cost is negligible. At scale it would need an indexed backend query.

**Role not persisted on login.** The login tab initially assigned `role: 'Student'` to everyone. Organiser credentials logged in but never unlocked the dashboard or post functionality. That was frustrating to debug because the login itself worked fine. The fix was adding the `_mockAccounts` map that maps known emails to preset name/role/campus triples. Matching emails get the correct role. Everything else defaults to Student.

**Bottom nav overflow.** A fixed-height `SizedBox` inside the `BottomAppBar` conflicted with system navigation bar insets. Produced an 11-pixel RenderFlex overflow on devices with gesture navigation. The fix: remove the fixed height, set `BottomAppBar(padding: EdgeInsets.zero)`, and give each `_NavItem` intrinsic height via `Padding(vertical: 8)`. The system handles safe-area space from there.

**Skills not in bottom nav.** The Skills Marketplace was reachable only via a named route, not from the bottom navigation. Users thought skill posting was restricted. We promoted Skills to a first-class bottom nav tab (index 2), between Explore and the FAB notch. Should have been there from the start. That one was not hard to fix.

**sqflite cold-start delay.** Seeding 14 opportunities, 10 skill listings, 54 feedback entries, and 60 chat messages in `onCreate` caused a noticeable delay on first launch. We batched all inserts into a single `db.batch().commit()` call. One transaction instead of dozens. Solved it.

---

## 6. What We Left Out

We cut gamification badges, live polling, and achievement tracking. They looked good in early sketches but added visual noise without solving a real problem students have. The biggest gap is offline support. Campus wifi drops regularly and the app has no offline-first mode beyond what sqflite already caches. Screen reader and high-contrast mode testing is also missing. The light theme and tap targets are solid but we have not verified them with actual accessibility tools. We would address both in the next iteration.

---

## 7. AI Usage Disclosure

AI tooling (Claude Code) was used for code scaffolding, boilerplate generation, and debugging assistance. All architectural decisions, feature designs, and UX rationale in this report came from the team's own thinking and were developed through discussion and iteration. Team members can explain every implementation decision, modify the codebase live, and justify all product choices during evaluation. The match score algorithm, the role-split dashboard design, the dual-persistence strategy, and the Campus Pulse concept were all defined by the team before any code was generated.

---

## 8. GitHub & Collaboration

Repository: `https://github.com/NicoleMbera/Group-37_Formative_Assignment1`

Each team member maintains an individual feature branch. The project structure follows a layered architecture: `constants to models to services to providers to screens to widgets`, with files organised across 9 providers, 7 models, 3 services, 12 reusable widgets, and 19 screens.

---

## 9. Contribution Tracker

The group contribution tracker (Google Sheets) is available at:

> https://docs.google.com/spreadsheets/d/1cQnpGrZwLKjR2C3f08LKVMeespAox91QRAU136VOezw/edit?usp=sharing

---

## References

[1] "Material Design 3 - Color tokens," Google. [Online]. Available: https://m3.material.io/styles/color/color-tokens. [Accessed: Jun. 11, 2026].

[2] "Material Design 3 - Accessibility," Google. [Online]. Available: https://m3.material.io/foundations/accessibility. [Accessed: Jun. 11, 2026].

[3] "State management - Provider," Flutter Documentation, Google. [Online]. Available: https://docs.flutter.dev/data-and-backend/state-mgmt. [Accessed: Jun. 11, 2026].
