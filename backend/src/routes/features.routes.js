const express = require('express');
const { protect } = require('../middleware/auth.middleware');
const {
  getAdaptiveSuggestion,
  recordAnswer,
  getDailyChallenges,
  claimChallenge,
  submitBossFight,
  getCoopQuest,
  getFriends,
  sendFriendRequest,
  respondFriendRequest,
  getFriendlyLeaderboard,
  getFeed,
  likePost,
  unlockFeedSubscription,
  getContests,
  joinContest,
  getParentMetrics,
  claimDoubleAdReward,
  buyStreakFreeze,
} = require('../controllers/features.controller');

const router = express.Router();
router.use(protect);

// 1. Adaptive Engine
router.get('/adaptive/suggestion', getAdaptiveSuggestion);
router.post('/adaptive/record-answer', recordAnswer);

// 2. Daily Challenges
router.get('/challenges/daily', getDailyChallenges);
router.post('/challenges/claim', claimChallenge);

// 3. Boss Fights
router.post('/boss-fight/submit', submitBossFight);

// 4. Co-op Quests
router.get('/coop-quest', getCoopQuest);

// 5. Friends & Friendly Leaderboard
router.get('/friends', getFriends);
router.post('/friends/request', sendFriendRequest);
router.post('/friends/respond', respondFriendRequest);
router.get('/friends/leaderboard', getFriendlyLeaderboard);

// 6. Social Feed
router.get('/social/feed', getFeed);
router.post('/social/like', likePost);
router.post('/social/unlock-feed', unlockFeedSubscription);

// 7. Contests
router.get('/contests', getContests);
router.post('/contests/join', joinContest);

// 8. Parent Spectator Mode
router.get('/parent/metrics', getParentMetrics);

// 9. Monetization / Virtual Economy
router.post('/rewards/double-ad', claimDoubleAdReward);
router.post('/rewards/streak-freeze', buyStreakFreeze);

module.exports = router;
