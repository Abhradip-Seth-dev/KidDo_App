# 🚀 KidDo App - Gamified Learning & Quiz Platform for Kids

KidDo is an interactive, gamified learning application built with **Flutter (Frontend)** and **Node.js + Express + PostgreSQL (Backend)**. The backend uses Prisma for database access and schema migrations. It combines lessons, subject quizzes, and brain-training games with a dual-currency progression system.

---

## ✨ Key Features

- **🎓 Interactive Lessons & Quizzes**: Engaging quiz modes with live streak tracking, instant audio-visual feedback, and mascot animations.
- **🎮 Progressive Game Hub**:
  - *Math Puzzle* (Algebraic logic & patterns)
  - *Word Scramble* (Vocabulary building)
  - *Memory Match* (Visual memory & speedrun challenges)
- **🧠 Dual-Currency & Level System**:
  - **IQ (`assets/images/IQ.png`)**: Experience points (EXP) used for global leaderboards, unlocking lessons/games, and leveling up leagues.
  - **Coins (`assets/images/coin.png`)**: Spendable currency earned by beating levels and challenges, redeemable in the KidDo Shop.
- **🛍️ KidDo Shop**: In-game shop to unlock avatar skins, custom themes, and streak powerups.
- **✨ Animated Auth & Mascot**:
  - Rive interactive yeti animation with eye tracking, password face-covering, and reactions.
  - Google Sign-In with device account picker.
  - Profile onboarding and survey customization.

---

## 🏗️ Project Structure

```
KidDO_APP/
├── backend/                  # Node.js + Express + PostgreSQL REST API
│   ├── src/
│   │   ├── controllers/      # Auth, Games, Quiz, Shop, Users controllers
│   │   ├── prisma.js         # Prisma client and API response formatting
│   │   ├── routes/           # REST API routes
│   │   ├── middleware/       # JWT Auth verification
│   │   ├── server.js         # Server entry point
│   │   └── app.js            # Express app configuration
│   ├── prisma/schema.prisma  # PostgreSQL data model
│   ├── prisma/migrations/    # Checked-in database migrations
│   └── docker-compose.yml    # Local PostgreSQL service
│   └── package.json
│
└── kiddo_app/                # Flutter Frontend Application
    ├── lib/
    │   ├── core/             # Routing, Providers, API clients, Data Models
    │   ├── features/
    │   │   ├── Auth/         # Animated Rive Login & Sign Up
    │   │   ├── home/         # Home Dashboard & Mascot
    │   │   ├── lessons/      # Subject Lessons & Units
    │   │   ├── games/        # Math Puzzle, Word Scramble, Memory Match
    │   │   ├── quiz/         # Quiz Engine & Streak Celebrations
    │   │   ├── leaderboard/  # Real-time IQ Leaderboard & Podium
    │   │   ├── shop/         # Coin Store & Avatar customizer
    │   │   ├── user/         # Profile, League Rank & Settings
    │   │   └── onboarding_Screen/ # Multi-step Survey & Welcome
    │   └── main.dart
    └── pubspec.yaml
```

---

## 🛠️ Getting Started

### 1. Backend Setup
```bash
cd backend
cp .env.example .env
# Start the local PostgreSQL database
docker compose up -d postgres
npm install
npm run db:deploy
npm run seed
npm run dev
```

See [backend/README.md](backend/README.md) for database migration and existing database setup notes.

### 2. Frontend Setup
```bash
cd kiddo_app
flutter pub get
flutter run
```
