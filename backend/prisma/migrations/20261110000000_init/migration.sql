-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT,
    "googleId" TEXT,
    "avatarUrl" TEXT NOT NULL DEFAULT 'assets/images/kido_character.png',
    "age" INTEGER NOT NULL DEFAULT 8,
    "gradeClass" TEXT NOT NULL DEFAULT 'Class 3',
    "hasCompletedOnboarding" BOOLEAN NOT NULL DEFAULT false,
    "role" TEXT NOT NULL DEFAULT 'student',
    "isBanned" BOOLEAN NOT NULL DEFAULT false,
    "forceLogoutBefore" TIMESTAMP(3),
    "deviceType" TEXT NOT NULL DEFAULT 'iOS/Android',
    "appVersion" TEXT NOT NULL DEFAULT '1.0.0',
    "lastLoginAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "iq" INTEGER NOT NULL DEFAULT 0,
    "coins" INTEGER NOT NULL DEFAULT 0,
    "streak" INTEGER NOT NULL DEFAULT 0,
    "longestStreak" INTEGER NOT NULL DEFAULT 0,
    "lastActiveDate" TIMESTAMP(3),
    "totalQuizzesCompleted" INTEGER NOT NULL DEFAULT 0,
    "totalGamesPlayed" INTEGER NOT NULL DEFAULT 0,
    "completedUnits" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "currentUnitBySubject" JSONB NOT NULL DEFAULT '{"Math":1,"GK":1,"English":1,"Computer":1}',
    "completedQuizzes" JSONB NOT NULL DEFAULT '[]',
    "ownedItemIds" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "activeTheme" TEXT NOT NULL DEFAULT 'default',
    "activeAvatar" TEXT NOT NULL DEFAULT '',
    "streakFreezes" INTEGER NOT NULL DEFAULT 1,
    "hasFeedSubscription" BOOLEAN NOT NULL DEFAULT false,
    "learningMinutesToday" INTEGER NOT NULL DEFAULT 0,
    "weeklyActivityMinutes" INTEGER[] DEFAULT ARRAY[15, 20, 10, 25, 30, 0, 15]::INTEGER[],
    "parentPin" TEXT NOT NULL DEFAULT '1234',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuizQuestion" (
    "id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "gradeClass" TEXT NOT NULL DEFAULT 'Class 3',
    "chapter" TEXT NOT NULL DEFAULT 'Chapter 1',
    "unitNumber" INTEGER NOT NULL,
    "unitName" TEXT NOT NULL,
    "quizName" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'MCQ',
    "options" TEXT[],
    "correctAnswer" TEXT NOT NULL,
    "correctIndex" INTEGER NOT NULL,
    "imageAsset" TEXT,
    "explanation" TEXT,
    "difficulty" TEXT NOT NULL DEFAULT 'easy',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QuizQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LevelProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "levelId" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'locked',
    "stars" INTEGER NOT NULL DEFAULT 0,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LevelProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuizAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "score" INTEGER NOT NULL,
    "correctCount" INTEGER NOT NULL,
    "totalQuestions" INTEGER NOT NULL DEFAULT 5,
    "iqEarned" INTEGER NOT NULL DEFAULT 0,
    "coinsEarned" INTEGER NOT NULL DEFAULT 0,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QuizAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Game" (
    "id" TEXT NOT NULL,
    "gameKey" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "emoji" TEXT NOT NULL,
    "category" TEXT NOT NULL DEFAULT '10 Levels',
    "color" TEXT NOT NULL DEFAULT '#38bdf8',
    "gradientColors" TEXT[] DEFAULT ARRAY['#6C63FF', '#9B59B6']::TEXT[],
    "totalLevels" INTEGER NOT NULL DEFAULT 10,
    "order" INTEGER NOT NULL DEFAULT 1,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Game_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GameProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "gameKey" TEXT NOT NULL,
    "levelNumber" INTEGER NOT NULL,
    "stars" INTEGER NOT NULL DEFAULT 0,
    "bestScore" INTEGER NOT NULL DEFAULT 0,
    "bestMoves" INTEGER,
    "bestTimeSeconds" DOUBLE PRECISION,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "isUnlocked" BOOLEAN NOT NULL DEFAULT false,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GameProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GameAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "gameKey" TEXT NOT NULL,
    "levelNumber" INTEGER NOT NULL,
    "stars" INTEGER NOT NULL,
    "score" INTEGER NOT NULL DEFAULT 0,
    "moves" INTEGER,
    "timeSeconds" DOUBLE PRECISION,
    "iqEarned" INTEGER NOT NULL DEFAULT 0,
    "coinsEarned" INTEGER NOT NULL DEFAULT 0,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GameAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MathPuzzleLevel" (
    "id" TEXT NOT NULL,
    "levelNumber" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "puzzles" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MathPuzzleLevel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WordScrambleLevel" (
    "id" TEXT NOT NULL,
    "levelNumber" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "puzzles" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "WordScrambleLevel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MemoryMatchLevel" (
    "id" TEXT NOT NULL,
    "levelNumber" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "config" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MemoryMatchLevel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShopItem" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "imageAsset" TEXT NOT NULL,
    "coinCost" INTEGER NOT NULL,
    "category" TEXT NOT NULL,
    "emoji" TEXT NOT NULL DEFAULT '⭐',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ShopItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdaptiveProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "consecutiveFastCorrect" INTEGER NOT NULL DEFAULT 0,
    "consecutiveIncorrect" INTEGER NOT NULL DEFAULT 0,
    "currentAdaptiveDifficulty" TEXT NOT NULL DEFAULT 'beginner',
    "mistakeHistory" JSONB NOT NULL DEFAULT '[]',
    "strongTopics" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "weakTopics" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "totalQuestionsAnswered" INTEGER NOT NULL DEFAULT 0,
    "totalCorrectAnswered" INTEGER NOT NULL DEFAULT 0,
    "avgResponseTimeSeconds" DOUBLE PRECISION NOT NULL DEFAULT 8.0,
    "lastMascotSuggestion" JSONB NOT NULL DEFAULT '{"title":"Let''s learn something new!","message":"Keep up your great streak today! You are mastering your lessons.","suggestedSubject":"Math","suggestedUnit":1}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AdaptiveProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DailyChallenge" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "dateKey" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "taskTitle" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL DEFAULT 'quiz',
    "subject" TEXT NOT NULL DEFAULT 'General',
    "targetCount" INTEGER NOT NULL DEFAULT 3,
    "currentCount" INTEGER NOT NULL DEFAULT 0,
    "weight" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "iqReward" INTEGER NOT NULL DEFAULT 20,
    "coinReward" INTEGER NOT NULL DEFAULT 10,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "isClaimed" BOOLEAN NOT NULL DEFAULT false,
    "mascotEmoji" TEXT NOT NULL DEFAULT '🐘',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyChallenge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Friendship" (
    "id" TEXT NOT NULL,
    "requesterId" TEXT NOT NULL,
    "recipientId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Friendship_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialPost" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "userName" TEXT NOT NULL,
    "avatarUrl" TEXT NOT NULL DEFAULT 'assets/images/kido_character.png',
    "gradeClass" TEXT NOT NULL DEFAULT 'Class 3',
    "activityType" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "caption" TEXT NOT NULL DEFAULT '',
    "badgeEmoji" TEXT NOT NULL DEFAULT '🏆',
    "likes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialPost_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CoopQuest" (
    "id" TEXT NOT NULL,
    "gradeClass" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "subject" TEXT NOT NULL DEFAULT 'Math',
    "targetCount" INTEGER NOT NULL DEFAULT 500,
    "currentCount" INTEGER NOT NULL DEFAULT 0,
    "rewardBadge" TEXT NOT NULL DEFAULT '🌟 Math Legend',
    "rewardCoins" INTEGER NOT NULL DEFAULT 100,
    "rewardIq" INTEGER NOT NULL DEFAULT 200,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "contributors" JSONB NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CoopQuest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contest" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "monthYear" TEXT NOT NULL,
    "gradeClass" TEXT NOT NULL,
    "entryCoinCost" INTEGER NOT NULL DEFAULT 20,
    "registrationOpen" BOOLEAN NOT NULL DEFAULT true,
    "stages" JSONB NOT NULL DEFAULT '[]',
    "participants" JSONB NOT NULL DEFAULT '[]',
    "prizePool" JSONB NOT NULL DEFAULT '{"first":{"iq":500,"coins":250,"badge":"🥇 Arena Champion"},"second":{"iq":300,"coins":150,"badge":"🥈 Arena Master"},"third":{"iq":200,"coins":100,"badge":"🥉 Arena Elite"}}',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Contest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "adminId" TEXT NOT NULL,
    "adminEmail" TEXT NOT NULL,
    "adminRole" TEXT NOT NULL DEFAULT 'admin',
    "action" TEXT NOT NULL,
    "resource" TEXT NOT NULL,
    "resourceId" TEXT,
    "details" JSONB NOT NULL DEFAULT '{}',
    "ipAddress" TEXT NOT NULL DEFAULT '127.0.0.1',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SystemConfig" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL DEFAULT 'global_settings',
    "doubleXpEnabled" BOOLEAN NOT NULL DEFAULT false,
    "baseXpMultiplier" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "bossBattleXpMultiplier" DOUBLE PRECISION NOT NULL DEFAULT 1.5,
    "doubleXpTitle" TEXT NOT NULL DEFAULT 'Double XP Weekend',
    "streakReminderEnabled" BOOLEAN NOT NULL DEFAULT true,
    "streakReminderHour" INTEGER NOT NULL DEFAULT 20,
    "inactivityThresholdDays" INTEGER NOT NULL DEFAULT 3,
    "updatedBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SystemConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BroadcastMessage" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'info',
    "targetClass" TEXT NOT NULL DEFAULT 'All',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "createdBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BroadcastMessage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");

-- CreateIndex
CREATE INDEX "QuizQuestion_subject_unitNumber_quizName_idx" ON "QuizQuestion"("subject", "unitNumber", "quizName");

-- CreateIndex
CREATE INDEX "QuizQuestion_gradeClass_idx" ON "QuizQuestion"("gradeClass");

-- CreateIndex
CREATE UNIQUE INDEX "LevelProgress_userId_levelId_key" ON "LevelProgress"("userId", "levelId");

-- CreateIndex
CREATE INDEX "QuizAttempt_userId_idx" ON "QuizAttempt"("userId");

-- CreateIndex
CREATE INDEX "QuizAttempt_subject_idx" ON "QuizAttempt"("subject");

-- CreateIndex
CREATE UNIQUE INDEX "Game_gameKey_key" ON "Game"("gameKey");

-- CreateIndex
CREATE INDEX "GameProgress_userId_gameKey_idx" ON "GameProgress"("userId", "gameKey");

-- CreateIndex
CREATE UNIQUE INDEX "GameProgress_userId_gameKey_levelNumber_key" ON "GameProgress"("userId", "gameKey", "levelNumber");

-- CreateIndex
CREATE INDEX "GameAttempt_userId_idx" ON "GameAttempt"("userId");

-- CreateIndex
CREATE INDEX "GameAttempt_userId_createdAt_idx" ON "GameAttempt"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "MathPuzzleLevel_levelNumber_key" ON "MathPuzzleLevel"("levelNumber");

-- CreateIndex
CREATE UNIQUE INDEX "WordScrambleLevel_levelNumber_key" ON "WordScrambleLevel"("levelNumber");

-- CreateIndex
CREATE UNIQUE INDEX "MemoryMatchLevel_levelNumber_key" ON "MemoryMatchLevel"("levelNumber");

-- CreateIndex
CREATE INDEX "ShopItem_category_idx" ON "ShopItem"("category");

-- CreateIndex
CREATE UNIQUE INDEX "AdaptiveProfile_userId_key" ON "AdaptiveProfile"("userId");

-- CreateIndex
CREATE INDEX "AdaptiveProfile_userId_idx" ON "AdaptiveProfile"("userId");

-- CreateIndex
CREATE INDEX "DailyChallenge_userId_dateKey_idx" ON "DailyChallenge"("userId", "dateKey");

-- CreateIndex
CREATE INDEX "Friendship_requesterId_idx" ON "Friendship"("requesterId");

-- CreateIndex
CREATE INDEX "Friendship_recipientId_idx" ON "Friendship"("recipientId");

-- CreateIndex
CREATE INDEX "Friendship_status_idx" ON "Friendship"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Friendship_requesterId_recipientId_key" ON "Friendship"("requesterId", "recipientId");

-- CreateIndex
CREATE INDEX "SocialPost_userId_idx" ON "SocialPost"("userId");

-- CreateIndex
CREATE INDEX "SocialPost_createdAt_idx" ON "SocialPost"("createdAt");

-- CreateIndex
CREATE INDEX "CoopQuest_gradeClass_idx" ON "CoopQuest"("gradeClass");

-- CreateIndex
CREATE INDEX "Contest_gradeClass_idx" ON "Contest"("gradeClass");

-- CreateIndex
CREATE INDEX "AuditLog_action_idx" ON "AuditLog"("action");

-- CreateIndex
CREATE INDEX "AuditLog_resource_idx" ON "AuditLog"("resource");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SystemConfig_key_key" ON "SystemConfig"("key");

-- CreateIndex
CREATE INDEX "BroadcastMessage_active_createdAt_idx" ON "BroadcastMessage"("active", "createdAt");
