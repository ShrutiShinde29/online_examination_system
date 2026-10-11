USE online_exam_system;

-- Before running, check duplicates:
-- 1) Questions duplicates (same exam + text + type)
SELECT exam_id, question_text, question_type, COUNT(*) AS cnt
FROM questions
GROUP BY exam_id, question_text, question_type
HAVING COUNT(*) > 1;

-- 2) Options duplicates (same question + option text)
SELECT question_id, option_text, COUNT(*) AS cnt
FROM options
GROUP BY question_id, option_text
HAVING COUNT(*) > 1;

-- Add DB-level protection (run once after cleaning duplicates)
ALTER TABLE questions
ADD UNIQUE KEY uq_exam_question (exam_id, question_text(255), question_type);

ALTER TABLE options
ADD UNIQUE KEY uq_question_option (question_id, option_text(255));

-- Helpful indexes
ALTER TABLE results ADD INDEX idx_results_exam_student (exam_id, student_id);
ALTER TABLE enrollments ADD UNIQUE KEY uq_enroll_student_course (student_id, course_id);

