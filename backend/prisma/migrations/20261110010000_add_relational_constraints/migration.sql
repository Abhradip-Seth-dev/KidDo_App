-- Add foreign keys after the initial table baseline. Keeping this separate
-- allows an existing database created with `prisma db push` to baseline the
-- table migration, then apply these constraints without recreating tables.
ALTER TABLE "LevelProgress"
  ADD CONSTRAINT "LevelProgress_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "QuizAttempt"
  ADD CONSTRAINT "QuizAttempt_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GameProgress"
  ADD CONSTRAINT "GameProgress_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GameProgress"
  ADD CONSTRAINT "GameProgress_gameKey_fkey"
  FOREIGN KEY ("gameKey") REFERENCES "Game"("gameKey") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GameAttempt"
  ADD CONSTRAINT "GameAttempt_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GameAttempt"
  ADD CONSTRAINT "GameAttempt_gameKey_fkey"
  FOREIGN KEY ("gameKey") REFERENCES "Game"("gameKey") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "AdaptiveProfile"
  ADD CONSTRAINT "AdaptiveProfile_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DailyChallenge"
  ADD CONSTRAINT "DailyChallenge_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Friendship"
  ADD CONSTRAINT "Friendship_requesterId_fkey"
  FOREIGN KEY ("requesterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Friendship"
  ADD CONSTRAINT "Friendship_recipientId_fkey"
  FOREIGN KEY ("recipientId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SocialPost"
  ADD CONSTRAINT "SocialPost_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
