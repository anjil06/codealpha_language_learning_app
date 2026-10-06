# LinguaLearn 🌍

**LinguaLearn** is a modern, interactive Language Learning Mobile Application designed with Flutter, Dart, Riverpod, Material 3, and Firebase. It empowers learners to acquire and master new languages through daily structured lessons, categorized vocabulary, interactive 3D flashcards, pronunciation practice, grammar rules, comprehensive multi-type quizzes, and a gamified progress tracking system with streaks, XP, and levels.

---

## 🚀 Key Highlights & Features

### 1. 🌟 Onboarding Flow
- **Interactive 4-Screen Carousel**:
  - Screen 1: *Learn a New Language*
  - Screen 2: *Learn Every Day*
  - Screen 3: *Test Your Knowledge*
  - Screen 4: *Language Selection* with flag emblems, total lessons, and greeting intros.
- Supported languages: **Spanish, French, German, Japanese, Korean, Hindi, Telugu**.
- Persisted completion state via `SharedPreferences`.

### 2. 🔐 Authentication & Profile
- **Firebase Authentication & Offline Fallback**:
  - Email/Password sign up and sign in.
  - Form validation for Name, Email, Password, Confirm Password, and Target Language.
  - Forgot Password with password reset dispatch flow.
  - Safe offline local user session mode allowing instantaneous demonstration without needing a live cloud backend.
- Profile dashboard showing custom avatar, user metrics, level badges, and edit profile dialog.

### 3. 🏠 Home Dashboard
- Personalized greeting ("Hello, Anjil 👋").
- **Daily Learning Goal** tracking with dynamic progress bar (`7 / 10 lessons completed`).
- **Current Streak Badge** (🔥 5 Day Streak) and XP badge.
- **Today's Lesson Card** ("Daily Vocabulary – Greetings", 10 new words, Start Lesson CTA).
- **Quick Action Buttons**: Direct navigation to *Vocabulary*, *Grammar*, *Flashcards*, and *Quizzes*.
- **Continue Learning**: Direct link into the next unfinished course module.

### 4. 📚 Daily Lessons & Structured Learning
- Step-by-step modular lesson structure:
  1. **Introduction**: Cultural and linguistic context.
  2. **New Vocabulary**: Key terms with English meanings and native TTS audio.
  3. **Pronunciation Guide**: Detailed phonetic breakdowns and accent rules.
  4. **Example Sentences**: Realistic bilingual conversational sentences.
  5. **Mini Practice**: In-lesson interactive check-up questions with instant feedback.
  6. **Lesson Completion**: XP awards (+20 XP), streak celebration dialog, and quiz direct launch.

### 5. 🗂️ Vocabulary Lab
- 13 distinct categories:
  *Greetings, Food, Travel, Family, Work, Education, Shopping, Numbers, Time, Colors, Animals, Technology, Daily Activities*.
- Real-time search across target words, phonetics, and English meanings.
- Native Text-to-Speech (TTS) speaker button for every single word and example sentence.
- Phonetic guides (e.g. `/oh-la/`).

### 6. ⚡ Interactive Flashcards
- **3D Card Flip Animation**: Smooth perspective transform to reveal English translations and examples.
- **Mastery Controls**: "Known ✓" and "Don't Know ✕" tracking.
- Real-time session progress and completion summary:
  - Accuracy percentage.
  - Mastered word counts.
  - **Review Difficult Words**: Target-practice deck isolating missed cards.

### 7. 📖 Grammar Section
- Detailed lessons for:
  - Basic Sentence Structure (SVO pattern, pronoun omission, inverted punctuation).
  - Subject Pronouns (Yo, Tú, Él, Ella, Usted, Nosotros, etc.).
  - Present Tense Regular Verbs (-AR, -ER, -IR families).
- Structured with clear explanations, bulleted rules, audio-enabled examples, and concept checking practice questions.

### 8. 🎙️ Pronunciation Lab
- "Listen and Repeat" drill system.
- Native Text-to-Speech playback for clear pronunciation modeling.
- Microphone practice flow with animated waveform visualization.
- Acoustic accuracy feedback score (85–98%) with honest simulation disclosure.

### 9. 🧠 Interactive Multi-Type Quizzes & Results
- Supports 5 distinct question types:
  1. **Multiple Choice**
  2. **Translation**
  3. **Word Matching** (interactive paired chip selection)
  4. **Fill in the Blank**
  5. **Listening Comprehension** (audio playback prompt with choice identification)
- **Quiz Results Dashboard**:
  - Score & accuracy percentage (e.g., 8 / 10, 80%).
  - Correct vs. Wrong counts.
  - XP earned (+30 XP) & words learned.
  - Current streak persistence.
  - Recommended next lesson.

