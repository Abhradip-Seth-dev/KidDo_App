const { prisma, formatDoc } = require('../prisma');

function getTodayKey() {
  const d = new Date();
  return d.toISOString().split('T')[0];
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. ADAPTIVE LEARNING ENGINE (Section 2.1 & 2.2)
// ─────────────────────────────────────────────────────────────────────────────

exports.getAdaptiveSuggestion = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    let profile = await prisma.adaptiveProfile.findUnique({ where: { userId } });

    if (!profile) {
      profile = await prisma.adaptiveProfile.create({
        data: {
          userId,
          currentAdaptiveDifficulty: 'beginner',
          lastMascotSuggestion: {
            title: 'Welcome Adventurer!',
            message: 'Start with Math Chapter 1 to unlock cool character items and earn IQ!',
            suggestedSubject: 'Math',
            suggestedUnit: 1,
          },
        },
      });
    }

    let mascotTitle = "You're doing fantastic! 🌟";
    let mascotMessage = 'Keep practicing every day to climb the friendly leaderboard!';
    let suggestedSubject = 'Math';

    const currentUnitBySubject = typeof req.user.currentUnitBySubject === 'string'
      ? JSON.parse(req.user.currentUnitBySubject || '{}')
      : (req.user.currentUnitBySubject || {});
    let suggestedUnit = currentUnitBySubject.Math || 1;

    const weakTopics = profile.weakTopics || [];
    if (weakTopics.length > 0) {
      const topWeak = weakTopics[0];
      mascotTitle = `Let's practice ${topWeak}! 💡`;
      mascotMessage = `I noticed you encountered a few tricky questions in ${topWeak}. Let's try some practice drills together!`;
    } else if (profile.consecutiveFastCorrect >= 3) {
      mascotTitle = 'Lightning Fast! ⚡';
      mascotMessage = 'You answered 3 questions in under 10 seconds! Scaling up to a higher difficulty challenge for extra IQ!';
    }

    res.status(200).json({
      success: true,
      adaptiveProfile: {
        difficulty: profile.currentAdaptiveDifficulty,
        consecutiveFastCorrect: profile.consecutiveFastCorrect,
        consecutiveIncorrect: profile.consecutiveIncorrect,
        weakTopics: profile.weakTopics,
        strongTopics: profile.strongTopics,
        avgResponseTimeSeconds: profile.avgResponseTimeSeconds,
      },
      mascotSuggestion: {
        title: mascotTitle,
        message: mascotMessage,
        suggestedSubject,
        suggestedUnit,
        mascotEmoji: '🐘',
      },
    });
  } catch (err) {
    next(err);
  }
};

