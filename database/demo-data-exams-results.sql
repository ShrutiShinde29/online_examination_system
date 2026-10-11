USE online_exam_system;

-- Ensure base roles/users exist (password: 123456)
INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'System administrator'),
('TEACHER', 'Faculty user'),
('STUDENT', 'Learner user')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- sha256('123456')
SET @P = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT role_id, 'Teacher One', 'teacher@oes.com', @P, 1 FROM roles WHERE role_name='TEACHER'
ON DUPLICATE KEY UPDATE password_hash=@P, is_active=1, role_id=VALUES(role_id);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT role_id, 'Student One', 'student@oes.com', @P, 1 FROM roles WHERE role_name='STUDENT'
ON DUPLICATE KEY UPDATE password_hash=@P, is_active=1, role_id=VALUES(role_id);

-- Course + subjects
INSERT INTO courses (course_name, description)
VALUES ('BCA', 'Bachelor of Computer Applications')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO subjects (course_id, subject_name)
SELECT c.course_id, 'Java Programming' FROM courses c
WHERE c.course_name='BCA'
AND NOT EXISTS (SELECT 1 FROM subjects s WHERE s.course_id=c.course_id AND s.subject_name='Java Programming');

-- Enrollment
INSERT INTO enrollments (student_id, course_id)
SELECT u.user_id, c.course_id
FROM users u JOIN courses c ON c.course_name='BCA'
WHERE u.email='student@oes.com'
AND NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id=u.user_id AND e.course_id=c.course_id);

-- Published Exam
INSERT INTO exams (subject_id, teacher_id, title, duration_minutes, total_marks, status)
SELECT s.subject_id, t.user_id, 'Java Unit Test 1', 20, 10, 'PUBLISHED'
FROM subjects s
JOIN users t ON t.email='teacher@oes.com'
WHERE s.subject_name='Java Programming'
AND NOT EXISTS (SELECT 1 FROM exams e WHERE e.title='Java Unit Test 1');

-- Questions
INSERT INTO questions (exam_id, question_text, question_type, marks, model_answer, expected_keywords)
SELECT e.exam_id, 'JVM stands for?', 'MCQ', 5, NULL, NULL
FROM exams e WHERE e.title='Java Unit Test 1'
AND NOT EXISTS (SELECT 1 FROM questions q WHERE q.exam_id=e.exam_id AND q.question_text='JVM stands for?');

INSERT INTO questions (exam_id, question_text, question_type, marks, model_answer, expected_keywords)
SELECT e.exam_id, 'Write any two OOP concepts.', 'SUBJECTIVE', 5, 'Encapsulation, Inheritance', 'encapsulation,inheritance,polymorphism,abstraction'
FROM exams e WHERE e.title='Java Unit Test 1'
AND NOT EXISTS (SELECT 1 FROM questions q WHERE q.exam_id=e.exam_id AND q.question_text='Write any two OOP concepts.');

-- Options for MCQ (dedup safe)
INSERT INTO options (question_id, option_text, is_correct)
SELECT q.question_id, x.option_text, x.is_correct
FROM questions q
JOIN exams e ON e.exam_id=q.exam_id AND e.title='Java Unit Test 1'
JOIN (
    SELECT 'Java Virtual Machine' AS option_text, 1 AS is_correct
    UNION ALL SELECT 'Java Variable Method', 0
    UNION ALL SELECT 'Just Virtual Memory', 0
    UNION ALL SELECT 'Joint Vector Module', 0
) x
WHERE q.question_text='JVM stands for?'
AND NOT EXISTS (SELECT 1 FROM options o WHERE o.question_id=q.question_id);

-- Create one evaluated result to show performance on dashboard
INSERT INTO results (exam_id, student_id, score_obtained, status, submitted_at)
SELECT e.exam_id, u.user_id, 7.00, 'EVALUATED', NOW()
FROM exams e
JOIN users u ON u.email='student@oes.com'
WHERE e.title='Java Unit Test 1'
AND NOT EXISTS (SELECT 1 FROM results r WHERE r.exam_id=e.exam_id AND r.student_id=u.user_id AND r.status='EVALUATED');

