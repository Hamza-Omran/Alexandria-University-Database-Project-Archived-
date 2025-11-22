use AlexandriaUniversity;

CREATE TABLE [Departments] (
  [DepartmentID] int PRIMARY KEY IDENTITY(1, 1),
  [DepartmentName] nvarchar(100)
)
Go

CREATE TABLE [Enrollment_Status] (
  [StatusID] int PRIMARY KEY,
  [status] varchar(20)
)
Go

CREATE TABLE [students] (
  [student_id] int PRIMARY KEY IDENTITY(1, 1),
  [first_name] varchar(50),
  [last_name] varchar(50),
  [email] varchar(100) UNIQUE,
  [date_of_birth] date,
  [gender] varchar(10),
  [DepartmentID] int,
  FOREIGN KEY ([DepartmentID]) REFERENCES [Departments]([DepartmentID])
)
GO

CREATE TABLE [student_changes_log] (
  [log_id] int PRIMARY KEY IDENTITY(1, 1),
  [student_id] int,
  [first_name] varchar(50),
  [last_name] varchar(50),
  [email] varchar(100),
  [date_of_birth] date,
  [gender] varchar(10),
  [DepartmentID] int,
  [changed_at] datetime,
  [action_type] varchar(10),
  [change_reason] varchar(100),
  [changed_by] varchar(100),
  FOREIGN KEY ([student_id]) REFERENCES [students] ([student_id])
)
GO

CREATE TABLE [instructors] (
  [instructor_id] int PRIMARY KEY IDENTITY(1, 1),
  [first_name] varchar(50),
  [last_name] varchar(50),
  [email] varchar(100) UNIQUE,
  [DepartmentID] int,
  FOREIGN KEY ([DepartmentID]) REFERENCES [Departments] ([DepartmentID])
)
GO

CREATE TABLE [courses] (
  [course_id] int PRIMARY KEY IDENTITY(1, 1),
  [course_code] varchar(10) UNIQUE,
  [course_name] varchar(100),
  [credit_hours] int,
  [description] text
)
GO

CREATE TABLE [available_courses] (
  [available_course_id] int PRIMARY KEY IDENTITY(1, 1),
  [course_id] int,
  [instructor_id] int,
  [semester] varchar(10),
  [year] int,
  [Seats] int,
  [IsActive] bit,
  [schedule] varchar(50),
  FOREIGN KEY ([course_id]) REFERENCES [courses] ([course_id]),
  FOREIGN KEY ([instructor_id]) REFERENCES [instructors] ([instructor_id])
)
GO

CREATE TABLE [enrollments] (
  [enrollment_id] int PRIMARY KEY IDENTITY(1, 1),
  [student_id] int,
  [available_course_id] int,
  [enrollment_date] date,
  [grade] int,
  [performed_by] varchar(100),
  [performed_at] datetime,
  [StatusID] int,
  FOREIGN KEY ([StatusID]) REFERENCES [Enrollment_Status] ([StatusID]),
  FOREIGN KEY ([student_id]) REFERENCES [students] ([student_id]),
  FOREIGN KEY ([available_course_id]) REFERENCES [available_courses] ([available_course_id])
)
GO

CREATE TABLE [enrollment_activity_log] (
  [log_id] int PRIMARY KEY IDENTITY(1, 1),
  [enrollment_id] int,
  [student_id] int,
  [available_course_id] int,
  [action_type] varchar(20),
  [action_details] text,
  [performed_at] datetime,
  [performed_by] varchar(100),
  FOREIGN KEY ([enrollment_id]) REFERENCES [enrollments] ([enrollment_id])
)
GO


------------------------------------------------------------------------------------------------------------------------------------------------------
-- inserting some examples
------------------------------------------------------------------------------------------------------------------------------------------------------

--Departments

INSERT INTO Departments (DepartmentName) VALUES (N'Computer Science');
INSERT INTO Departments (DepartmentName) VALUES (N'Information Systems');
INSERT INTO Departments (DepartmentName) VALUES (N'Data Science');
INSERT INTO Departments (DepartmentName) VALUES (N'AI');