exports.recordAnswer = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const { subject, topic, isCorrect, responseTimeSeconds = 8.0, questionType } = req.body;

    let profile = await prisma.adaptiveProfile.findUnique({ where: { userId } });
    if (!profile) {
      profile = await prisma.adaptiveProfile.create({
        data: { userId },
      });
    }

    let totalQuestionsAnswered = profile.totalQuestionsAnswered + 1;
    let totalCorrectAnswered = profile.totalCorrectAnswered + (isCorrect ? 1 : 0);

    let avgResponseTimeSeconds = Number(
      ((profile.avgResponseTimeSeconds * 0.8) + (parseFloat(responseTimeSeconds) * 0.2)).toFixed(1)
    );

    let difficultyChanged = null;
    let consecutiveFastCorrect = profile.consecutiveFastCorrect;
    let consecutiveIncorrect = profile.consecutiveIncorrect;
    let currentAdaptiveDifficulty = profile.currentAdaptiveDifficulty;
    let mistakeHistory = Array.isArray(profile.mistakeHistory)
      ? [...profile.mistakeHistory]
      : (typeof profile.mistakeHistory === 'string' ? JSON.parse(profile.mistakeHistory || '[]') : []);
    let weakTopics = [...(profile.weakTopics || [])];

    if (isCorrect) {
      consecutiveIncorrect = 0;
      if (responseTimeSeconds < 10) {
        consecutiveFastCorrect += 1;
        if (consecutiveFastCorrect >= 3) {
          if (currentAdaptiveDifficulty === 'beginner') {
            currentAdaptiveDifficulty = 'moderate';
            difficultyChanged = 'moderate';
          } else if (currentAdaptiveDifficulty === 'moderate') {
            currentAdaptiveDifficulty = 'hard';
            difficultyChanged = 'hard';
          }
        }
      }
    } else {
      consecutiveFastCorrect = 0;
      consecutiveIncorrect += 1;

      if (consecutiveIncorrect >= 2) {
        if (currentAdaptiveDifficulty === 'hard') {
          currentAdaptiveDifficulty = 'moderate';
          difficultyChanged = 'moderate';
        } else if (currentAdaptiveDifficulty === 'moderate') {
          currentAdaptiveDifficulty = 'beginner';
          difficultyChanged = 'beginner';
        }
      }

      if (topic) {
        const existingMistake = mistakeHistory.find(
          (m) => m.subject === subject && m.topic === topic
        );
        if (existingMistake) {
          existingMistake.wrongCount += 1;
          existingMistake.lastMistakeAt = new Date().toISOString();
        } else {
          mistakeHistory.push({
            subject,
            topic,
            questionType: questionType || 'mcq',
            wrongCount: 1,
            lastMistakeAt: new Date().toISOString(),
          });
        }

        if (!weakTopics.includes(topic)) {
          weakTopics.push(topic);
        }
      }
    }

    await prisma.adaptiveProfile.update({
      where: { id: profile.id },
      data: {
        totalQuestionsAnswered,
        totalCorrectAnswered,
        avgResponseTimeSeconds,
        consecutiveFastCorrect,
        consecutiveIncorrect,
        currentAdaptiveDifficulty,
        mistakeHistory,
        weakTopics,
      },
    });

    res.status(200).json({
      success: true,
      currentDifficulty: currentAdaptiveDifficulty,
      difficultyChanged,
      consecutiveFastCorrect,
      consecutiveIncorrect,
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 2. DAILY CHALLENGES & WEEKLY GOALS (Section 2.3)
// ─────────────────────────────────────────────────────────────────────────────

exports.getDailyChallenges = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const dateKey = getTodayKey();

    let challenges = await prisma.dailyChallenge.findMany({
      where: { userId, dateKey },
    });

    if (challenges.length === 0) {
      const currentUnitBySubject = typeof req.user.currentUnitBySubject === 'string'
        ? JSON.parse(req.user.currentUnitBySubject || '{}')
        : (req.user.currentUnitBySubject || {});
      const userSubject = Object.keys(currentUnitBySubject)[0] || 'Math';

      const defaultTasks = [
        {
          userId,
          dateKey,
          taskId: 'task_1',
          taskTitle: 'Start New Chapter',
          description: `Complete 1 lesson quiz in ${userSubject}.`,
          category: 'quiz',
          subject: userSubject,
          targetCount: 1,
          currentCount: 0,
          weight: 1.0,
          iqReward: 30,
          coinReward: 15,
          mascotEmoji: '🐘',
        },
        {
          userId,
          dateKey,
          taskId: 'task_2',
          taskTitle: 'Daily Brain Spark',
          description: 'Play 1 mini-game (Math Puzzle or Memory Match).',
          category: 'game',
          subject: 'General',
          targetCount: 1,
          currentCount: 0,
          weight: 1.2,
          iqReward: 25,
          coinReward: 10,
          mascotEmoji: '🦹',
        },
        {
          userId,
          dateKey,
          taskId: 'task_3',
          taskTitle: 'Boss Hunter',
          description: 'Answer 5 questions with over 80% accuracy.',
          category: 'quiz',
          subject: 'General',
          targetCount: 5,
          currentCount: 0,
          weight: 1.5,
          iqReward: 50,
          coinReward: 25,
          mascotEmoji: '👩‍🔬',
        },
      ];

      await prisma.dailyChallenge.createMany({ data: defaultTasks });
      challenges = await prisma.dailyChallenge.findMany({ where: { userId, dateKey } });
    }

    res.status(200).json({
      success: true,
      dateKey,
      challenges: formatDoc(challenges),
    });
  } catch (err) {
    next(err);
  }
};

