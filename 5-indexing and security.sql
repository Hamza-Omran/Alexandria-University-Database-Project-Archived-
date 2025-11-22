-- ==============================================
-- AlexandriaUniversity Database Optimization Script (Safe Version)
-- Includes Indexing, Roles, Sequences, RLS, DDM, and Performance Tests
-- ==============================================

-- ==============================================
-- 1. Safe Index Creation
-- ==============================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_students_email' AND object_id = OBJECT_ID('students'))
    CREATE INDEX IX_students_email ON students(email);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_students_department' AND object_id = OBJECT_ID('students'))
    CREATE INDEX IX_students_department ON students(DepartmentID);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_students_name' AND object_id = OBJECT_ID('students'))
    CREATE INDEX IX_students_name ON students(last_name, first_name);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_enrollments_student' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_enrollments_student ON enrollments(student_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_enrollments_course' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_enrollments_course ON enrollments(available_course_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_enrollments_status' AND object_id = OBJECT_ID('enrollments'))
    CREATE INDEX IX_enrollments_status ON enrollments(StatusID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_available_courses_course' AND object_id = OBJECT_ID('available_courses'))
    CREATE INDEX IX_available_courses_course ON available_courses(course_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_available_courses_instructor' AND object_id = OBJECT_ID('available_courses'))
    CREATE INDEX IX_available_courses_instructor ON available_courses(instructor_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_available_courses_semester' AND object_id = OBJECT_ID('available_courses'))
    CREATE INDEX IX_available_courses_semester ON available_courses(semester, year);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_courses_code' AND object_id = OBJECT_ID('courses'))
    CREATE INDEX IX_courses_code ON courses(course_code);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_courses_name' AND object_id = OBJECT_ID('courses'))
    CREATE INDEX IX_courses_name ON courses(course_name);

-- ==============================================
-- 2. Safe Sequence Creation
-- ==============================================
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'StudentIDSeq')
BEGIN
    CREATE SEQUENCE StudentIDSeq
        START WITH 1000
        INCREMENT BY 1;
END;

-- Sample table using the sequence
IF OBJECT_ID('sample_students') IS NULL
BEGIN
    CREATE TABLE sample_students (
        student_id INT PRIMARY KEY DEFAULT NEXT VALUE FOR StudentIDSeq,
        first_name VARCHAR(50),
        last_name VARCHAR(50)
    );
END;

-- ==============================================
-- 3. Row-Level Security
-- ==============================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Security')
    EXEC('CREATE SCHEMA Security');
GO

IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'studentFilter')
    DROP SECURITY POLICY Security.studentFilter;
GO

IF OBJECT_ID('Security.fn_securitypredicate') IS NOT NULL
    DROP FUNCTION Security.fn_securitypredicate;
GO

CREATE FUNCTION Security.fn_securitypredicate(@student_id AS INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE CAST(SESSION_CONTEXT(N'student_id') AS INT) = @student_id
   OR USER_NAME() IN ('admin1', 'registrar_jones');
GO

CREATE SECURITY POLICY Security.studentFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(student_id)
ON dbo.students
WITH (STATE = ON);
GO

-- ==============================================
-- 4. Dynamic Data Masking
-- ==============================================
ALTER TABLE students ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE students ALTER COLUMN date_of_birth ADD MASKED WITH (FUNCTION = 'default()');

-- ==============================================
-- 5. Performance Testing
-- ==============================================
DECLARE @StartTime DATETIME, @EndTime DATETIME;

-- Without index
SET @StartTime = GETDATE();
SELECT * FROM enrollments WHERE student_id = 5;
SET @EndTime = GETDATE();
PRINT 'Time without index: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';

-- With index
SET @StartTime = GETDATE();
SELECT * FROM enrollments WITH(INDEX(IX_enrollments_student)) WHERE student_id = 5;
SET @EndTime = GETDATE();
PRINT 'Time with index: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';

-- Join performance
SET @StartTime = GETDATE();
SELECT s.student_id, s.first_name, s.last_name, COUNT(e.enrollment_id)
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name;
SET @EndTime = GETDATE();
PRINT 'Join query time: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';

-- ==============================================
-- 6. Roles and Permissions (Safe Version)
-- ==============================================
-- Roles
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentRole') CREATE ROLE StudentRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'InstructorRole') CREATE ROLE InstructorRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole') CREATE ROLE AdminRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RegistrarRole') CREATE ROLE RegistrarRole;

-- Permissions (optional views/procs should exist first)
-- Use conditional checks or defer until those objects are created
-- GRANT SELECT ON vw_StudentProgress TO StudentRole;
-- GRANT EXECUTE ON sp_EnrollStudentWithSeatCheck TO StudentRole;
-- GRANT EXECUTE ON sp_UnenrollStudent TO StudentRole;
-- GRANT SELECT ON vw_CourseSeatAvailability TO InstructorRole;
-- GRANT SELECT ON vw_InstructorLoad TO InstructorRole;
-- GRANT UPDATE ON enrollments(grade) TO InstructorRole;
-- GRANT EXECUTE ON sp_UpdateStudentGrade TO InstructorRole;

GRANT SELECT, INSERT, UPDATE ON students TO RegistrarRole;
GRANT SELECT, INSERT, UPDATE ON enrollments TO RegistrarRole;
GRANT EXECUTE ON SCHEMA :: dbo TO RegistrarRole;

GRANT CONTROL ON DATABASE::AlexandriaUniversity TO AdminRole;

-- Logins and Users
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'student1') CREATE LOGIN student1 WITH PASSWORD = 'SecurePassword123!';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'prof_smith') CREATE LOGIN prof_smith WITH PASSWORD = 'Professor123!';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'registrar_jones') CREATE LOGIN registrar_jones WITH PASSWORD = 'RegistrarSecure!';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin1') CREATE LOGIN admin1 WITH PASSWORD = 'AdminSuperSecure!';

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'student1') CREATE USER student1 FOR LOGIN student1;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'prof_smith') CREATE USER prof_smith FOR LOGIN prof_smith;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'registrar_jones') CREATE USER registrar_jones FOR LOGIN registrar_jones;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin1') CREATE USER admin1 FOR LOGIN admin1;

-- Assign users to roles
ALTER ROLE StudentRole ADD MEMBER student1;
ALTER ROLE InstructorRole ADD MEMBER prof_smith;
ALTER ROLE RegistrarRole ADD MEMBER registrar_jones;
ALTER ROLE AdminRole ADD MEMBER admin1;

-- Optional: Revoke access as needed
REVOKE SELECT ON students FROM InstructorRole;
REVOKE SELECT ON enrollments FROM InstructorRole;
REVOKE UPDATE ON enrollments FROM StudentRole;
-- ==============================================
-- END OF SCRIPT
-- ==============================================