--students

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('John', 'Doe', 'john.doe@example.com', '2000-05-15', 'Male', 1);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Jane', 'Smith', 'jane.smith@example.com', '1999-08-21', 'Female', 2);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Michael', 'Brown', 'michael.brown@example.com', '2001-02-10', 'Male', 3);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Emily', 'Davis', 'emily.davis@example.com', '1998-11-05', 'Female', 4);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('James', 'Wilson', 'james.wilson@example.com', '2000-12-25', 'Male', 4);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Sophia', 'Taylor', 'sophia.taylor@example.com', '1999-03-16', 'Female', 4);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('David', 'Moore', 'david.moore@example.com', '2000-01-30', 'Male', 3);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Olivia', 'Jackson', 'olivia.jackson@example.com', '1998-07-14', 'Female', 2);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('William', 'Martin', 'william.martin@example.com', '2001-06-09', 'Male', 2);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Isabella', 'Lee', 'isabella.lee@example.com', '1999-04-22', 'Female', 1);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Ethan', 'Harris', 'ethan.harris@example.com', '2000-09-12', 'Male', 3);

INSERT INTO students (first_name, last_name, email, date_of_birth, gender, DepartmentID) 
VALUES ('Mia', 'Clark', 'mia.clark@example.com', '2001-01-18', 'Female', 1);


-- Instructors

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Alan', 'Williams', 'alan.williams@example.com', 1);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Barbara', 'Johnson', 'barbara.johnson@example.com', 2);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Prof. Charles', 'Roberts', 'charles.roberts@example.com', 3);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Diane', 'Anderson', 'diane.anderson@example.com', 4);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Prof. Edward', 'Miller', 'edward.miller@example.com', 5);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Fiona', 'Hernandez', 'fiona.hernandez@example.com', 6);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Prof. George', 'Martinez', 'george.martinez@example.com', 7);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Helen', 'King', 'helen.king@example.com', 8);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Prof. Ian', 'Lee', 'ian.lee@example.com', 9);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Jack', 'Perez', 'jack.perez@example.com', 10);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Prof. Karen', 'Gonzalez', 'karen.gonzalez@example.com', 11);

INSERT INTO instructors (first_name, last_name, email, DepartmentID) 
VALUES ('Dr. Laura', 'Wilson', 'laura.wilson@example.com', 12);