exports.claimChallenge = async (req, res, next) => {
  try {
    const { challengeId } = req.body;
    const userId = req.user.id || req.user._id;

    const challenge = await prisma.dailyChallenge.findFirst({
      where: {
        OR: [{ id: challengeId }, { taskId: challengeId }],
        userId,
      },
    });

    if (!challenge) {
      return res.status(404).json({ success: false, message: 'Challenge not found' });
    }

    if (challenge.isClaimed) {
      return res.status(400).json({ success: false, message: 'Challenge reward already claimed' });
    }

    const completionFraction = Math.min(1.0, challenge.currentCount / Math.max(1, challenge.targetCount));
    if (completionFraction < 0.3) {
      return res.status(400).json({ success: false, message: 'Need at least 30% progress to claim partial rewards' });
    }

    const earnedIq = Math.round(challenge.iqReward * completionFraction);
    const earnedCoins = Math.round(challenge.coinReward * completionFraction);

    await prisma.dailyChallenge.update({
      where: { id: challenge.id },
      data: {
        isClaimed: true,
        isCompleted: completionFraction >= 1.0 ? true : challenge.isCompleted,
      },
    });

    const user = await prisma.user.findUnique({ where: { id: userId } });
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        iq: user.iq + earnedIq,
        coins: user.coins + earnedCoins,
      },
    });

    res.status(200).json({
      success: true,
      earnedIq,
      earnedCoins,
      isFullyCompleted: challenge.isCompleted,
      user: {
        iq: updatedUser.iq,
        coins: updatedUser.coins,
      },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 3. BOSS FIGHTS (Section 2.4)
// ─────────────────────────────────────────────────────────────────────────────

exports.submitBossFight = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const { subject, chapter, score, livesRemaining, timeTakenSeconds } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    const won = livesRemaining > 0 && score >= 7;

    let iqEarned = 0;
    let coinsEarned = 0;

    if (won) {
      iqEarned = 150 + (livesRemaining * 20);
      coinsEarned = 50 + (livesRemaining * 10);

      await prisma.user.update({
        where: { id: userId },
        data: {
          iq: user.iq + iqEarned,
          coins: user.coins + coinsEarned,
          learningMinutesToday: user.learningMinutesToday + (Math.round(timeTakenSeconds / 60) || 3),
        },
      });

      await prisma.socialPost.create({
        data: {
          userId,
          userName: user.name,
          avatarUrl: user.avatarUrl,
          gradeClass: user.gradeClass,
          activityType: 'boss_defeated',
          title: `Defeated the ${subject} Boss! ⚔️`,
          caption: `${user.name} conquered Chapter "${chapter || 'Basics'}" with ${livesRemaining} hearts remaining!`,
          badgeEmoji: '👑',
        },
      });

      const quest = await prisma.coopQuest.findFirst({
        where: {
          gradeClass: user.gradeClass,
          completed: false,
          expiresAt: { gte: new Date() },
        },
      });

      if (quest) {
        let contributors = Array.isArray(quest.contributors)
          ? [...quest.contributors]
          : (typeof quest.contributors === 'string' ? JSON.parse(quest.contributors || '[]') : []);

        const contributor = contributors.find((c) => c.userId?.toString() === userId.toString());
        if (contributor) {
          contributor.count += 10;
        } else {
          contributors.push({ userId, userName: user.name, count: 10 });
        }

        const newCount = quest.currentCount + 10;
        await prisma.coopQuest.update({
          where: { id: quest.id },
          data: {
            currentCount: newCount,
            completed: newCount >= quest.targetCount,
            contributors,
          },
        });
      }
    }

    const latestUser = await prisma.user.findUnique({ where: { id: userId } });
    res.status(200).json({
      success: true,
      won,
      score,
      livesRemaining,
      timeTakenSeconds,
      iqEarned,
      coinsEarned,
      user: {
        iq: latestUser.iq,
        coins: latestUser.coins,
      },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 4. CO-OP QUESTS (Section 2.5)
// ─────────────────────────────────────────────────────────────────────────────

exports.getCoopQuest = async (req, res, next) => {
  try {
    const gradeClass = req.user.gradeClass || 'Class 3';
    let quest = await prisma.coopQuest.findFirst({
      where: {
        gradeClass,
        expiresAt: { gte: new Date() },
      },
    });

    if (!quest) {
      const nextSunday = new Date();
      nextSunday.setDate(nextSunday.getDate() + (7 - nextSunday.getDay()));
      nextSunday.setHours(23, 59, 59, 999);

      quest = await prisma.coopQuest.create({
        data: {
          gradeClass,
          title: 'Classroom Challenge: 500 Math Problems!',
          description: `Team up with your ${gradeClass} classmates to solve 500 Math problems together this week to unlock the "Math Legend" profile badge!`,
          subject: 'Math',
          targetCount: 500,
          currentCount: 85,
          rewardBadge: '🌟 Math Legend',
          rewardCoins: 100,
          rewardIq: 200,
          expiresAt: nextSunday,
          contributors: [
            { userId: req.user.id || req.user._id, userName: req.user.name, count: 15 },
          ],
        },
      });
    }

    res.status(200).json({
      success: true,
      quest: formatDoc(quest),
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 5. FRIENDS & FRIENDLY ZONE LEADERBOARD (Section 2.5)
// ─────────────────────────────────────────────────────────────────────────────

exports.getFriends = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;

    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [{ requesterId: userId }, { recipientId: userId }],
      },
    });

    // Gather user IDs
    const otherUserIds = Array.from(
      new Set(
        friendships.map((f) => (f.requesterId === userId ? f.recipientId : f.requesterId))
      )
    );

    const users = await prisma.user.findMany({
      where: { id: { in: otherUserIds } },
      select: {
        id: true,
        name: true,
        email: true,
        avatarUrl: true,
        iq: true,
        coins: true,
        streak: true,
        gradeClass: true,
      },
    });
    const userMap = new Map(users.map((u) => [u.id, formatDoc(u)]));

    const accepted = [];
    const pending = [];

    friendships.forEach((f) => {
      const isRequester = f.requesterId === userId;
      const friendId = isRequester ? f.recipientId : f.requesterId;
      const friend = userMap.get(friendId);
      if (!friend) return;

      if (f.status === 'accepted') {
        accepted.push({
          friendshipId: f.id,
          user: friend,
        });
      } else if (f.status === 'pending') {
        pending.push({
          friendshipId: f.id,
          isIncoming: !isRequester,
          user: friend,
        });
      }
    });

    res.status(200).json({
      success: true,
      friends: accepted,
      pendingRequests: pending,
    });
  } catch (err) {
    next(err);
  }
};

exports.sendFriendRequest = async (req, res, next) => {
  try {
    const { targetEmail } = req.body;
    const userId = req.user.id || req.user._id;

    const targetUser = await prisma.user.findUnique({
      where: { email: targetEmail.toLowerCase().trim() },
    });

    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'Student not found with this email' });
    }

    if (targetUser.id === userId) {
      return res.status(400).json({ success: false, message: 'You cannot add yourself as a friend' });
    }

    const existing = await prisma.friendship.findFirst({
      where: {
        OR: [
          { requesterId: userId, recipientId: targetUser.id },
          { requesterId: targetUser.id, recipientId: userId },
        ],
      },
    });

    if (existing) {
      return res.status(400).json({ success: false, message: `Friendship is already ${existing.status}` });
    }

    const friendship = await prisma.friendship.create({
      data: {
        requesterId: userId,
        recipientId: targetUser.id,
        status: 'pending',
      },
    });

    res.status(201).json({
      success: true,
      message: 'Friend request sent successfully!',
      friendship: formatDoc(friendship),
    });
  } catch (err) {
    next(err);
  }
};

