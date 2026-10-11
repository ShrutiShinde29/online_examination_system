USE online_exam_system;

-- 1) Ensure a published exam exists for student visibility
SELECT exam_id, title, status, subject_id FROM exams ORDER BY exam_id DESC;

-- 2) Ensure student is enrolled in the exam's course
SELECT u.user_id, u.email, e.enrollment_id, c.course_name
FROM users u
LEFT JOIN enrollments e ON e.student_id = u.user_id
LEFT JOIN courses c ON c.course_id = e.course_id
WHERE u.email = 'student@oes.com';

-- Optional repair if no enrollment exists:
INSERT INTO enrollments (student_id, course_id)
SELECT u.user_id, c.course_id
FROM users u
JOIN courses c ON c.course_name = 'BCA'
WHERE u.email = 'student@oes.com'
AND NOT EXISTS (
    SELECT 1 FROM enrollments en WHERE en.student_id = u.user_id AND en.course_id = c.course_id
);

-- 3) Relationship check: each question must map to a valid exam
SELECT q.question_id, q.exam_id, e.exam_id AS existing_exam_id, e.title
FROM questions q
LEFT JOIN exams e ON e.exam_id = q.exam_id
WHERE e.exam_id IS NULL;

-- 4) Duplicate question detector in same exam
SELECT exam_id, question_text, question_type, COUNT(*) AS cnt
FROM questions
GROUP BY exam_id, question_text, question_type
HAVING COUNT(*) > 1;

-- 5) Duplicate option detector per question
SELECT question_id, option_text, COUNT(*) AS cnt
FROM options
GROUP BY question_id, option_text
HAVING COUNT(*) > 1;

-- 6) Schema check for required FK relationships
SELECT
    kcu.TABLE_NAME,
    kcu.COLUMN_NAME,
    kcu.REFERENCED_TABLE_NAME,
    kcu.REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE kcu
WHERE kcu.TABLE_SCHEMA = DATABASE()
  AND kcu.TABLE_NAME IN ('questions', 'options')
  AND kcu.REFERENCED_TABLE_NAME IS NOT NULL;

-- Optional hardening (run once manually if needed):
-- ALTER TABLE questions ADD INDEX idx_questions_exam (exam_id);
-- ALTER TABLE options ADD INDEX idx_options_question (question_id);
-- ALTER TABLE questions ADD UNIQUE KEY uq_exam_question_text_type (exam_id, question_text(255), question_type);
