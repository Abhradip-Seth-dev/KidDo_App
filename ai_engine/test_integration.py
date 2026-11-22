"""Integration test — runs the server in-process and hits every endpoint."""
import uvicorn
import threading
import time
import uuid
import httpx
import os
import sys

# Remove old DB
db_path = os.path.join(os.path.dirname(__file__), "ai_engine_dev.db")
if os.path.exists(db_path):
    os.remove(db_path)

# Start server in background thread
def run_server():
    uvicorn.run("main:app", host="127.0.0.1", port=8000, log_level="warning")

t = threading.Thread(target=run_server, daemon=True)
t.start()
time.sleep(5)

base = "http://127.0.0.1:8000"
client = httpx.Client(base_url=base, timeout=10)
errors = []

def check(label, condition, detail=""):
    status = "✅" if condition else "❌"
    print(f"  {status} {label} {detail}")
    if not condition:
        errors.append(label)

print("=" * 60)
print("KidDo AI Engine — Integration Test")
print("=" * 60)

# 1. Health
r = client.get("/health")
check("Health check", r.status_code == 200, f"→ {r.json()}")

# 2. Root
r = client.get("/")
check("Root endpoint", r.json()["service"] == "KidDo AI Engine")

# 3. List subjects
r = client.get("/api/v1/questions/subjects")
subjects = r.json()
check("Subjects seeded", len(subjects) == 4, f"→ {[s['code'] for s in subjects]}")

# 4. List topics for MATH
r = client.get("/api/v1/questions/topics", params={"subject_code": "MATH"})
topics = r.json()
check("Math topics loaded", len(topics) == 10, f"→ {len(topics)} topics")
math_topic_code = topics[0]["code"] if topics else "MATH-U1"

# 5. Start session
r = client.post("/api/v1/sessions/", json={
    "student_id": "test-student-001",
    "subject_code": "MATH",
    "topic_code": math_topic_code,
})
check("Start session", r.status_code == 201, f"→ status={r.status_code}")
sess = r.json()
session_id = sess["session_id"]
check("Initial score = 100", sess["subject_score"] == 100)
check("Initial difficulty = beginner", sess["current_difficulty"] == "beginner")
check("Mastery label = not_enough_data", sess["mastery_label"] == "not_enough_data")

# 6. Get next question
r = client.get(f"/api/v1/sessions/{session_id}/next-question")
check("Get next question", r.status_code == 200)
q = r.json()
check("Question has content", "question" in q["content"])
check("Question has options", len(q["content"]["options"]) >= 2)
check("NO answer_key leaked", "answer_key" not in q)
check("Difficulty = beginner", q["difficulty"] == "beginner")
print(f"     Question: \"{q['content']['question'][:60]}\"")
print(f"     Options:  {[o['text'] for o in q['content']['options']]}")

# 7. Submit an answer
sub_id = str(uuid.uuid4())
r = client.post("/api/v1/attempts/", json={
    "session_id": session_id,
    "question_db_id": q["question_db_id"],
    "submission_id": sub_id,
    "selected_answer": {"option_id": q["content"]["options"][0]["option_id"]},
    "hints_used": 0,
    "time_taken_seconds": 8,
})
check("Submit answer", r.status_code == 201, f"→ status={r.status_code}")
a = r.json()
check("Has is_correct field", "is_correct" in a)
check("Has score update", "points_change" in a["score"])
check("Has mastery update", "current_difficulty" in a["progress"])
check("Has feedback", len(a["feedback"]["message"]) > 0, f"→ \"{a['feedback']['message']}\"")
print(f"     Correct: {a['is_correct']}, Points: {a['score']['points_change']}, Score: {a['score']['subject_score']}")

# 8. Idempotency test
r2 = client.post("/api/v1/attempts/", json={
    "session_id": session_id,
    "question_db_id": q["question_db_id"],
    "submission_id": sub_id,
    "selected_answer": {"option_id": q["content"]["options"][0]["option_id"]},
    "hints_used": 0,
})
check("Idempotency works", r2.status_code == 201)
check("Same attempt_id returned", a["attempt_id"] == r2.json()["attempt_id"])

# 9. Get progress dashboard
r = client.get("/api/v1/students/test-student-001/progress")
check("Progress dashboard", r.status_code == 200)
p = r.json()
check("Has overall score", "overall_score" in p)
check("Has subjects list", len(p["subjects"]) >= 1, f"→ {len(p['subjects'])} subjects")
check("Has topics list", len(p["topics"]) >= 1, f"→ {len(p['topics'])} topics")
print(f"     Overall: {p['overall_score']}, Active subjects: {p['active_subject_count']}")

# 10. 404 cases
r = client.post("/api/v1/sessions/", json={
    "student_id": "x",
    "subject_code": "INVALID",
    "topic_code": "MATH-U1",
})
check("404 on invalid subject", r.status_code == 404)

r = client.get("/api/v1/sessions/nonexistent-session/next-question")
check("404 on invalid session", r.status_code == 404)

# 11. Question hint
r = client.get(f"/api/v1/questions/{q['question_db_id']}/hint")
check("Hint endpoint", r.status_code == 200, f"→ {r.json()}")

print()
print("=" * 60)
if errors:
    print(f"FAILED: {len(errors)} tests failed: {errors}")
    sys.exit(1)
else:
    print("ALL TESTS PASSED ✅")
    sys.exit(0)
