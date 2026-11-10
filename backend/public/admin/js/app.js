/**
 * app.js — Main Application Controller for KidDO Admin Panel
 */

// ── GLOBAL STATE ─────────────────────────────────────────────────────────────
let currentUser = null;
let currentTab = 'overview';
let subjectChartInstance = null;

// Pagination state
const pagination = {
  questions: { page: 1, limit: 15, total: 0 },
  students: { page: 1, limit: 15, total: 0 },
  audit: { page: 1, limit: 25, total: 0 },
};

// ── DOM ELEMENTS ─────────────────────────────────────────────────────────────
const authOverlay = document.getElementById('authOverlay');
const adminApp = document.getElementById('adminApp');
const loginForm = document.getElementById('loginForm');
const loginError = document.getElementById('loginError');
const logoutBtn = document.getElementById('logoutBtn');
const refreshDataBtn = document.getElementById('refreshDataBtn');

// ── TOAST NOTIFICATIONS ──────────────────────────────────────────────────────
function showToast(message, type = 'success') {
  const container = document.getElementById('toastContainer');
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `<span>${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}</span><span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.remove();
  }, 4000);
}

// ── MODAL HELPERS ────────────────────────────────────────────────────────────
function openModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.remove('hidden');
}

function closeModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.add('hidden');
}

// ── INITIALIZATION & AUTH ────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  setupEventListeners();
  const token = api.getToken();
  const savedUser = api.getUser();

  if (token && savedUser) {
    currentUser = savedUser;
    initAdminSession();
  } else {
    showAuthOverlay();
  }
});

function showAuthOverlay() {
  authOverlay.classList.remove('hidden');
  adminApp.classList.add('hidden');
}

function initAdminSession() {
  authOverlay.classList.add('hidden');
  adminApp.classList.remove('hidden');

  // Set current user details in sidebar
  document.getElementById('currentAdminName').innerText = currentUser.name || 'Admin User';
  document.getElementById('currentAdminEmail').innerText = currentUser.email || 'admin@kiddo.app';
  document.getElementById('currentAdminInitial').innerText = (currentUser.name || 'A')[0].toUpperCase();
  document.getElementById('currentUserRoleBadge').innerText = (currentUser.role || 'admin').toUpperCase();

  // Load initial tab data
  switchTab(currentTab);
}

// ── EVENT LISTENERS ──────────────────────────────────────────────────────────
function setupEventListeners() {
  // Login Form
  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value.trim();
    const password = document.getElementById('loginPassword').value.trim();
    loginError.classList.add('hidden');

    try {
      const data = await api.login(email, password);
      if (data.user.role !== 'admin' && data.user.role !== 'content_creator') {
        throw new Error('Access denied: You need Administrator or Content Creator permissions.');
      }
      api.setToken(data.token);
      api.setUser(data.user);
      currentUser = data.user;
      initAdminSession();
      showToast(`Welcome back, ${currentUser.name}!`);
    } catch (err) {
      loginError.innerText = err.message || 'Login failed. Check credentials.';
      loginError.classList.remove('hidden');
    }
  });

  // Logout
  logoutBtn.addEventListener('click', () => {
    api.clearToken();
    currentUser = null;
    showAuthOverlay();
    showToast('Signed out successfully.');
  });

  // Refresh
  refreshDataBtn.addEventListener('click', () => {
    loadTabData(currentTab);
    showToast('Refreshed data.');
  });

  // Sidebar Tabs
  document.querySelectorAll('.nav-item').forEach((btn) => {
    btn.addEventListener('click', () => {
      const tab = btn.getAttribute('data-tab');
      switchTab(tab);
    });
  });

  // 1.1 Question Bank Filters & Modals
  document.getElementById('openAddQuestionModalBtn').addEventListener('click', () => {
    document.getElementById('questionForm').reset();
    document.getElementById('editQuestionId').value = '';
    document.getElementById('questionModalTitle').innerText = 'Upload New Question';
    openModal('questionModal');
  });

  document.getElementById('questionSearchInput').addEventListener('input', debounce(() => loadQuestions(), 300));
  document.getElementById('questionSubjectFilter').addEventListener('change', () => loadQuestions(1));
  document.getElementById('questionClassFilter').addEventListener('change', () => loadQuestions(1));
  document.getElementById('questionDifficultyFilter').addEventListener('change', () => loadQuestions(1));

  document.getElementById('questionForm').addEventListener('submit', handleSaveQuestion);

  // 1.2 Student Filters
  document.getElementById('studentSearchInput').addEventListener('input', debounce(() => loadStudents(), 300));
  document.getElementById('studentClassFilter').addEventListener('change', () => loadStudents(1));
  document.getElementById('studentStatusFilter').addEventListener('change', () => loadStudents(1));

  // 1.3 Engagement Form & Broadcasts
  document.getElementById('multiplierForm').addEventListener('submit', handleSaveMultiplierConfig);
  document.getElementById('openNewBroadcastBtn').addEventListener('click', () => {
    document.getElementById('broadcastForm').reset();
    openModal('broadcastModal');
  });
  document.getElementById('broadcastForm').addEventListener('submit', handleSaveBroadcast);

  // 1.4 Store Manager
  document.getElementById('openAddStoreItemBtn').addEventListener('click', () => {
    document.getElementById('storeItemForm').reset();
    document.getElementById('editStoreId').value = '';
    document.getElementById('storeItemId').disabled = false;
    document.getElementById('storeModalTitle').innerText = 'Add Store Asset';
    openModal('storeItemModal');
  });
  document.getElementById('storeItemForm').addEventListener('submit', handleSaveStoreItem);

  // 1.5 Audit Search & Filter
  document.getElementById('auditSearchInput').addEventListener('input', debounce(() => loadAuditLogs(), 300));
  document.getElementById('auditActionFilter').addEventListener('change', () => loadAuditLogs(1));
}

function switchTab(tabId) {
  currentTab = tabId;
  document.querySelectorAll('.nav-item').forEach((btn) => {
    btn.classList.toggle('active', btn.getAttribute('data-tab') === tabId);
  });
  document.querySelectorAll('.tab-pane').forEach((pane) => {
    pane.classList.remove('active');
  });

  const targetPane = document.getElementById(`tab-${tabId}`);
  if (targetPane) targetPane.classList.add('active');

  const titles = {
    overview: ['Dashboard Overview', 'Real-time telemetry, gamification stats, and system metrics'],
    questions: ['Question Bank & Content Management (1.1)', 'Create, edit, and organize curriculum questions across Class 1–10'],
    students: ['Students & Account Management (1.2)', 'Search students, inspect telemetry, ban toxic users, and adjust balances'],
    engagement: ['Engagement & Communication Tools (1.3)', 'Toggle Double XP Weekends, configure triggers, and publish broadcasts'],
    store: ['Store & Economy Manager (1.4)', 'Add and manage avatar items, UI themes, and powerups in real-time'],
    audit: ['Security & Audit Logs (1.5)', 'Immutable audit trail of all administrative actions and security events'],
  };

  if (titles[tabId]) {
    document.getElementById('pageTitle').innerText = titles[tabId][0];
    document.getElementById('pageSubtitle').innerText = titles[tabId][1];
  }

  loadTabData(tabId);
}

function loadTabData(tabId) {
  switch (tabId) {
    case 'overview':
      loadOverview();
      break;
    case 'questions':
      loadQuestions();
      break;
    case 'students':
      loadStudents();
      break;
    case 'engagement':
      loadEngagement();
      break;
    case 'store':
      loadStoreItems();
      break;
    case 'audit':
      loadAuditLogs();
      break;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: OVERVIEW CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────
async function loadOverview() {
  try {
    const data = await api.getStats();
    const stats = data.stats;

    // Update KPI tiles
    document.getElementById('statTotalStudents').innerText = Number(stats.totalStudents).toLocaleString();
    document.getElementById('statTotalQuestions').innerText = Number(stats.totalQuestions).toLocaleString();
    document.getElementById('statTotalCoins').innerText = Number(stats.totalCoinsCirculating).toLocaleString();
    document.getElementById('statTotalIq').innerText = Number(stats.totalIqEarned).toLocaleString();

    // Update Double XP Status Pill in Header
    const doubleXpBadge = document.getElementById('liveDoubleXpBadge');
    const doubleXpText = document.getElementById('doubleXpText');
    if (stats.doubleXpEnabled) {
      doubleXpBadge.className = 'status-pill status-on';
      doubleXpText.innerText = '⚡ Double XP: ACTIVE';
    } else {
      doubleXpBadge.className = 'status-pill status-off';
      doubleXpText.innerText = 'Double XP: Inactive';
    }

    document.getElementById('summaryXpMultiplier').innerText = `${stats.baseXpMultiplier}x Base Multiplier`;
    document.getElementById('summaryDoubleXpStatus').innerText = stats.doubleXpEnabled ? '⚡ 2.0x Active' : 'Normal';
    document.getElementById('summaryBroadcasts').innerText = `${stats.activeBroadcasts} active in-app announcement(s)`;

    // Render Recent Users
    const recentBody = document.getElementById('recentUsersTableBody');
    if (stats.recentUsers && stats.recentUsers.length > 0) {
      recentBody.innerHTML = stats.recentUsers.map((u) => `
        <tr>
          <td>
            <strong>${escapeHtml(u.name)}</strong><br>
            <small class="text-muted">${escapeHtml(u.email)}</small>
          </td>
          <td><span class="badge badge-info">${escapeHtml(u.gradeClass || 'Class 3')}</span></td>
          <td><strong>${u.iq} IQ</strong></td>
          <td><span class="text-amber">🪙 ${u.coins}</span></td>
          <td>🔥 ${u.streak}d</td>
          <td>
            ${u.isBanned ? '<span class="badge badge-danger">Banned</span>' : '<span class="badge badge-success">Active</span>'}
          </td>
          <td><small class="text-muted">${formatDate(u.createdAt)}</small></td>
        </tr>
      `).join('');
    } else {
      recentBody.innerHTML = '<tr><td colspan="7" class="text-center py-4">No recent users found.</td></tr>';
    }

    // Render Subject Chart
    renderSubjectChart(stats.subjectBreakdown || []);
  } catch (err) {
    showToast(`Failed to load overview: ${err.message}`, 'error');
  }
}

function renderSubjectChart(breakdown) {
  const ctx = document.getElementById('subjectChart');
  if (!ctx) return;

  const labels = breakdown.map((b) => b._id || 'General');
  const counts = breakdown.map((b) => b.count);

  if (subjectChartInstance) {
    subjectChartInstance.destroy();
  }

  subjectChartInstance = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels.length > 0 ? labels : ['Math', 'GK', 'English', 'Computer', 'Science'],
      datasets: [
        {
          data: counts.length > 0 ? counts : [10, 8, 4, 3, 2],
          backgroundColor: ['#0284C7', '#10B981', '#F59E0B', '#7C3AED', '#EC4899'],
          borderWidth: 0,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right' },
      },
    },
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: QUESTIONS CONTROLLER (Section 1.1)
// ─────────────────────────────────────────────────────────────────────────────
async function loadQuestions(page = pagination.questions.page) {
  pagination.questions.page = page;
  const tbody = document.getElementById('questionsTableBody');
  tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">Loading questions...</td></tr>';

  try {
    const params = {
      page,
      limit: pagination.questions.limit,
      search: document.getElementById('questionSearchInput').value.trim(),
      subject: document.getElementById('questionSubjectFilter').value,
      gradeClass: document.getElementById('questionClassFilter').value,
      difficulty: document.getElementById('questionDifficultyFilter').value,
    };

    const data = await api.getQuestions(params);
    const questions = data.questions || [];
    pagination.questions.total = data.pagination.total;

    if (questions.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">No questions found matching criteria.</td></tr>';
      renderPagination('questionsPagination', data.pagination, loadQuestions);
      return;
    }

    tbody.innerHTML = questions.map((q) => `
      <tr>
        <td>
          <span class="badge badge-purple">${escapeHtml(q.subject)}</span><br>
          <small class="badge badge-info mt-1">${escapeHtml(q.gradeClass || 'Class 3')}</small>
        </td>
        <td>
          <strong>Unit ${q.unitNumber}: ${escapeHtml(q.unitName)}</strong><br>
          <small class="text-muted">${escapeHtml(q.quizName)}</small>
        </td>
        <td style="max-width: 260px;">
          <strong>${escapeHtml(q.question)}</strong>
          ${q.explanation ? `<br><small class="text-muted">💡 ${escapeHtml(q.explanation)}</small>` : ''}
        </td>
        <td>
          <small>${(q.options || []).map((opt, i) => `<span class="badge ${opt === q.correctAnswer ? 'badge-success' : 'badge-info'} mr-1">${i + 1}. ${escapeHtml(opt)}</span>`).join(' ')}</small>
        </td>
        <td>
          <span class="badge badge-success">✓ ${escapeHtml(q.correctAnswer)}</span>
        </td>
        <td>
          <span class="badge ${q.difficulty === 'hard' ? 'badge-danger' : q.difficulty === 'medium' ? 'badge-warning' : 'badge-cyan'}">${escapeHtml(q.difficulty)}</span>
        </td>
        <td>
          <div class="action-btn-group">
            <button class="btn btn-secondary btn-sm" onclick='editQuestion(${JSON.stringify(q).replace(/'/g, "&apos;")})'>✏️</button>
            <button class="btn btn-outline-danger btn-sm" onclick="deleteQuestion('${q._id}')">🗑️</button>
          </div>
        </td>
      </tr>
    `).join('');

    renderPagination('questionsPagination', data.pagination, loadQuestions);
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center py-4 text-danger">Error: ${err.message}</td></tr>`;
  }
}

