/**
 * AI Engine Gateway Service
 * Proxies calls from Node.js backend to the Python FastAPI AI Engine (port 8000).
 */

const AI_ENGINE_URL = process.env.AI_ENGINE_URL || 'http://localhost:8000';

class AiEngineGateway {
  constructor(baseUrl = AI_ENGINE_URL) {
    this.baseUrl = baseUrl;
  }

  /**
   * Health check on Python FastAPI AI Engine
   */
  async checkHealth() {
    try {
      const res = await fetch(`${this.baseUrl}/health`);
      return res.ok;
    } catch (err) {
      return false;
    }
  }

  /**
   * Start a practice session in the Python AI Engine
   * POST /api/v1/sessions/
   */
  async startSession({ studentId, subjectCode, topicCode }) {
    const res = await fetch(`${this.baseUrl}/api/v1/sessions/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        student_id: studentId,
        subject_code: subjectCode,
        topic_code: topicCode,
      }),
    });

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`AI Engine startSession failed (${res.status}): ${errorText}`);
    }

    return await res.json();
  }

  /**
   * Get the next difficulty-matched question from Python AI Engine
   * GET /api/v1/sessions/:sessionId/next-question
   */
  async getNextQuestion(sessionId) {
    const res = await fetch(`${this.baseUrl}/api/v1/sessions/${sessionId}/next-question`);

    if (res.status === 404) {
      const data = await res.json().catch(() => ({}));
      if (data.detail === 'pool_exhausted') {
        return { isTopicMastered: true, message: 'Question pool exhausted for this difficulty tier.' };
      }
      return null;
    }

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`AI Engine getNextQuestion failed (${res.status}): ${errorText}`);
    }

    return await res.json();
  }

  /**
   * Submit an answer attempt to Python AI Engine for authoritative checking & progression
   * POST /api/v1/attempts/
   */
  async submitAttempt({
    sessionId,
    questionDbId,
    submissionId,
    selectedAnswer,
    hintsUsed = 0,
    timeTakenSeconds = 0,
  }) {
    const res = await fetch(`${this.baseUrl}/api/v1/attempts/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        session_id: sessionId,
        question_db_id: questionDbId,
        submission_id: submissionId,
        selected_answer: selectedAnswer,
        hints_used: hintsUsed,
        time_taken_seconds: timeTakenSeconds,
      }),
    });

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`AI Engine submitAttempt failed (${res.status}): ${errorText}`);
    }

    return await res.json();
  }

  /**
   * Get student progress from Python AI Engine
   * GET /api/v1/students/:studentId/progress
   */
  async getStudentProgress(studentId) {
    const res = await fetch(`${this.baseUrl}/api/v1/students/${studentId}/progress`);

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`AI Engine getStudentProgress failed (${res.status}): ${errorText}`);
    }

    return await res.json();
  }
}

module.exports = new AiEngineGateway();