-- courses

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('CS101', 'Introduction to Computer Science', 3, 'Basic principles of computer science.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('CS102', 'Data Structures', 3, 'Introduction to data structures.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('CS201', 'Algorithms', 4, 'Advanced algorithms and their analysis.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('IS101', 'Information Systems', 3, 'Basics of information systems.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('IS102', 'Database Management Systems', 4, 'Introduction to databases and SQL.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('MATH101', 'Calculus I', 4, 'Introduction to calculus.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('MATH102', 'Linear Algebra', 3, 'Introduction to matrix operations and vector spaces.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('PHY101', 'Physics I', 4, 'Introduction to mechanics and thermodynamics.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('BIO101', 'Biology I', 3, 'Basic principles of biology.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('CHEM101', 'Chemistry I', 3, 'Introduction to chemistry.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('ENG101', 'English Literature', 3, 'Study of English literary works.');

INSERT INTO courses (course_code, course_name, credit_hours, description) 
VALUES ('ECO101', 'Microeconomics', 3, 'Introduction to microeconomics and market theory.');


--Available_Courses

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (1, 1, 'Fall', 2025, 30, 1, 'MWF 10:00-11:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (2, 2, 'Spring', 2025, 25, 1, 'TTh 9:00-10:30');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (3, 3, 'Fall', 2025, 35, 1, 'MWF 11:00-12:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (4, 4, 'Spring', 2025, 40, 1, 'TTh 10:00-11:30');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (5, 5, 'Fall', 2025, 30, 1, 'MWF 9:00-10:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (6, 6, 'Spring', 2025, 25, 1, 'TTh 1:00-2:30');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (7, 7, 'Fall', 2025, 50, 1, 'MWF 12:00-1:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (8, 8, 'Spring', 2025, 30, 1, 'TTh 2:00-3:30');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (9, 9, 'Fall', 2025, 40, 1, 'MWF 8:00-9:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (10, 10, 'Spring', 2025, 35, 1, 'TTh 3:00-4:30');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (11, 11, 'Fall', 2025, 20, 1, 'MWF 1:00-2:00');

INSERT INTO available_courses (course_id, instructor_id, semester, year, Seats, IsActive, schedule)
VALUES (12, 12, 'Spring', 2025, 45, 1, 'TTh 4:00-5:30');

-- Enrollment_Status

INSERT INTO Enrollment_Status (StatusID, status) VALUES
(1, 'Success'),
(2, 'Fail'),
(3, 'Withdraw'),
(4, 'Forced Withdraw'),
(5, 'Withdraw Not Attend'),
(6, 'Passed'),
(7, 'Military Withdraw'),
(8, 'Registered');


-- enrollements

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (1, 1, '2025-09-01', 85, 'admin1', '2025-09-01', 8);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (2, 2, '2025-09-01', 90, 'admin2', '2025-09-01', 8);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (3, 3, '2025-09-01', 88, 'admin3', '2025-09-01', 8);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (4, 4, '2025-09-01', 92, 'admin4', '2025-09-01', 8);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (5, 5, '2025-09-01', 80, 'admin5', '2025-09-01', 6);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (6, 6, '2025-09-01', 95, 'admin6', '2025-09-01', 5);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (7, 7, '2025-09-01', 70, 'admin7', '2025-09-01', 1);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (8, 8, '2025-09-01', 65, 'admin8', '2025-09-01', 1);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (9, 9, '2025-09-01', 77, 'admin9', '2025-09-01', 1);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (10, 10, '2025-09-01', 89, 'admin10', '2025-09-01', 1);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (11, 11, '2025-09-01', 75, 'admin11', '2025-09-01', 1);

INSERT INTO enrollments (student_id, available_course_id, enrollment_date, grade, performed_by, performed_at, StatusID)
VALUES (12, 12, '2025-09-01', 85, 'admin12', '2025-09-01', 1);

-----------------------------------
-- showing the tables
-----------------------------------
  select * from available_courses;
  select * from courses;
  select * from Departments;
  select * from Enrollment_Status;
  select * from enrollments;
  select * from instructors;
  select * from students;



-----------------------------------------------------------------------------------------------------------------------------------
-- another queries
-----------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------------------
-- functions
-----------------------------------------------------------------------------------------------------------------------------------
Go

CREATE FUNCTION dbo.GetCourseNameByID (@course_id INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @course_name VARCHAR(100)

    SELECT @course_name = course_name
    FROM courses
    WHERE course_id = @course_id

    RETURN @course_name
END


Go
---------------------------------
---------------------------------
CREATE FUNCTION dbo.GetCourseIDByEnrollment (@available_course_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @course_id INT
    
    SELECT @course_id = course_id
    FROM available_courses
    WHERE available_course_id = @available_course_id
    
    RETURN @course_id
END
GO

GO

---------------------------------
---------------------------------

CREATE PROCEDURE dbo.RegisterStudentInCourse
    @StudentID INT,
    @AvailableCourseID INT,  -- This should actually be available_course_id based on your table
    @Message NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if the student is already enrolled in this available course
        IF EXISTS (
            SELECT 1 
            FROM Enrollments
            WHERE student_id = @StudentID 
              AND available_course_id = @AvailableCourseID
              AND StatusID = 1  -- Assuming 1 means active enrollment
        )
        BEGIN
            SET @Message = N'The student is already enrolled in this course.';  
            RETURN;
        END

        -- Check if the available course exists
        IF NOT EXISTS (
            SELECT 1 
            FROM available_courses 
            WHERE available_course_id = @AvailableCourseID
        )
        BEGIN
            SET @Message = N'The specified course does not exist.';
            RETURN;
        END

        -- Enroll the student
        INSERT INTO Enrollments (
            student_id,
            available_course_id,
            enrollment_date,
            StatusID,
            performed_by,
            performed_at
        )
        VALUES (
            @StudentID,
            @AvailableCourseID,
            GETDATE(),
            8,  -- 8 means registered
            SYSTEM_USER,  -- or pass a specific user ID
            GETDATE()
        )

        SET @Message = N'The student has been successfully enrolled.'; 
    END TRY
    BEGIN CATCH
        SET @Message = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END

go;

-----------
------------


CREATE FUNCTION GetInstructorNameByEnrollmentID (@EnrollmentID INT)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @InstructorName VARCHAR(200)

    SELECT @InstructorName = i.first_name + ' ' + i.last_name
    FROM enrollments e
    JOIN available_courses ac ON e.available_course_id = ac.available_course_id
    JOIN instructors i ON ac.instructor_id = i.instructor_id
    WHERE e.enrollment_id = @EnrollmentID

    RETURN @InstructorName
END


--------------------
--------------------
Go;

CREATE VIEW View_StudentCoursesWithGrades AS
SELECT 
    s.student_id,
    s.first_name + ' ' + s.last_name AS StudentFullName,
    c.course_name,
    ac.semester,
    ac.year,
    e.grade,
    e.enrollment_date,
	dbo.GetInstructorNameByEnrollmentID(e.enrollment_id) as InstructorName
FROM 
    students s
JOIN 
    enrollments e ON s.student_id = e.student_id
JOIN 
    available_courses ac ON e.available_course_id = ac.available_course_id
JOIN 
    courses c ON ac.course_id = c.course_id;


GO;

-------------------------------
-------------------------------
Go;

CREATE VIEW StudentProgress AS
SELECT 
    s.student_id,
    s.first_name AS StudentFirstName,
    s.last_name AS StudentLastName,
    STRING_AGG(c.course_name, ', ') AS CourseNames,
    STRING_AGG(CAST(e.grade AS NVARCHAR), ', ') AS Grades,
    AVG(CAST(e.grade AS FLOAT)) AS GPA
FROM 
    students s
JOIN 
    enrollments e ON s.student_id = e.student_id
JOIN 
    available_courses ac ON e.available_course_id = ac.available_course_id
JOIN 
    courses c ON ac.course_id = c.course_id
GROUP BY
    s.student_id, s.first_name, s.last_name;

go;



----------------------------------
-----------------------------------

go;
CREATE TRIGGER trg_PreventDuplicateEmail
ON students
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM students s
        JOIN inserted i ON s.email = i.email
    )
    BEGIN
        PRINT 'This email is already registered in the system. We cannot add the student.'
        RETURN
    END

    INSERT INTO students (
        first_name, last_name, email, date_of_birth, gender, DepartmentID
    )
    SELECT 
        first_name, last_name, email, date_of_birth, gender, DepartmentID
    FROM inserted
END

go;
-----------------------------------------------------------------------------------------------------------------------------------
-- Queries
-----------------------------------------------------------------------------------------------------------------------------------

-- استعلام الطلاب الذين لم يسجلوا في مادة معينة:
	SELECT 
    s.first_name AS StudentFirstName,
    s.last_name AS StudentLastName
FROM 
    Students s
WHERE 
    s.student_id NOT IN (
        SELECT e.student_id 
        FROM Enrollments e
        JOIN Courses c ON e.available_course_id = c.course_id
        WHERE c.course_code = 'IS102'
    );

-- استعلام للمدرسين الذين يدرسون أكثر من مادة:
     SELECT 
    i.first_name AS InstructorFirstName,
    i.last_name AS InstructorLastName,
    COUNT(ic.course_id) AS NumberOfCourses
FROM 
    available_courses ic
JOIN 
    Instructors i ON ic.instructor_id = i.instructor_id
GROUP BY 
    i.instructor_id, i.first_name, i.last_name
HAVING 
    COUNT(ic.course_id) > 1;


	-- استعلام للمواد التي بها أقل من 5 طلاب:
	SELECT 
    dbo.GetCourseNameByID(c.course_id) AS CourseName,
    COUNT(e.student_id) AS NumberOfStudents
FROM 
    Enrollments e
JOIN 
    available_courses c ON e.available_course_id = c.available_course_id
GROUP BY 
    c.course_id
HAVING 
    COUNT(e.student_id) < 5;
	
	
----------------------
----------------------
	
	SELECT 
    s.first_name AS StudentFirstName,
    s.last_name AS StudentLastName,
    dbo.GetCourseNameByID(c.course_id) AS CourseName,
    i.first_name AS InstructorFirstName,
    i.last_name AS InstructorLastName

FROM 
    Students s
JOIN 
    Enrollments e ON s.student_id = e.student_id
JOIN 
    available_courses c ON e.available_course_id = c.available_course_id
JOIN 
    Instructors i ON c.instructor_id = i.instructor_id;


	SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name,
    AVG(e.Grade) AS GPA
FROM 
    Students s
JOIN 
    Enrollments e ON s.student_id = e.student_id
GROUP BY 
    s.student_id, s.first_name, s.last_name
HAVING 
    AVG(e.Grade) > 3.5;


		
		SELECT 
    i.first_name AS InstructorFirstName,
    i.last_name AS InstructorLastName,
    dbo.GetCourseNameByID(c.course_id) AS CourseName,
    (SELECT COUNT(*) 
     FROM Enrollments e 
     WHERE e.available_course_id = c.available_course_id) AS StudentCount
FROM 
    Instructors i
JOIN 
    available_courses c ON i.instructor_id = c.instructor_id;

	-- استعلام للحصول على الطلاب الذين سجلوا في أكثر من مادة واحدة:
	SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name
FROM 
    Students s
WHERE 
    (SELECT COUNT(*) 
     FROM Enrollments e 
     WHERE e.student_id = s.student_id) > 1;

--  استعلام للحصول على المواد التي لم يتم تسجيل أي طالب فيها بعد:
	 SELECT 
    dbo.GetCourseNameByID(c.course_id) AS CourseName
FROM 
    available_courses c
WHERE 
    c.available_course_id NOT IN (SELECT DISTINCT available_course_id 
                       FROM Enrollments);