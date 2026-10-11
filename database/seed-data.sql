USE online_exam_system;

INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'System administrator'),
('TEACHER', 'Faculty user'),
('STUDENT', 'Learner user')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Password for all users below: 123456
-- sha256('123456') = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'System Admin', 'admin@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'ADMIN'
ON DUPLICATE KEY UPDATE
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Teacher One', 'teacher@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'TEACHER'
ON DUPLICATE KEY UPDATE
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Student One', 'student@oes.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'STUDENT'
ON DUPLICATE KEY UPDATE
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO courses (course_name, description)
VALUES ('BCA', 'Bachelor of Computer Applications')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO subjects (course_id, subject_name)
SELECT c.course_id, 'Java Programming'
FROM courses c WHERE c.course_name = 'BCA';

INSERT INTO enrollments (student_id, course_id)
SELECT s.user_id, c.course_id
FROM users s
JOIN roles r ON r.role_id = s.role_id AND r.role_name = 'STUDENT'
JOIN courses c ON c.course_name = 'BCA';