### 10. 📊 Progress & Gamification Dashboard
- **Gamification Mechanics**:
  - **XP System**: +20 XP (lessons), +30 XP (quizzes), +5 XP (vocabulary), +10 XP (daily login/pronunciation).
  - **Levels 1–5**: Beginner, Explorer, Learner, Speaker, Fluent Starter.
  - **Achievements**: First Lesson (🏆), 7 Day Streak (🔥), 100 Words (📚), 90% Quiz Score (🎯), Flashcard Ace (⚡).
- **Weekly Learning Activity Chart**: Day-by-day learning minutes histogram.

### 11. ⚙️ Settings & Theme Support
- Full **Material 3 Light and Dark Themes**.
- Learning language switching with instant data reload.
- Daily goal adjustment (5, 10, 15, 20 lessons/day).
- Pronunciation audio, sound effects, and reminder toggles.
- About dialog, Terms of Service, and Privacy Policy dialogs.

---

## 🏗️ Architecture & Project Structure

The project follows clean Flutter architecture principles with strict separation between UI, State (Riverpod), Repositories, Services, and Models:

```text
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp with theme & router
│   ├── routes.dart                # Declarative GoRouter configuration
│   └── theme.dart                 # Material 3 Light and Dark themes
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Unified brand & gamification palette
│   │   ├── app_constants.dart     # Keys, thresholds, and XP rewards
│   │   └── sample_data.dart       # Prepopulated Spanish learning content
│   ├── services/
│   │   ├── app_providers.dart     # Riverpod Notifiers & query providers
│   │   ├── firebase_service.dart  # Safe Firebase initialization
│   │   ├── storage_service.dart   # SharedPreferences cache manager
│   │   └── tts_service.dart       # Text-to-speech audio pronunciation
│   └── widgets/
│       ├── app_logo.dart          # LinguaLearn branding logo
│       ├── custom_button.dart     # Primary, secondary & outline buttons
│       ├── empty_view.dart        # Reusable empty state widget
│       ├── error_view.dart        # Friendly error handling widget
│       └── stat_badge.dart        # Streak, XP, and Level badges
│
├── models/
│   ├── grammar_model.dart         # Grammar explanations & questions
│   ├── language_model.dart        # Supported languages & metadata
│   ├── lesson_model.dart          # Structured daily lessons
│   ├── progress_model.dart        # Streaks, scores & achievements
│   ├── quiz_model.dart            # Multi-type quizzes & results
│   ├── user_model.dart            # User profile data model
│   └── vocabulary_model.dart      # Vocabulary words & translations
│
├── repositories/
│   ├── auth_repository.dart       # Firebase Auth & local fallback
│   ├── lesson_repository.dart     # Lesson queries & completion tracking
│   ├── progress_repository.dart   # XP rewards, achievements & sync
│   ├── quiz_repository.dart       # Quiz retrieval & question scoring
│   └── vocabulary_repository.dart # Categories, search & flashcard deck
│
└── features/
    ├── auth/                      # Login, register, forgot password
    ├── flashcards/                # 3D interactive flashcards
    ├── grammar/                   # Grammar list & detail screens
    ├── home/                      # Dashboard & language selection
    ├── learn/                     # Learn Hub (Lessons, Vocab, Grammar)
    ├── lessons/                   # Structured lesson screens
    ├── main_layout/               # 5-branch Bottom Navigation shell
    ├── onboarding/                # 4-screen onboarding carousel
    ├── practice/                  # Practice Hub (Flashcards, Quiz, Pronunciation)
    ├── profile/                   # User profile & app settings
    ├── progress/                  # Analytics & achievements dashboard
    ├── pronunciation/             # TTS and microphone practice lab
    ├── quiz/                      # Interactive quiz & result screens
    └── vocabulary/                # Searchable vocabulary directory
```

---

## 🔒 Firebase Firestore & Security Rules

### Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }

    // Public educational content (read-only for all)
    match /languages/{languageId} { allow read: if true; allow write: if false; }
    match /lessons/{lessonId} { allow read: if true; allow write: if false; }
    match /vocabulary/{vocabularyId} { allow read: if true; allow write: if false; }
    match /grammar/{grammarId} { allow read: if true; allow write: if false; }
    match /quizzes/{quizId} { allow read: if true; allow write: if false; }

    // Private user data (owner access only)
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isOwner(userId);
    }
    match /userProgress/{userId} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

---

## 🧪 Testing & Verification

All automated tests and static analysis pass with 0 warnings:

```bash
# Run static analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

---

## 📱 Running the Application

### Prerequisites
* Flutter SDK (3.44+)
* Dart SDK (3.12+)
* Android Studio / VS Code with Flutter extension
* Android Device or Emulator / Windows Desktop

### Run Command
```bash
flutter pub get
flutter run
```
