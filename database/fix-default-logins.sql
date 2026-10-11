USE online_exam_system;

-- Reset default project login users to password: 123456
UPDATE users
SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
    is_active = 1
WHERE email IN ('admin@oes.com', 'teacher@oes.com', 'student@oes.com');