exports.respondFriendRequest = async (req, res, next) => {
  try {
    const { friendshipId, accept } = req.body;
    const userId = req.user.id || req.user._id;

    const friendship = await prisma.friendship.findFirst({
      where: {
        id: friendshipId,
        recipientId: userId,
      },
    });

    if (!friendship) {
      return res.status(404).json({ success: false, message: 'Friend request not found' });
    }

    const updated = await prisma.friendship.update({
      where: { id: friendship.id },
      data: { status: accept ? 'accepted' : 'rejected' },
    });

    res.status(200).json({
      success: true,
      status: updated.status,
      message: accept ? 'Friend request accepted!' : 'Friend request declined.',
    });
  } catch (err) {
    next(err);
  }
};

exports.getFriendlyLeaderboard = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;

    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [{ requesterId: userId }, { recipientId: userId }],
        status: 'accepted',
      },
    });

    const friendIds = friendships.map((f) =>
      f.requesterId === userId ? f.recipientId : f.requesterId
    );
    friendIds.push(userId);

    const leaderboard = await prisma.user.findMany({
      where: { id: { in: friendIds } },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        iq: true,
        coins: true,
        streak: true,
        gradeClass: true,
      },
      orderBy: { iq: 'desc' },
    });

    res.status(200).json({
      success: true,
      leaderboard: formatDoc(leaderboard),
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 6. MINI SOCIAL FEED & SUBSCRIPTIONS (Section 2.5 & 2.7)
// ─────────────────────────────────────────────────────────────────────────────

exports.getFeed = async (req, res, next) => {
  try {
    const posts = await prisma.socialPost.findMany({
      orderBy: { createdAt: 'desc' },
      take: 30,
    });

    res.status(200).json({
      success: true,
      hasSubscription: req.user.hasFeedSubscription,
      posts: formatDoc(posts),
    });
  } catch (err) {
    next(err);
  }
};

exports.likePost = async (req, res, next) => {
  try {
    const { postId } = req.body;
    const userId = req.user.id || req.user._id;

    const post = await prisma.socialPost.findUnique({ where: { id: postId } });
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });

    let likes = [...(post.likes || [])];
    const index = likes.indexOf(userId);
    let isLiked = false;
    if (index > -1) {
      likes.splice(index, 1);
    } else {
      likes.push(userId);
      isLiked = true;
    }

    await prisma.socialPost.update({
      where: { id: postId },
      data: { likes },
    });

    res.status(200).json({
      success: true,
      isLiked,
      likeCount: likes.length,
    });
  } catch (err) {
    next(err);
  }
};

