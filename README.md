# Online Examination and Evaluation System

Java web application for secure online exams with role-based dashboards, exam management, auto-MCQ grading, and instant result visibility.

## Implemented Core Modules
- Authentication and session management
- Admin dashboard analytics counters
- Admin management panel (users, courses, subjects, notifications)
- Teacher dashboard and exam creation
- Teacher exam lifecycle (draft, publish, close) + question bank management
- Student dashboard with course/subject filtered exams
- Timed exam attempt flow
- Exam autosave + resume from draft answers
- Attempt restriction (no re-attempt after evaluated submission)
- Auto-grading for MCQ questions
- Subjective grading (keyword-based NLP starter layer)
- Proctoring event pipeline (browser behavior events -> `proctoring_logs`)
- Subject-wise result panel
- Admin analytics (subject performance, top students, pass-rate)
- Teacher CSV report export for exam results
- Notification delivery workflow (broadcast to active users)
- Unified high-end UI theme for all modules (admin, teacher, student, manage pages)

## Deferred (Planned Next Phase)
- AI proctoring with OpenCV
- NLP-based subjective evaluation with OpenNLP
- Notification service (email/SMS)

## Stack
- Java Servlets + JSP + JSTL
- JDBC
- MySQL
- Maven (WAR packaging)

## Project Structure
- `src/main/java/com/oes/*` - DAO, servlets, models, utilities
- `src/main/resources/com/oes/config/db.properties` - DB config
- `src/main/webapp/views/*` - role-specific UI
- `database/seed-data.sql` - bootstrap role/user/course data

## Setup
1. Create schema using your SQL script.
2. Run `database/seed-data.sql`.
3. Update DB credentials in `src/main/resources/com/oes/config/db.properties`.
4. Build:
   - `mvn clean package`
5. Deploy generated WAR (`target/OnlineExaminationSystem.war`) in Tomcat 9+.

## Default Login Users (password: `123456`)
- Admin: `admin@oes.com`
- Teacher: `teacher@oes.com`
- Student: `student@oes.com`

## Notes
- Passwords are stored as SHA-256 hash in this starter implementation.
- Subjective answers are stored but awarded `0` until NLP/manual evaluator is integrated.
- AI proctoring should run as a separate service and write into `proctoring_logs`.
- Notification table script: `database/phase3-notifications.sql` (also auto-created by DAO if missing).
- Combined phase script: `database/phase4_phase5.sql`.
- Phase 6 currently integrates lightweight hooks/services for proctoring + NLP scoring without heavy OpenCV/OpenNLP runtime dependency.
