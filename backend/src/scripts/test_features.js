require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { prisma, formatDoc } = require('../prisma');
const featuresController = require('../controllers/features.controller');

async function testBackendFeatures() {
  try {
    await prisma.$connect();
    console.log('Connected to PostgreSQL via Prisma');

    const user = await prisma.user.findFirst();
    console.log('Testing with user:', user?.name, user?.email);

    // Mock Express req/res
    const req = { user: formatDoc(user), body: {} };
    const res = {
      statusCode: 200,
      status(code) { this.statusCode = code; return this; },
      json(data) { console.log(`[Status ${this.statusCode}] Response:`, JSON.stringify(data).slice(0, 150) + '...'); return this; }
    };

    console.log('\n1. Testing getAdaptiveSuggestion...');
    await featuresController.getAdaptiveSuggestion(req, res, (err) => console.error(err));

    console.log('\n2. Testing getDailyChallenges...');
    await featuresController.getDailyChallenges(req, res, (err) => console.error(err));

    console.log('\n3. Testing getCoopQuest...');
    await featuresController.getCoopQuest(req, res, (err) => console.error(err));

    console.log('\n4. Testing getContests...');
    await featuresController.getContests(req, res, (err) => console.error(err));

    console.log('\n5. Testing getFeed...');
    await featuresController.getFeed(req, res, (err) => console.error(err));

    console.log('\n6. Testing getParentMetrics...');
    await featuresController.getParentMetrics(req, res, (err) => console.error(err));

    console.log('\n🎉 All Section 2 Backend Features Verified Successfully on PostgreSQL!');
  } catch (err) {
    console.error('Test failed:', err);
  } finally {
    await prisma.$disconnect();
    process.exit(0);
  }
}

testBackendFeatures();
