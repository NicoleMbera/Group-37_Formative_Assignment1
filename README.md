# ALU Connect

A mobile app for African Leadership University students to discover opportunities, join communities, exchange skills, and stay connected with what is happening on campus.

Built with Flutter for Android and iOS.

## What it does

Students can browse a personalised feed of events, hackathons, workshops, and internships. The feed is ranked by a match score that compares each opportunity against the student's interests, academic pathway, and skills. RSVPs are saved locally and appear on the home screen immediately.

Club leaders and event organisers get a separate dashboard where they can post opportunities, track how many students have registered for each event, and view post-event feedback analytics.

The Skills Marketplace lets any student offer help in an area they are good at, whether that is Flutter development, essay writing, public speaking, or data analysis. Other students can request a session, which opens a direct message thread with the person offering the skill.

Campus Pulse is a discovery tab that surfaces the most active clubs, events that are filling up quickly, and a daily mood poll.

## Running the app

You need Flutter installed. Clone the repo, then run:

```
flutter pub get
flutter run
```

The app uses sqflite and SharedPreferences for local storage. No backend or internet connection is required. All data is seeded on first launch.

## Test accounts

Use any of these on the login screen. The password can be anything.

| Email | Role |
|---|---|
| organizer@alu.edu | Event Organizer |
| clubleader@alu.edu | Club Leader |
| staff@alu.edu | Academic Staff |
| aline@alustudent.com | Student |

You can also register a new account and choose your role from the dropdown.

## Project structure

```
lib/
  constants/    colours, typography, strings
  models/       data classes for users, events, communities, feedback, skills
  services/     database (sqflite), preferences (SharedPreferences), match scoring
  providers/    state management with Provider (9 providers total)
  screens/      19 screens across onboarding, auth, home, explore, communities,
                chat, skills, campus pulse, feedback, and profile
  widgets/      12 reusable widgets including cards, chips, charts, and loaders
```

## Key features

**Match score** — each opportunity is scored against the current user's profile across five dimensions: interest overlap, academic pathway, skills, community membership, and past attendance. The algorithm lives in `lib/services/match_score_service.dart` and runs entirely on-device.

**Role-based dashboard** — organisers and club leaders see a different home screen with event management tools, RSVP capacity tracking, and feedback analytics. Students see the personalised feed.

**Persistent state** — RSVPs, interests, pathway, and the mood poll vote are stored in SharedPreferences. Chat messages, feedback entries, skill listings, and opportunities are stored in sqflite.

**Post-event feedback** — after an event date passes, RSVP'd students see an option to rate the event across five categories. Organisers can view aggregated analytics with a bar chart and per-category scores.

## Dependencies

Provider, sqflite, SharedPreferences, Google Fonts (Poppins), fl_chart, percent_indicator, shimmer, image_picker, intl.
