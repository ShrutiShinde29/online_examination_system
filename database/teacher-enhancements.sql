-- Teacher features: exam window, passing marks, result feedback, question bank, subject assignment.
-- The application also applies these changes automatically on first teacher/student load (ensureTeacherSchema).

USE online_exam_system;

ALTER TABLE exams ADD COLUMN passing_marks INT NULL;
ALTER TABLE exams ADD COLUMN available_from DATETIME NULL;
ALTER TABLE exams ADD COLUMN available_until DATETIME NULL;

ALTER TABLE results ADD COLUMN teacher_feedback TEXT NULL;

CREATE TABLE IF NOT EXISTS teacher_subjects (
  teacher_id BIGINT UNSIGNED NOT NULL,
  subject_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (teacher_id, subject_id),
  CONSTRAINT fk_ts_teacher FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_ts_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Optional: restrict teacher to specific subjects (if table is empty for a teacher, app shows all subjects).
-- INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES (2, 1);

CREATE TABLE IF NOT EXISTS question_bank (
  bank_question_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  subject_id BIGINT UNSIGNED NOT NULL,
  teacher_id BIGINT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  question_type VARCHAR(20) NOT NULL,
  marks INT NOT NULL,
  model_answer TEXT,
  expected_keywords VARCHAR(500),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_qb_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
  CONSTRAINT fk_qb_teacher FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS question_bank_options (
  bank_option_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  bank_question_id BIGINT UNSIGNED NOT NULL,
  option_text VARCHAR(500) NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_qbo_q FOREIGN KEY (bank_question_id) REFERENCES question_bank(bank_question_id) ON DELETE CASCADE
) ENGINE=InnoDB;
