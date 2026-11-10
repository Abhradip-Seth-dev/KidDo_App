const { prisma, formatDoc } = require('../prisma');

const STAR_REWARDS = {
  1: { iq: 10, coins: 5 },
  2: { iq: 20, coins: 10 },
  3: { iq: 30, coins: 15 },
};

// ── GET /api/games ─────────────────────────────────────────────────────────────
exports.getGames = async (req, res, next) => {
  try {
    const games = await prisma.game.findMany({
      where: { isActive: true },
      orderBy: { order: 'asc' },
    });
    const userId = req.user?.id || req.user?._id;

    const gamesWithProgress = await Promise.all(
      games.map(async (game) => {
        let earnedStars = 0;
        let unlockedLevels = 1;

        if (userId) {
          const progressList = await prisma.gameProgress.findMany({
            where: {
              userId,
              gameKey: game.gameKey,
            },
          });

          earnedStars = progressList.reduce((acc, p) => acc + (p.stars || 0), 0);
          const maxUnlocked = progressList
            .filter((p) => p.isUnlocked || p.stars > 0)
            .reduce((max, p) => Math.max(max, p.levelNumber), 1);
          unlockedLevels = Math.min(maxUnlocked + 1, game.totalLevels);
        }

        return {
          ...formatDoc(game),
          earnedStars,
          unlockedLevels,
        };
      })
    );

    res.status(200).json({
      success: true,
      count: gamesWithProgress.length,
      games: gamesWithProgress,
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/games/:gameKey/levels ────────────────────────────────────────────
exports.getGameLevels = async (req, res, next) => {
  try {
    const { gameKey } = req.params;
    const userId = req.user?.id || req.user?._id;

    let levels = [];
    if (gameKey === 'math_puzzle') {
      levels = await prisma.mathPuzzleLevel.findMany({
        select: { id: true, levelNumber: true, title: true, description: true, icon: true },
        orderBy: { levelNumber: 'asc' },
      });
    } else if (gameKey === 'word_scramble') {
      levels = await prisma.wordScrambleLevel.findMany({
        select: { id: true, levelNumber: true, title: true, description: true, icon: true },
        orderBy: { levelNumber: 'asc' },
      });
    } else if (gameKey === 'memory_match') {
      levels = await prisma.memoryMatchLevel.findMany({
        select: { id: true, levelNumber: true, title: true, description: true, icon: true },
        orderBy: { levelNumber: 'asc' },
      });
    } else {
      return res.status(404).json({ success: false, message: `Unknown gameKey: ${gameKey}` });
    }

    // Attach user progress
    let userProgressMap = {};
    if (userId) {
      const progressDocs = await prisma.gameProgress.findMany({
        where: { userId, gameKey },
      });
      progressDocs.forEach((p) => {
        userProgressMap[p.levelNumber] = p;
      });
    }

    let highestUnlocked = 1;
    for (let i = 1; i <= 50; i++) {
      if (userProgressMap[i] && userProgressMap[i].stars > 0) {
        highestUnlocked = i + 1;
      } else {
        break;
      }
    }

    const levelsWithProgress = levels.map((lvl) => {
      const p = userProgressMap[lvl.levelNumber];
      const isUnlocked = lvl.levelNumber <= highestUnlocked || p?.isUnlocked === true;
      return {
        ...formatDoc(lvl),
        stars: p?.stars || 0,
        bestScore: p?.bestScore || 0,
        isCompleted: (p?.stars || 0) > 0,
        isUnlocked,
      };
    });

    res.status(200).json({
      success: true,
      gameKey,
      levels: levelsWithProgress,
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/games/:gameKey/levels/:levelNumber ────────────────────────────────
exports.getLevelData = async (req, res, next) => {
  try {
    const { gameKey, levelNumber } = req.params;
    const levelNum = parseInt(levelNumber, 10);

    let levelData = null;
    if (gameKey === 'math_puzzle') {
      levelData = await prisma.mathPuzzleLevel.findUnique({ where: { levelNumber: levelNum } });
    } else if (gameKey === 'word_scramble') {
      levelData = await prisma.wordScrambleLevel.findUnique({ where: { levelNumber: levelNum } });
    } else if (gameKey === 'memory_match') {
      levelData = await prisma.memoryMatchLevel.findUnique({ where: { levelNumber: levelNum } });
    } else {
      return res.status(404).json({ success: false, message: `Unknown gameKey: ${gameKey}` });
    }

    if (!levelData) {
      return res.status(404).json({
        success: false,
        message: `Level ${levelNumber} for ${gameKey} not found in database`,
      });
    }

    res.status(200).json({
      success: true,
      gameKey,
      level: formatDoc(levelData),
    });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/games/submit ─────────────────────────────────────────────────────
exports.submitGameLevel = async (req, res, next) => {
  try {
    const { gameKey, levelNumber, stars, score = 0, moves = null, timeSeconds = null } = req.body;
    const userId = req.user.id || req.user._id;

    const levelNum = parseInt(levelNumber, 10);
    const starCount = Math.max(1, Math.min(3, parseInt(stars, 10) || 1));

    // Find previous progress
    let progress = await prisma.gameProgress.findUnique({
      where: {
        userId_gameKey_levelNumber: {
          userId,
          gameKey,
          levelNumber: levelNum,
        },
      },
    });
    const prevStars = progress?.stars || 0;

    let iqEarned = 0;
    let coinsEarned = 0;

    if (!progress || prevStars === 0) {
      const reward = STAR_REWARDS[starCount] || STAR_REWARDS[1];
      iqEarned = reward.iq;
      coinsEarned = reward.coins;
    } else if (starCount > prevStars) {
      const prevReward = STAR_REWARDS[prevStars] || { iq: 0, coins: 0 };
      const newReward = STAR_REWARDS[starCount];
      iqEarned = Math.max(0, newReward.iq - prevReward.iq);
      coinsEarned = Math.max(0, newReward.coins - prevReward.coins);
    } else {
      iqEarned = 2;
      coinsEarned = 1;
    }

    // Upsert level progress
    if (!progress) {
      await prisma.gameProgress.create({
        data: {
          userId,
          gameKey,
          levelNumber: levelNum,
          stars: starCount,
          bestScore: score,
          bestMoves: moves,
          bestTimeSeconds: timeSeconds ? parseFloat(timeSeconds) : null,
          isCompleted: true,
          isUnlocked: true,
          completedAt: new Date(),
        },
      });
    } else {
      const updateData = {
        isCompleted: true,
        completedAt: new Date(),
      };
      if (starCount > progress.stars) updateData.stars = starCount;
      if (score > progress.bestScore) updateData.bestScore = score;
      if (moves !== null && (progress.bestMoves === null || moves < progress.bestMoves)) {
        updateData.bestMoves = moves;
      }
      if (timeSeconds !== null && (progress.bestTimeSeconds === null || timeSeconds < progress.bestTimeSeconds)) {
        updateData.bestTimeSeconds = parseFloat(timeSeconds);
      }
      await prisma.gameProgress.update({
        where: { id: progress.id },
        data: updateData,
      });
    }

    // Unlock next level (levelNumber + 1)
    const nextLevelNum = levelNum + 1;
    const nextProgress = await prisma.gameProgress.findUnique({
      where: {
        userId_gameKey_levelNumber: {
          userId,
          gameKey,
          levelNumber: nextLevelNum,
        },
      },
    });

    if (!nextProgress) {
      await prisma.gameProgress.create({
        data: {
          userId,
          gameKey,
          levelNumber: nextLevelNum,
          isUnlocked: true,
          stars: 0,
        },
      });
    } else if (!nextProgress.isUnlocked) {
      await prisma.gameProgress.update({
        where: { id: nextProgress.id },
        data: { isUnlocked: true },
      });
    }

    // Log attempt history
    await prisma.gameAttempt.create({
      data: {
        userId,
        gameKey,
        levelNumber: levelNum,
        stars: starCount,
        score,
        moves,
        timeSeconds: timeSeconds ? parseFloat(timeSeconds) : null,
        iqEarned,
        coinsEarned,
      },
    });

    // Update user stats
    const user = await prisma.user.findUnique({ where: { id: userId } });
    let newStreak = user.streak;
    const now = new Date();
    if (user.lastActiveDate) {
      const lastActive = new Date(user.lastActiveDate);
      const diffHours = (now - lastActive) / (1000 * 60 * 60);
      if (diffHours >= 20 && diffHours < 48) {
        newStreak += 1;
      } else if (diffHours >= 48) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        iq: user.iq + iqEarned,
        coins: user.coins + coinsEarned,
        totalGamesPlayed: user.totalGamesPlayed + 1,
        streak: newStreak,
        longestStreak: Math.max(newStreak, user.longestStreak),
        lastActiveDate: now,
      },
    });

    res.status(200).json({
      success: true,
      gameKey,
      levelNumber: levelNum,
      stars: starCount,
      iqEarned,
      coinsEarned,
      nextLevelUnlocked: nextLevelNum,
      user: {
        iq: updatedUser.iq,
        coins: updatedUser.coins,
        streak: updatedUser.streak,
      },
    });
  } catch (err) {
    next(err);
  }
};
