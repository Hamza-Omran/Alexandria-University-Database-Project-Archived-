-- Indexes for students table
CREATE INDEX IX_students_email ON students(email);
CREATE INDEX IX_students_department ON students(DepartmentID);
CREATE INDEX IX_students_name ON students(last_name, first_name);

-- Indexes for enrollments table
CREATE INDEX IX_enrollments_student ON enrollments(student_id);
CREATE INDEX IX_enrollments_course ON enrollments(available_course_id);
CREATE INDEX IX_enrollments_status ON enrollments(StatusID);

-- Indexes for available_courses table
CREATE INDEX IX_available_courses_course ON available_courses(course_id);
CREATE INDEX IX_available_courses_instructor ON available_courses(instructor_id);
CREATE INDEX IX_available_courses_semester ON available_courses(semester, year);

-- Indexes for courses table
CREATE INDEX IX_courses_code ON courses(course_code);
CREATE INDEX IX_courses_name ON courses(course_name);

--------------------------------------------------------------

-- Without index (example)
SET STATISTICS TIME ON;
SELECT * FROM students WHERE email = 'john.doe@example.com';
SET STATISTICS TIME OFF;
-- Note the execution time

-- With index
SET STATISTICS TIME ON;
SELECT * FROM students WITH(INDEX(IX_students_email)) 
WHERE email = 'john.doe@example.com';
SET STATISTICS TIME OFF;
-- Compare execution times


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------



-- Create roles
CREATE ROLE StudentRole;
CREATE ROLE InstructorRole;
CREATE ROLE AdminRole;
CREATE ROLE RegistrarRole;

-------------------------------------------------------------------------------
-- Student permissions
GRANT SELECT ON vw_StudentProgress TO StudentRole;
GRANT EXECUTE ON sp_EnrollStudentWithSeatCheck TO StudentRole;
GRANT EXECUTE ON sp_UnenrollStudent TO StudentRole;

-- Instructor permissions
GRANT SELECT ON vw_CourseSeatAvailability TO InstructorRole;
GRANT SELECT ON vw_InstructorLoad TO InstructorRole;
GRANT UPDATE ON enrollments(grade) TO InstructorRole;
GRANT EXECUTE ON sp_UpdateStudentGrade TO InstructorRole;

-- Registrar permissions
GRANT SELECT, INSERT, UPDATE ON students TO RegistrarRole;
GRANT SELECT, INSERT, UPDATE ON enrollments TO RegistrarRole;
GRANT EXECUTE ON ALL PROCEDURES TO RegistrarRole;

-- Admin permissions
GRANT CONTROL ON DATABASE::AlexandriaUniversity TO AdminRole;

-----------------------------------------------------------------------------------

-- Create login
CREATE LOGIN student1 WITH PASSWORD = 'SecurePassword123';
CREATE LOGIN prof_smith WITH PASSWORD = 'Professor123';
CREATE LOGIN registrar_jones WITH PASSWORD = 'RegistrarSecure!';
CREATE LOGIN admin1 WITH PASSWORD = 'AdminSuperSecure!';

-- Create database users
CREATE USER student1 FOR LOGIN student1;
CREATE USER prof_smith FOR LOGIN prof_smith;
CREATE USER registrar_jones FOR LOGIN registrar_jones;
CREATE USER admin1 FOR LOGIN admin1;

-- Assign roles
ALTER ROLE StudentRole ADD MEMBER student1;
ALTER ROLE InstructorRole ADD MEMBER prof_smith;
ALTER ROLE RegistrarRole ADD MEMBER registrar_jones;
ALTER ROLE AdminRole ADD MEMBER admin1;

----------------------------------------------------------------------------

-- Revoke direct table access from instructors
REVOKE SELECT ON students FROM InstructorRole;
REVOKE SELECT ON enrollments FROM InstructorRole;

-- Revoke update permission from students
REVOKE UPDATE ON enrollments FROM StudentRole;

-------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------



-- Example from your existing schema:
CREATE TABLE [students] (
  [student_id] int PRIMARY KEY IDENTITY(1, 1),
  ...
);

----------------------------------------------------------

-- Create sequence
CREATE SEQUENCE StudentIDSeq
    START WITH 1000
    INCREMENT BY 1;

-- Table using sequence
CREATE TABLE sample_students (
    student_id INT PRIMARY KEY DEFAULT NEXT VALUE FOR StudentIDSeq,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

---------------------------------------------------------

-- Performance test script
DECLARE @StartTime DATETIME, @EndTime DATETIME;

-- Test without index
SET @StartTime = GETDATE();
SELECT * FROM enrollments WHERE student_id = 5;
SET @EndTime = GETDATE();
PRINT 'Time without index: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';

-- Test with index
SET @StartTime = GETDATE();
SELECT * FROM enrollments WITH(INDEX(IX_enrollments_student)) WHERE student_id = 5;
SET @EndTime = GETDATE();
PRINT 'Time with index: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';

-- Test join performance
SET @StartTime = GETDATE();
SELECT s.student_id, s.first_name, s.last_name, COUNT(e.enrollment_id)
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name;
SET @EndTime = GETDATE();
PRINT 'Join query time: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ms';




-------------------------------------------------------------------------------------------------------


-- Create security predicate for students to only see their own records
CREATE SCHEMA Security;
GO

CREATE FUNCTION Security.fn_securitypredicate(@student_id AS INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @student_id = USER_ID() OR USER_NAME() IN ('admin1', 'registrar_jones');
GO

CREATE SECURITY POLICY Security.studentFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(student_id)
ON students;


-------------------------------------------------------------------------------------------------------------

-- Add masking to sensitive columns
ALTER TABLE students
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE students
ALTER COLUMN date_of_birth ADD MASKED WITH (FUNCTION = 'default()');
