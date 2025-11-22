use AlexandriaUniversity;


										----------------------------------------
										----------------------------------------
										--  note you must run each one alone  --
										----------------------------------------
										----------------------------------------

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

CREATE OR ALTER VIEW StudentProgress AS
SELECT 
    s.student_id,
    s.first_name + ' ' + s.last_name AS student_name,
    d.DepartmentName,
    COUNT(e.enrollment_id) AS courses_taken,
    AVG(CASE WHEN e.StatusID IN (1, 6) THEN e.grade ELSE NULL END) AS average_grade,
    STRING_AGG(CASE WHEN e.enrollment_id IS NOT NULL 
               THEN c.course_name + ' (' + CAST(e.grade AS NVARCHAR) + ')' 
               ELSE NULL END, ', ') AS course_details
FROM 
    students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN available_courses ac ON e.available_course_id = ac.available_course_id
LEFT JOIN courses c ON ac.course_id = c.course_id
GROUP BY 
    s.student_id, s.first_name, s.last_name, d.DepartmentName;

go;
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


CREATE VIEW InstructorLoad AS
SELECT 
    i.instructor_id,
    i.first_name + ' ' + i.last_name AS instructor_name,
    COUNT(ac.available_course_id) AS courses_teaching,
    SUM(ac.Seats) AS total_seats
FROM 
    instructors i
LEFT JOIN available_courses ac ON i.instructor_id = ac.instructor_id
WHERE ac.IsActive = 1
GROUP BY 
    i.instructor_id, i.first_name, i.last_name;

go;
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    s.first_name + ' ' + s.last_name AS student_name,
    c.course_name,
    e.grade
FROM 
    students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN available_courses ac ON e.available_course_id = ac.available_course_id
JOIN courses c ON ac.course_id = c.course_id
WHERE e.grade IS NOT NULL;

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    course_name,
    credit_hours
FROM 
    courses
WHERE 
    course_id IN (
        SELECT course_id 
        FROM available_courses 
        WHERE semester = 'Fall' AND year = 2025
    );

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    d.DepartmentName,
    COUNT(s.student_id) AS student_count
FROM 
    Departments d
LEFT JOIN students s ON d.DepartmentID = s.DepartmentID
GROUP BY 
    d.DepartmentName
HAVING 
    COUNT(s.student_id) > 0;

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    AVG(grade) AS avg_grade,
    MAX(grade) AS max_grade,
    MIN(grade) AS min_grade
FROM 
    enrollments
WHERE 
    StatusID = 1; -- Passed courses

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    student_id,
    student_name,
    average_grade,
    RANK() OVER (ORDER BY average_grade DESC) AS rank
FROM (
    SELECT 
        s.student_id,
        s.first_name + ' ' + s.last_name AS student_name,
        AVG(e.grade) AS average_grade
    FROM 
        students s
    JOIN 
        enrollments e ON s.student_id = e.student_id
    WHERE 
        e.StatusID IN (1, 6) -- Success or Passed
    GROUP BY 
        s.student_id, s.first_name, s.last_name
    HAVING 
        COUNT(e.enrollment_id) >= 1
) AS student_grades
WHERE 
    average_grade > 80
ORDER BY 
    average_grade DESC;

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

SELECT 
    d.DepartmentName,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(e.enrollment_id) AS total_enrollments,
    AVG(e.grade) AS average_grade,
    SUM(c.credit_hours) AS total_credit_hours
FROM 
    Departments d
JOIN 
    students s ON d.DepartmentID = s.DepartmentID
JOIN 
    enrollments e ON s.student_id = e.student_id
JOIN 
    available_courses ac ON e.available_course_id = ac.available_course_id
JOIN 
    courses c ON ac.course_id = c.course_id
WHERE 
    e.StatusID IN (1, 6, 8) -- Success, Passed, Registered
GROUP BY 
    d.DepartmentName
HAVING 
    COUNT(e.enrollment_id) > 1
ORDER BY 
    total_enrollments DESC;

-----------------------------------------------------------------------------------------------------------------------------------
-- Queries
-----------------------------------------------------------------------------------------------------------------------------------

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

	--------------------------------------------------

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

	----------------------------------------------------------

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


		-------------------------------------------------------
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

-------------------------------------------------------
SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name
FROM 
    Students s
WHERE 
    (SELECT COUNT(*) 
     FROM Enrollments e 
     WHERE e.student_id = s.student_id) > 0;

--------------------------------------------------