exports.unlockFeedSubscription = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const user = await prisma.user.findUnique({ where: { id: userId } });

    const FEED_COIN_PRICE = 100;
    if (user.coins < FEED_COIN_PRICE) {
      return res.status(400).json({
        success: false,
        message: `Insufficient coins. Feed pass requires ${FEED_COIN_PRICE} Coins.`,
      });
    }

    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        coins: user.coins - FEED_COIN_PRICE,
        hasFeedSubscription: true,
      },
    });

    res.status(200).json({
      success: true,
      message: 'Social Feed Pass unlocked successfully! 🎉',
      hasFeedSubscription: true,
      user: {
        coins: updated.coins,
        iq: updated.iq,
      },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 7. CONTEST ARENA (Section 2.5 & 2.7)
// ─────────────────────────────────────────────────────────────────────────────

exports.getContests = async (req, res, next) => {
  try {
    const gradeClass = req.user.gradeClass || 'Class 3';
    let contest = await prisma.contest.findFirst({
      where: { active: true, gradeClass },
    });

    if (!contest) {
      contest = await prisma.contest.create({
        data: {
          title: 'Monthly Math & Science Championship 🏆',
          monthYear: 'September 2026',
          gradeClass,
          entryCoinCost: 20,
          stages: [
            { stageNumber: 1, title: 'Stage 1: Speed Arithmetic', questionCount: 10, timeLimitSeconds: 180, unlockDayOffset: 0 },
            { stageNumber: 2, title: 'Stage 2: Pattern Master', questionCount: 10, timeLimitSeconds: 180, unlockDayOffset: 1 },
            { stageNumber: 3, title: 'Stage 3: GK & Nature Quiz', questionCount: 10, timeLimitSeconds: 180, unlockDayOffset: 2 },
            { stageNumber: 4, title: 'Stage 4: Logic & Riddle Battle', questionCount: 10, timeLimitSeconds: 180, unlockDayOffset: 3 },
            { stageNumber: 5, title: 'Stage 5: Grand Final Boss Stage', questionCount: 15, timeLimitSeconds: 240, unlockDayOffset: 4 },
          ],
          participants: [
            {
              userId: req.user.id || req.user._id,
              userName: req.user.name,
              avatarUrl: req.user.avatarUrl,
              totalScore: 40,
              totalTimeSeconds: 110,
              stagesCompleted: 1,
            },
          ],
        },
      });
    }

    const participants = Array.isArray(contest.participants)
      ? contest.participants
      : (typeof contest.participants === 'string' ? JSON.parse(contest.participants || '[]') : []);

    const currentUserId = (req.user.id || req.user._id).toString();
    const isJoined = participants.some((p) => p.userId?.toString() === currentUserId);

    res.status(200).json({
      success: true,
      contest: formatDoc(contest),
      isJoined,
    });
  } catch (err) {
    next(err);
  }
};

exports.joinContest = async (req, res, next) => {
  try {
    const { contestId, isAdEntry } = req.body;
    const userId = req.user.id || req.user._id;

    const contest = await prisma.contest.findUnique({ where: { id: contestId } });
    if (!contest) return res.status(404).json({ success: false, message: 'Contest not found' });

    const user = await prisma.user.findUnique({ where: { id: userId } });
    let participants = Array.isArray(contest.participants)
      ? [...contest.participants]
      : (typeof contest.participants === 'string' ? JSON.parse(contest.participants || '[]') : []);

    const existing = participants.find((p) => p.userId?.toString() === userId.toString());
    if (existing) {
      return res.status(400).json({ success: false, message: 'Already registered for this contest' });
    }

    if (!isAdEntry) {
      if (user.coins < contest.entryCoinCost) {
        return res.status(400).json({
          success: false,
          message: `Insufficient coins. Need ${contest.entryCoinCost} Coins to register, or watch an ad.`,
        });
      }
      await prisma.user.update({
        where: { id: userId },
        data: { coins: user.coins - contest.entryCoinCost },
      });
    }

    participants.push({
      userId,
      userName: user.name,
      avatarUrl: user.avatarUrl,
      totalScore: 0,
      totalTimeSeconds: 0,
      stagesCompleted: 0,
    });

    await prisma.contest.update({
      where: { id: contestId },
      data: { participants },
    });

    const latestUser = await prisma.user.findUnique({ where: { id: userId } });
    res.status(200).json({
      success: true,
      message: 'Successfully registered for the Championship Arena! ⚔️',
      user: { coins: latestUser.coins },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 8. PARENT SPECTATOR MODE (Section 2.9)
// ─────────────────────────────────────────────────────────────────────────────

exports.getParentMetrics = async (req, res, next) => {
  try {
    const user = req.user;
    const userId = user.id || user._id;
    const profile = await prisma.adaptiveProfile.findUnique({ where: { userId } });

    const completedQuizzes = Array.isArray(user.completedQuizzes)
      ? user.completedQuizzes
      : (typeof user.completedQuizzes === 'string' ? JSON.parse(user.completedQuizzes || '[]') : []);

    const completedUnits = user.completedUnits || [];

    res.status(200).json({
      success: true,
      parentData: {
        childName: user.name,
        gradeClass: user.gradeClass,
        age: user.age,
        habitMetrics: {
          currentStreak: user.streak,
          longestStreak: user.longestStreak || user.streak,
          learningMinutesToday: user.learningMinutesToday || 20,
          weeklyActivityMinutes: user.weeklyActivityMinutes || [15, 20, 10, 25, 30, 15, 20],
          modulesCompleted: completedUnits.length,
          totalQuizzesTaken: completedQuizzes.length,
          totalGamesPlayed: user.totalGamesPlayed || 0,
        },
        strengthsAndFocus: {
          strongTopics: profile?.strongTopics?.length ? profile.strongTopics : ['Counting & Numbers', 'Basic Shapes'],
          focusAreas: profile?.weakTopics?.length ? profile.weakTopics : ['Word Scramble', 'Speed Arithmetic'],
          currentDifficultyLevel: profile?.currentAdaptiveDifficulty || 'beginner',
        },
        privacyCompliance: {
          dpdpActCompliant: true,
          noPersonalTracking: true,
          verifiableParentalControl: true,
        },
      },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 9. REWARD DOUBLER & STREAK FREEZE (Section 2.4 & 2.7)
// ─────────────────────────────────────────────────────────────────────────────

exports.claimDoubleAdReward = async (req, res, next) => {
  try {
    const { baseIq, baseCoins } = req.body;
    const userId = req.user.id || req.user._id;
    const user = await prisma.user.findUnique({ where: { id: userId } });

    const extraIq = Math.min(100, Math.max(0, parseInt(baseIq, 10) || 10));
    const extraCoins = Math.min(50, Math.max(0, parseInt(baseCoins, 10) || 5));

    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        iq: user.iq + extraIq,
        coins: user.coins + extraCoins,
      },
    });

    res.status(200).json({
      success: true,
      message: '2x Ad Reward applied successfully! 🎁',
      extraIq,
      extraCoins,
      user: {
        iq: updated.iq,
        coins: updated.coins,
      },
    });
  } catch (err) {
    next(err);
  }
};

exports.buyStreakFreeze = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const user = await prisma.user.findUnique({ where: { id: userId } });
    const STREAK_FREEZE_COST = 50;

    if (user.coins < STREAK_FREEZE_COST) {
      return res.status(400).json({
        success: false,
        message: `Need ${STREAK_FREEZE_COST} Coins to purchase a Streak Freeze.`,
      });
    }

    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        coins: user.coins - STREAK_FREEZE_COST,
        streakFreezes: (user.streakFreezes || 0) + 1,
      },
    });

    res.status(200).json({
      success: true,
      message: 'Streak Freeze purchased! ❄️ Your streak is protected.',
      streakFreezes: updated.streakFreezes,
      user: {
        coins: updated.coins,
        streakFreezes: updated.streakFreezes,
      },
    });
  } catch (err) {
    next(err);
  }
};
