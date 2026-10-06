# Cloud Firestore Database Schema & Architecture

This document details the database schema, data types, security models, and indexing strategies implemented in **LinguaLearn**.

---

## 1. Collections Hierarchy

```text
users (Collection)
 └── {userId} (Document)
      ├── id: string (Auth UID)
      ├── name: string
      ├── email: string
      ├── learningLanguage: string (e.g., "Spanish")
      ├── xp: number
      ├── level: number (1–5)
      ├── streak: number (consecutive active days)
      ├── dailyGoal: number (e.g., 10 lessons)
      ├── lessonsCompleted: number
      ├── wordsLearned: number
      ├── createdAt: timestamp / ISO8601 string
      └── avatarUrl: string (optional)

languages (Collection)
 └── {languageId} (Document)
      ├── id: string (e.g., "spanish", "french")
      ├── name: string
      ├── code: string ("es", "fr", "de", "ja", "ko", "hi", "te")
      ├── flag: string (emblem / flag emoji)
      ├── totalLessons: number
      ├── progressPercentage: number
      ├── greeting: string
      └── ttsLocale: string

lessons (Collection)
 └── {lessonId} (Document)
      ├── id: string
      ├── languageId: string ("spanish")
      ├── title: string
      ├── category: string
      ├── description: string
      ├── difficulty: string ("Beginner" | "Intermediate" | "Advanced")
      ├── order: number
      ├── estimatedMinutes: number
      ├── introduction: string
      ├── vocabularyWords: array<string>
      ├── vocabularyMeanings: array<string>
      ├── pronunciationGuide: string
      ├── exampleSentences: array<map<string, string>>
      ├── miniPractice: array<map>
      ├── quizId: string
      └── isCompleted: boolean

vocabulary (Collection)
 └── {vocabularyId} (Document)
      ├── id: string
      ├── languageId: string
      ├── category: string ("Greetings", "Food", "Travel", "Family", etc.)
      ├── word: string
      ├── translation: string
      ├── pronunciation: string (phonetic)
      ├── exampleSentence: string
      ├── exampleTranslation: string
      ├── audioUrl: string (optional Cloud Storage URL)
      └── isMastered: boolean

grammar (Collection)
 └── {grammarId} (Document)
      ├── id: string
      ├── languageId: string
      ├── title: string
      ├── category: string
      ├── explanation: string
      ├── keyRules: array<string>
      ├── examples: array<map>
      └── practiceQuestions: array<map>

quizzes (Collection)
 └── {quizId} (Document)
      ├── id: string
      ├── languageId: string
      ├── lessonId: string
      ├── title: string
      ├── description: string
      ├── difficulty: string
      └── questions: array<map>
            ├── id: string
            ├── type: string ("multipleChoice" | "translation" | "wordMatching" | "fillInBlank" | "listening")
            ├── question: string
            ├── options: array<string>
            ├── correctAnswer: string
            ├── matchingPairs: map<string, string> (for word matching)
            ├── audioPrompt: string (for listening questions)
            └── explanation: string

userProgress (Collection)
 └── {userId} (Document)
      ├── userId: string
      ├── completedLessons: array<string>
      ├── learnedWords: array<string>
      ├── completedGrammar: array<string>
      ├── quizScores: map<string, number> (quizId -> score percentage)
      ├── streak: number
      ├── lastActiveDate: timestamp / ISO8601 string
      ├── weeklyActivity: map<string, number> ("Mon": 25, "Tue": 35, etc.)
      └── achievements: array<map>
            ├── id: string
            ├── title: string
            ├── description: string
            ├── icon: string
            ├── isUnlocked: boolean
            └── unlockedAt: timestamp
```

---

## 2. Offline-First Synchronization Strategy

1. **Local-First Writes**:
   All user progress, completed flashcard decks, mastered words, and lesson completions are immediately recorded to `StorageService` via persistent `SharedPreferences`.
2. **Background Firestore Sync**:
   When network connectivity and Firebase configuration are active, `ProgressRepository` asynchronously synchronizes the latest progress snapshot to `cloud_firestore` under `/userProgress/{userId}`.
3. **Graceful Fallback**:
   If the app is executed in an offline environment or prior to linking a Google Cloud service project, default educational datasets in `SampleData` ensure 100% functionality without crashes or missing screens.

