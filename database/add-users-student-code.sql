-- Optional: external student / roll id for admin student list (also added at runtime by the app if missing).
USE online_exam_system;

ALTER TABLE users ADD COLUMN student_code VARCHAR(64) NULL AFTER full_name;
