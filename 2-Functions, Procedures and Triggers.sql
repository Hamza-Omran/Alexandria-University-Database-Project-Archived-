use AlexandriaUniversity;


										----------------------------------------
										----------------------------------------
										--  note you must run each one alone  --
										----------------------------------------
										----------------------------------------
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


--------------------------------------
--------------------------------------

CREATE TRIGGER trg_LogStudentChanges
ON students
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- For updates (INSERTED contains new values, DELETED contains old values)
    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO student_changes_log (
            student_id, first_name, last_name, email, 
            date_of_birth, gender, DepartmentID, 
            changed_at, action_type, change_reason, changed_by
        )
        SELECT 
            d.student_id, d.first_name, d.last_name, d.email,
            d.date_of_birth, d.gender, d.DepartmentID,
            GETDATE(), 'UPDATE', 'Record updated', SYSTEM_USER
        FROM DELETED d
        JOIN INSERTED i ON d.student_id = i.student_id;
    END
    -- For deletions (only DELETED table has data)
    ELSE
    BEGIN
        INSERT INTO student_changes_log (
            student_id, first_name, last_name, email, 
            date_of_birth, gender, DepartmentID, 
            changed_at, action_type, change_reason, changed_by
        )
        SELECT 
            student_id, first_name, last_name, email,
            date_of_birth, gender, DepartmentID,
            GETDATE(), 'DELETE', 'Record deleted', SYSTEM_USER
        FROM DELETED;
    END
END;


-------------------
-------------------

CREATE TRIGGER trg_LogEnrollmentActivity
ON enrollments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- For inserts
    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO enrollment_activity_log (
            enrollment_id, student_id, available_course_id,
            action_type, action_details, performed_at, performed_by
        )
        SELECT 
            i.enrollment_id, i.student_id, i.available_course_id,
            'INSERT', 'New enrollment created', GETDATE(), i.performed_by
        FROM INSERTED i;
    END
    
    -- For updates
    ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO enrollment_activity_log (
            enrollment_id, student_id, available_course_id,
            action_type, action_details, performed_at, performed_by
        )
        SELECT 
            i.enrollment_id, i.student_id, i.available_course_id,
            'UPDATE', 
            'Enrollment updated. Old grade: ' + ISNULL(CAST(d.grade AS VARCHAR), 'NULL') + 
            ', New grade: ' + ISNULL(CAST(i.grade AS VARCHAR), 'NULL') +
            ', Old status: ' + ISNULL(CAST(d.StatusID AS VARCHAR), 'NULL') +
            ', New status: ' + ISNULL(CAST(i.StatusID AS VARCHAR), 'NULL'),
            GETDATE(), 
            ISNULL(i.performed_by, SYSTEM_USER)
        FROM INSERTED i
        JOIN DELETED d ON i.enrollment_id = d.enrollment_id;
    END
    
    -- For deletions
    ELSE IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO enrollment_activity_log (
            enrollment_id, student_id, available_course_id,
            action_type, action_details, performed_at, performed_by
        )
        SELECT 
            d.enrollment_id, d.student_id, d.available_course_id,
            'DELETE', 'Enrollment deleted', GETDATE(), SYSTEM_USER
        FROM DELETED d;
    END
END;