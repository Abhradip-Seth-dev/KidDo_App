/**
 * api.js — KidDO Admin API Client Wrapper
 */
const API_BASE = window.location.origin + '/api';

const api = {
  getToken() {
    return localStorage.getItem('kiddo_admin_token');
  },

  setToken(token) {
    localStorage.setItem('kiddo_admin_token', token);
  },

  clearToken() {
    localStorage.removeItem('kiddo_admin_token');
    localStorage.removeItem('kiddo_admin_user');
  },

  getUser() {
    const userStr = localStorage.getItem('kiddo_admin_user');
    try {
      return userStr ? JSON.parse(userStr) : null;
    } catch {
      return null;
    }
  },

  setUser(user) {
    localStorage.setItem('kiddo_admin_user', JSON.stringify(user));
  },

  async request(endpoint, options = {}) {
    const token = this.getToken();
    const headers = {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {}),
    };

    const config = {
      ...options,
      headers,
    };

    if (config.body && typeof config.body === 'object') {
      config.body = JSON.stringify(config.body);
    }

    try {
      const response = await fetch(`${API_BASE}${endpoint}`, config);
      const data = await response.json();

      if (!response.ok) {
        if (response.status === 401 || response.status === 403) {
          if (response.status === 401 && !endpoint.includes('/auth/login')) {
            this.clearToken();
            window.location.reload();
          }
        }
        throw new Error(data.message || `Request failed with status ${response.status}`);
      }

      return data;
    } catch (err) {
      console.error(`API Error on ${endpoint}:`, err);
      throw err;
    }
  },

  // Auth
  login(email, password) {
    return this.request('/auth/login', {
      method: 'POST',
      body: { email, password },
    });
  },

  // 1. Dashboard Stats
  getStats() {
    return this.request('/admin/stats');
  },

  // 1.1 Content & Questions
  getQuestions(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.request(`/admin/questions?${query}`);
  },

  createQuestion(questionData) {
    return this.request('/admin/questions', {
      method: 'POST',
      body: questionData,
    });
  },

  updateQuestion(id, questionData) {
    return this.request(`/admin/questions/${id}`, {
      method: 'PUT',
      body: questionData,
    });
  },

  deleteQuestion(id) {
    return this.request(`/admin/questions/${id}`, {
      method: 'DELETE',
    });
  },

  // 1.2 User & Account Controls
  getStudents(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.request(`/admin/students?${query}`);
  },

  getStudentDetails(id) {
    return this.request(`/admin/students/${id}`);
  },

  toggleBanStudent(id, reason) {
    return this.request(`/admin/students/${id}/ban`, {
      method: 'PATCH',
      body: { reason },
    });
  },

  resetStudentPassword(id, newPassword) {
    return this.request(`/admin/students/${id}/reset-password`, {
      method: 'POST',
      body: { newPassword },
    });
  },

  forceLogoutStudent(id) {
    return this.request(`/admin/students/${id}/force-logout`, {
      method: 'POST',
    });
  },

  adjustCurrency(id, iqDelta, coinsDelta, reason) {
    return this.request(`/admin/students/${id}/adjust-currency`, {
      method: 'POST',
      body: { iqDelta, coinsDelta, reason },
    });
  },

  restoreStreak(id, streakCount, reason) {
    return this.request(`/admin/students/${id}/restore-streak`, {
      method: 'POST',
      body: { streakCount, reason },
    });
  },

  // 1.3 Engagement & System Settings
  getSystemConfig() {
    return this.request('/admin/config');
  },

  updateSystemConfig(config) {
    return this.request('/admin/config', {
      method: 'PUT',
      body: config,
    });
  },

  getBroadcasts() {
    return this.request('/admin/broadcasts');
  },

  createBroadcast(broadcastData) {
    return this.request('/admin/broadcasts', {
      method: 'POST',
      body: broadcastData,
    });
  },

  toggleBroadcast(id) {
    return this.request(`/admin/broadcasts/${id}/toggle`, {
      method: 'PATCH',
    });
  },

  deleteBroadcast(id) {
    return this.request(`/admin/broadcasts/${id}`, {
      method: 'DELETE',
    });
  },

  // 1.4 Store Manager
  getStoreItems() {
    return this.request('/admin/store');
  },

  createStoreItem(itemData) {
    return this.request('/admin/store', {
      method: 'POST',
      body: itemData,
    });
  },

  updateStoreItem(id, itemData) {
    return this.request(`/admin/store/${id}`, {
      method: 'PUT',
      body: itemData,
    });
  },

  deleteStoreItem(id) {
    return this.request(`/admin/store/${id}`, {
      method: 'DELETE',
    });
  },

  // 1.5 Audit Logs
  getAuditLogs(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.request(`/admin/audit-logs?${query}`);
  },
};
