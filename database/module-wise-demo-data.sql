USE online_exam_system;

-- =========================================================
-- MODULE 1 + 4: ROLES, USERS, AUTH
-- Password used below: 123456
-- SHA-256: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
-- =========================================================
INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'System administrator'),
('TEACHER', 'Faculty user'),
('STUDENT', 'Learner user')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'System Admin', 'admin@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'ADMIN'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Teacher One', 'teacher@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'TEACHER'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Student One', 'student@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'STUDENT'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

-- =========================================================
-- MODULE 6: QUESTION/COURSE MANAGEMENT
-- =========================================================
INSERT INTO courses (course_name, description)
VALUES
('BCA', 'Bachelor of Computer Applications'),
('MCA', 'Master of Computer Applications')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO subjects (course_id, subject_name)
SELECT c.course_id, 'Java Programming' FROM courses c
WHERE c.course_name = 'BCA'
AND NOT EXISTS (
    SELECT 1 FROM subjects s WHERE s.course_id = c.course_id AND s.subject_name = 'Java Programming'
);

INSERT INTO subjects (course_id, subject_name)
SELECT c.course_id, 'Database Management' FROM courses c
WHERE c.course_name = 'BCA'
AND NOT EXISTS (
    SELECT 1 FROM subjects s WHERE s.course_id = c.course_id AND s.subject_name = 'Database Management'
);

INSERT INTO subjects (course_id, subject_name)
SELECT c.course_id, 'Software Engineering' FROM courses c
WHERE c.course_name = 'MCA'
AND NOT EXISTS (
    SELECT 1 FROM subjects s WHERE s.course_id = c.course_id AND s.subject_name = 'Software Engineering'
);

-- =========================================================
-- MODULE 3: STUDENT ENROLLMENT
-- =========================================================
INSERT INTO enrollments (student_id, course_id)
SELECT u.user_id, c.course_id
FROM users u
JOIN roles r ON r.role_id = u.role_id AND r.role_name = 'STUDENT'
JOIN courses c ON c.course_name = 'BCA'
WHERE u.email = 'student@oes.com'
AND NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = u.user_id AND e.course_id = c.course_id
);

-- =========================================================
-- MODULE 2: TEACHER EXAMS
-- =========================================================
INSERT INTO exams (subject_id, teacher_id, title, duration_minutes, total_marks, status)
SELECT s.subject_id, t.user_id, 'Java Mid Term Test', 30, 20, 'PUBLISHED'
FROM subjects s
JOIN courses c ON c.course_id = s.course_id AND c.course_name = 'BCA'
JOIN users t ON t.email = 'teacher@oes.com'
WHERE s.subject_name = 'Java Programming'
AND NOT EXISTS (
    SELECT 1 FROM exams e WHERE e.title = 'Java Mid Term Test' AND e.teacher_id = t.user_id
);

-- MCQ + Subjective questions for Java Mid Term Test
INSERT INTO questions (exam_id, question_text, question_type, marks, model_answer, expected_keywords)
SELECT e.exam_id, 'What is JVM?', 'MCQ', 5, NULL, NULL
FROM exams e
WHERE e.title = 'Java Mid Term Test'
AND NOT EXISTS (
    SELECT 1 FROM questions q WHERE q.exam_id = e.exam_id AND q.question_text = 'What is JVM?'
);

INSERT INTO questions (exam_id, question_text, question_type, marks, model_answer, expected_keywords)
SELECT e.exam_id, 'Explain OOP concepts in Java.', 'SUBJECTIVE', 15, 'Encapsulation, Inheritance, Polymorphism, Abstraction', 'encapsulation,inheritance,polymorphism,abstraction'
FROM exams e
WHERE e.title = 'Java Mid Term Test'
AND NOT EXISTS (
    SELECT 1 FROM questions q WHERE q.exam_id = e.exam_id AND q.question_text = 'Explain OOP concepts in Java.'
);

INSERT INTO options (question_id, option_text, is_correct)
SELECT q.question_id, x.option_text, x.is_correct
FROM questions q
JOIN exams e ON e.exam_id = q.exam_id AND e.title = 'Java Mid Term Test'
JOIN (
    SELECT 'Java Virtual Machine' AS option_text, 1 AS is_correct
    UNION ALL SELECT 'Java Variable Method', 0
    UNION ALL SELECT 'Joint Vector Module', 0
    UNION ALL SELECT 'Just Virtual Memory', 0
) x
WHERE q.question_text = 'What is JVM?'
AND NOT EXISTS (
    SELECT 1 FROM options o WHERE o.question_id = q.question_id
);

-- =========================================================
-- MODULE 9: NOTIFICATIONS
-- =========================================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    message_body    TEXT NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_notifications (
    user_notification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    notification_id      BIGINT UNSIGNED NOT NULL,
    user_id              BIGINT UNSIGNED NOT NULL,
    is_read              TINYINT(1) NOT NULL DEFAULT 0,
    created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_un_notification FOREIGN KEY (notification_id) REFERENCES notifications(notification_id) ON DELETE CASCADE,
    CONSTRAINT fk_un_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO notifications (title, message_body)
SELECT 'Welcome', 'Welcome to Online Examination and Evaluation System'
WHERE NOT EXISTS (
    SELECT 1 FROM notifications WHERE title = 'Welcome'
);

INSERT INTO user_notifications (notification_id, user_id, is_read)
SELECT n.notification_id, u.user_id, 0
FROM notifications n
JOIN users u ON u.is_active = 1
WHERE n.title = 'Welcome'
AND NOT EXISTS (
    SELECT 1 FROM user_notifications un
    WHERE un.notification_id = n.notification_id AND un.user_id = u.user_id
);