async function handleSaveQuestion(e) {
  e.preventDefault();
  const id = document.getElementById('editQuestionId').value;
  const payload = {
    subject: document.getElementById('qSubject').value,
    gradeClass: document.getElementById('qGradeClass').value,
    difficulty: document.getElementById('qDifficulty').value,
    chapter: document.getElementById('qChapter').value,
    unitNumber: parseInt(document.getElementById('qUnitNumber').value, 10),
    unitName: document.getElementById('qUnitName').value,
    quizName: document.getElementById('qQuizName').value,
    type: document.getElementById('qType').value,
    question: document.getElementById('qText').value,
    options: document.getElementById('qOptions').value.split(',').map((o) => o.trim()).filter(Boolean),
    correctAnswer: document.getElementById('qCorrectAnswer').value.trim(),
    imageAsset: document.getElementById('qImageAsset').value.trim() || null,
    explanation: document.getElementById('qExplanation').value.trim() || null,
  };

  try {
    if (id) {
      await api.updateQuestion(id, payload);
      showToast('Question updated successfully.');
    } else {
      await api.createQuestion(payload);
      showToast('Question uploaded to database successfully.');
    }
    closeModal('questionModal');
    loadQuestions();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

function editQuestion(q) {
  document.getElementById('editQuestionId').value = q._id;
  document.getElementById('qSubject').value = q.subject;
  document.getElementById('qGradeClass').value = q.gradeClass || 'Class 3';
  document.getElementById('qDifficulty').value = q.difficulty || 'easy';
  document.getElementById('qChapter').value = q.chapter || 'Chapter 1';
  document.getElementById('qUnitNumber').value = q.unitNumber;
  document.getElementById('qUnitName').value = q.unitName;
  document.getElementById('qQuizName').value = q.quizName;
  document.getElementById('qType').value = q.type || 'MCQ';
  document.getElementById('qText').value = q.question;
  document.getElementById('qOptions').value = (q.options || []).join(', ');
  document.getElementById('qCorrectAnswer').value = q.correctAnswer;
  document.getElementById('qImageAsset').value = q.imageAsset || '';
  document.getElementById('qExplanation').value = q.explanation || '';

  document.getElementById('questionModalTitle').innerText = 'Edit Question';
  openModal('questionModal');
}

async function deleteQuestion(id) {
  if (!confirm('Are you sure you want to delete this question?')) return;
  try {
    await api.deleteQuestion(id);
    showToast('Question deleted successfully.');
    loadQuestions();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: STUDENTS CONTROLLER (Section 1.2)
// ─────────────────────────────────────────────────────────────────────────────
async function loadStudents(page = pagination.students.page) {
  pagination.students.page = page;
  const tbody = document.getElementById('studentsTableBody');
  tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4">Loading student records...</td></tr>';

  try {
    const params = {
      page,
      limit: pagination.students.limit,
      search: document.getElementById('studentSearchInput').value.trim(),
      gradeClass: document.getElementById('studentClassFilter').value,
      isBanned: document.getElementById('studentStatusFilter').value,
    };

    const data = await api.getStudents(params);
    const users = data.users || [];
    pagination.students.total = data.pagination.total;

    if (users.length === 0) {
      tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4">No student records found.</td></tr>';
      renderPagination('studentsPagination', data.pagination, loadStudents);
      return;
    }

    tbody.innerHTML = users.map((u) => `
      <tr>
        <td>
          <strong>${escapeHtml(u.name)}</strong><br>
          <small class="text-muted">${escapeHtml(u.email)}</small>
        </td>
        <td>
          <span class="badge badge-info">${escapeHtml(u.gradeClass || 'Class 3')}</span><br>
          <small class="text-muted">${u.age || 8} yrs</small>
        </td>
        <td><strong>🧠 ${u.iq} IQ</strong></td>
        <td><strong class="text-amber">🪙 ${u.coins}</strong></td>
        <td>🔥 ${u.streak}d (Max: ${u.longestStreak}d)</td>
        <td>
          ${u.isBanned ? '<span class="badge badge-danger">Suspended</span>' : '<span class="badge badge-success">Active</span>'}
        </td>
        <td>
          <small class="text-muted">${formatDate(u.lastLoginAt || u.updatedAt)}</small>
        </td>
        <td>
          <button class="btn btn-primary btn-sm" onclick="viewStudentDetails('${u._id}')">Inspect & Manage</button>
        </td>
      </tr>
    `).join('');

    renderPagination('studentsPagination', data.pagination, loadStudents);
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center py-4 text-danger">Error: ${err.message}</td></tr>`;
  }
}

async function viewStudentDetails(studentId) {
  const content = document.getElementById('studentModalContent');
  content.innerHTML = '<div class="text-center py-4">Loading student telemetry...</div>';
  openModal('studentDetailsModal');

  try {
    const data = await api.getStudentDetails(studentId);
    const u = data.user;

    content.innerHTML = `
      <div class="student-telemetry-header">
        <div class="student-avatar-big">${(u.name || 'S')[0].toUpperCase()}</div>
        <div>
          <h3>${escapeHtml(u.name)}</h3>
          <p class="text-muted">${escapeHtml(u.email)} • Role: <strong>${u.role}</strong></p>
          <p class="text-muted">Device: <strong>${u.deviceType || 'iOS/Android'}</strong> • App Ver: <strong>${u.appVersion || '1.0.0'}</strong></p>
        </div>
      </div>

      <div class="telemetry-grid">
        <div class="telemetry-box">
          <span>Current IQ</span>
          <h4 style="color: var(--primary);">🧠 ${u.iq}</h4>
        </div>
        <div class="telemetry-box">
          <span>Coins Balance</span>
          <h4 style="color: var(--accent-amber);">🪙 ${u.coins}</h4>
        </div>
        <div class="telemetry-box">
          <span>Daily Streak</span>
          <h4 style="color: #F97316;">🔥 ${u.streak} Days</h4>
        </div>
      </div>

      <div class="account-controls-section">
        <h4>⚡ Account Actions & Controls (Section 1.2)</h4>
        <div class="controls-button-grid">
          <button class="btn ${u.isBanned ? 'btn-primary' : 'btn-outline-danger'}" onclick="handleBanToggle('${u._id}', ${u.isBanned})">
            ${u.isBanned ? '✅ Unban Student' : '🚫 Ban / Suspend'}
          </button>
          <button class="btn btn-secondary" onclick="handleResetPasswordPrompt('${u._id}', '${escapeHtml(u.email)}')">
            🔑 Reset Password
          </button>
          <button class="btn btn-secondary" onclick="handleForceLogout('${u._id}')">
            🚪 Force Logout
          </button>
          <button class="btn btn-secondary" onclick="handleAdjustBalancePrompt('${u._id}')">
            🪙 Add/Deduct Coins & IQ
          </button>
          <button class="btn btn-secondary" onclick="handleRestoreStreakPrompt('${u._id}', ${u.streak})">
            🔥 Restore Streak
          </button>
        </div>
      </div>
    `;
  } catch (err) {
    content.innerHTML = `<div class="text-danger text-center py-4">Failed to load student: ${err.message}</div>`;
  }
}

async function handleBanToggle(id, isBanned) {
  const reason = prompt(`Reason for ${isBanned ? 'unbanning' : 'banning'} this student:`, 'Violating terms');
  if (reason === null) return;
  try {
    const res = await api.toggleBanStudent(id, reason);
    showToast(res.message);
    viewStudentDetails(id);
    loadStudents();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleResetPasswordPrompt(id, email) {
  const newPassword = prompt(`Enter new password for ${email} (min 6 characters):`, 'KiddoPass@123');
  if (!newPassword) return;
  try {
    const res = await api.resetStudentPassword(id, newPassword);
    showToast(res.message);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleForceLogout(id) {
  if (!confirm('Force logout this user from all active app sessions?')) return;
  try {
    const res = await api.forceLogoutStudent(id);
    showToast(res.message);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleAdjustBalancePrompt(id) {
  const coinsStr = prompt('Coins to add (e.g. +100 or -50):', '50');
  if (coinsStr === null) return;
  const iqStr = prompt('IQ to add (e.g. +50 or -20):', '50');
  if (iqStr === null) return;
  const reason = prompt('Reason for balance adjustment:', 'Bonus reward');

  try {
    const res = await api.adjustCurrency(id, parseInt(iqStr || 0, 10), parseInt(coinsStr || 0, 10), reason);
    showToast(res.message);
    viewStudentDetails(id);
    loadStudents();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleRestoreStreakPrompt(id, currentStreak) {
  const newStreak = prompt(`Enter restored streak number (Current: ${currentStreak}):`, currentStreak + 1);
  if (newStreak === null) return;
  const reason = prompt('Reason for streak restoration:', 'Streak freeze compensation');

  try {
    const res = await api.restoreStreak(id, parseInt(newStreak, 10), reason);
    showToast(res.message);
    viewStudentDetails(id);
    loadStudents();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: ENGAGEMENT, MULTIPLIERS & BROADCASTS (Section 1.3)
// ─────────────────────────────────────────────────────────────────────────────
async function loadEngagement() {
  try {
    // Load System Config
    const configRes = await api.getSystemConfig();
    const config = configRes.config || {};

    document.getElementById('doubleXpToggle').checked = Boolean(config.doubleXpEnabled);
    document.getElementById('baseXpMultiplier').value = config.baseXpMultiplier || 1.0;
    document.getElementById('bossBattleXpMultiplier').value = config.bossBattleXpMultiplier || 1.5;
    document.getElementById('doubleXpTitle').value = config.doubleXpTitle || 'Double XP Weekend';
    document.getElementById('streakReminderToggle').checked = Boolean(config.streakReminderEnabled);
    document.getElementById('streakReminderHour').value = config.streakReminderHour || 20;

    // Load Broadcasts
    const broadcastRes = await api.getBroadcasts();
    const list = document.getElementById('broadcastsList');
    const broadcasts = broadcastRes.broadcasts || [];

    if (broadcasts.length === 0) {
      list.innerHTML = '<div class="text-center text-muted py-4">No broadcast announcements active.</div>';
      return;
    }

    list.innerHTML = broadcasts.map((b) => `
      <div class="broadcast-item">
        <div class="broadcast-content">
          <h4>${escapeHtml(b.title)} <span class="badge ${b.type === 'warning' ? 'badge-danger' : b.type === 'event' ? 'badge-purple' : 'badge-info'}">${b.type}</span></h4>
          <p>${escapeHtml(b.message)}</p>
          <div class="broadcast-meta">Target: <strong>${b.targetClass}</strong> • Created: ${formatDate(b.createdAt)}</div>
        </div>
        <div class="action-btn-group">
          <button class="btn btn-sm ${b.active ? 'btn-primary' : 'btn-secondary'}" onclick="handleToggleBroadcast('${b._id}')">
            ${b.active ? 'Active' : 'Paused'}
          </button>
          <button class="btn btn-outline-danger btn-sm" onclick="handleDeleteBroadcast('${b._id}')">🗑️</button>
        </div>
      </div>
    `).join('');
  } catch (err) {
    showToast(`Failed to load engagement settings: ${err.message}`, 'error');
  }
}

async function handleSaveMultiplierConfig(e) {
  e.preventDefault();
  const payload = {
    doubleXpEnabled: document.getElementById('doubleXpToggle').checked,
    baseXpMultiplier: parseFloat(document.getElementById('baseXpMultiplier').value),
    bossBattleXpMultiplier: parseFloat(document.getElementById('bossBattleXpMultiplier').value),
    doubleXpTitle: document.getElementById('doubleXpTitle').value.trim(),
    streakReminderEnabled: document.getElementById('streakReminderToggle').checked,
    streakReminderHour: parseInt(document.getElementById('streakReminderHour').value, 10),
  };

  try {
    await api.updateSystemConfig(payload);
    showToast('Multipliers and automated trigger settings saved.');
    loadOverview();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleSaveBroadcast(e) {
  e.preventDefault();
  const payload = {
    title: document.getElementById('bcTitle').value.trim(),
    message: document.getElementById('bcMessage').value.trim(),
    type: document.getElementById('bcType').value,
    targetClass: document.getElementById('bcTargetClass').value,
  };

  try {
    await api.createBroadcast(payload);
    showToast('Broadcast published to students.');
    closeModal('broadcastModal');
    loadEngagement();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleToggleBroadcast(id) {
  try {
    await api.toggleBroadcast(id);
    showToast('Broadcast status updated.');
    loadEngagement();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

async function handleDeleteBroadcast(id) {
  if (!confirm('Delete this broadcast?')) return;
  try {
    await api.deleteBroadcast(id);
    showToast('Broadcast deleted.');
    loadEngagement();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 5: STORE MANAGER CONTROLLER (Section 1.4)
// ─────────────────────────────────────────────────────────────────────────────
async function loadStoreItems() {
  const tbody = document.getElementById('storeTableBody');
  tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">Loading store inventory...</td></tr>';

  try {
    const data = await api.getStoreItems();
    const items = data.items || [];

    if (items.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">No store items found in database.</td></tr>';
      return;
    }

    tbody.innerHTML = items.map((item) => `
      <tr>
        <td>
          <div style="font-size: 28px; width: 44px; height: 44px; background: var(--bg-main); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
            ${item.emoji || '🎁'}
          </div>
        </td>
        <td>
          <strong>${escapeHtml(item.name)}</strong><br>
          <code>${escapeHtml(item._id)}</code>
        </td>
        <td><span class="badge badge-purple">${escapeHtml(item.category)}</span></td>
        <td><strong style="color: var(--accent-amber);">🪙 ${item.coinCost} Coins</strong></td>
        <td><small class="text-muted">${escapeHtml(item.description || '')}</small></td>
        <td>
          ${item.isAvailable ? '<span class="badge badge-success">Available</span>' : '<span class="badge badge-danger">Hidden</span>'}
        </td>
        <td>
          <div class="action-btn-group">
            <button class="btn btn-secondary btn-sm" onclick='editStoreItem(${JSON.stringify(item).replace(/'/g, "&apos;")})'>✏️</button>
            <button class="btn btn-outline-danger btn-sm" onclick="deleteStoreItem('${item._id}')">🗑️</button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center py-4 text-danger">Error: ${err.message}</td></tr>`;
  }
}

async function handleSaveStoreItem(e) {
  e.preventDefault();
  const id = document.getElementById('editStoreId').value;
  const isEditing = Boolean(id);

  const payload = {
    _id: document.getElementById('storeItemId').value.trim(),
    name: document.getElementById('storeItemName').value.trim(),
    category: document.getElementById('storeItemCategory').value,
    coinCost: parseInt(document.getElementById('storeItemCost').value, 10),
    emoji: document.getElementById('storeItemEmoji').value.trim() || '✨',
    description: document.getElementById('storeItemDescription').value.trim(),
    imageAsset: document.getElementById('storeItemImage').value.trim() || 'assets/images/kido_character.png',
  };

  try {
    if (isEditing) {
      await api.updateStoreItem(id, payload);
      showToast('Store item updated.');
    } else {
      await api.createStoreItem(payload);
      showToast('Store item added. Visible live in Flutter shop.');
    }
    closeModal('storeItemModal');
    loadStoreItems();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

function editStoreItem(item) {
  document.getElementById('editStoreId').value = item._id;
  document.getElementById('storeItemId').value = item._id;
  document.getElementById('storeItemId').disabled = true;
  document.getElementById('storeItemName').value = item.name;
  document.getElementById('storeItemCategory').value = item.category || 'avatar';
  document.getElementById('storeItemCost').value = item.coinCost;
  document.getElementById('storeItemEmoji').value = item.emoji || '✨';
  document.getElementById('storeItemDescription').value = item.description || '';
  document.getElementById('storeItemImage').value = item.imageAsset || '';

  document.getElementById('storeModalTitle').innerText = 'Edit Store Asset';
  openModal('storeItemModal');
}

async function deleteStoreItem(id) {
  if (!confirm(`Delete store item "${id}"?`)) return;
  try {
    await api.deleteStoreItem(id);
    showToast('Store item deleted.');
    loadStoreItems();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 6: AUDIT LOGS CONTROLLER (Section 1.5)
// ─────────────────────────────────────────────────────────────────────────────
async function loadAuditLogs(page = pagination.audit.page) {
  pagination.audit.page = page;
  const tbody = document.getElementById('auditTableBody');
  tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">Loading audit logs...</td></tr>';

  try {
    const params = {
      page,
      limit: pagination.audit.limit,
      search: document.getElementById('auditSearchInput').value.trim(),
      action: document.getElementById('auditActionFilter').value,
    };

    const data = await api.getAuditLogs(params);
    const logs = data.logs || [];
    pagination.audit.total = data.pagination.total;

    if (logs.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4">No audit records found.</td></tr>';
      renderPagination('auditPagination', data.pagination, loadAuditLogs);
      return;
    }

    tbody.innerHTML = logs.map((log) => `
      <tr>
        <td><small class="text-muted">${formatDate(log.createdAt)}</small></td>
        <td>
          <strong>${escapeHtml(log.adminEmail)}</strong><br>
          <span class="badge badge-purple">${log.adminRole || 'admin'}</span>
        </td>
        <td>
          <span class="badge ${log.action.includes('BAN') || log.action.includes('DELETE') ? 'badge-danger' : 'badge-cyan'}">${log.action}</span>
        </td>
        <td><code>${escapeHtml(log.resource)}</code></td>
        <td><small><code>${escapeHtml(log.resourceId || 'N/A')}</code></small></td>
        <td style="max-width: 240px;">
          <small><code>${escapeHtml(JSON.stringify(log.details || {}))}</code></small>
        </td>
        <td><small class="text-muted">${escapeHtml(log.ipAddress || '127.0.0.1')}</small></td>
      </tr>
    `).join('');

    renderPagination('auditPagination', data.pagination, loadAuditLogs);
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center py-4 text-danger">Error: ${err.message}</td></tr>`;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITY FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
function renderPagination(containerId, meta, callback) {
  const container = document.getElementById(containerId);
  if (!container || !meta || meta.totalPages <= 1) {
    if (container) container.innerHTML = '';
    return;
  }

  let html = '';
  for (let i = 1; i <= meta.totalPages; i++) {
    html += `<button class="page-btn ${i === meta.page ? 'active' : ''}" onclick="${callback.name}(${i})">${i}</button>`;
  }
  container.innerHTML = html;
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function debounce(func, wait) {
  let timeout;
  return function (...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
  };
}
