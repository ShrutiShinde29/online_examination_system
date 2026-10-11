USE online_exam_system;

-- Ensure roles exist
INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'System administrator'),
('TEACHER', 'Faculty user'),
('STUDENT', 'Learner user')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Force default users with known password 123456 (SHA-256)
INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'System Admin', 'admin@oes.com',
       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'ADMIN'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Teacher One', 'teacher@oes.com',
       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'TEACHER'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

INSERT INTO users (role_id, full_name, email, password_hash, is_active)
SELECT r.role_id, 'Student One', 'student@oes.com',
       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1
FROM roles r WHERE r.role_name = 'STUDENT'
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id),
full_name = VALUES(full_name),
password_hash = VALUES(password_hash),
is_active = VALUES(is_active);

-- Optional sanity output
SELECT user_id, email, password_hash, is_active
FROM users
WHERE email IN ('admin@oes.com', 'teacher@oes.com', 'student@oes.com');
