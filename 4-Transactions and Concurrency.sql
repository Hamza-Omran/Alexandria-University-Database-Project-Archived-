use AlexandriaUniversity;

--------------------------------------------------------------------------
--Basic Transaction Examples
--------------------------------------------------------------------------

--Simple Transaction with COMMIT

BEGIN TRANSACTION;
BEGIN TRY
    -- Update student department
    UPDATE students SET DepartmentID = 4 WHERE student_id = 1;
    --logging has happened successsfully automatically

    COMMIT TRANSACTION;
    PRINT 'Department transfer completed successfully';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error in department transfer: ' + ERROR_MESSAGE();
END CATCH


--Transaction with SAVEPOINT and ROLLBACK

BEGIN TRANSACTION;
BEGIN TRY
    -- Check available seats will happen automatically

    -- Create enrollment
    INSERT INTO enrollments (student_id, available_course_id, enrollment_date, StatusID)
    VALUES (1, 1, GETDATE(), 8); -- StatusID 8 = Registered
    
    SAVE TRANSACTION EnrollmentCreated;
    
    -- Update available seats will happen automatically
    
    -- Log enrollment activity happened automatically
    
	-- This will cause a divide-by-zero error
    DECLARE @x INT = 1 / 0;


    COMMIT TRANSACTION;
    PRINT 'Enrollment completed successfully';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION EnrollmentCreated;
    PRINT 'enrollment saved by the save point: ';
END CATCH


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--2. Concurrency Problem Demonstrations
--------------------------------------------------------------------------

--Dirty Read Problem

-- Connection 1 (Admin updating grade)
BEGIN TRANSACTION;
UPDATE enrollments SET grade = 90 WHERE enrollment_id = 1;

-- Connection 2 (Student checking grade with READ UNCOMMITTED)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT grade FROM enrollments WHERE enrollment_id = 1; -- read uncommitted 90
COMMIT TRANSACTION;

-- Connection 1
ROLLBACK TRANSACTION; --grade change is undone but student read the 90



--Lost Update Problem


--professor adjust the grade
BEGIN TRANSACTION;
SELECT grade FROM enrollments WHERE enrollment_id = 1; --read 85

--admin adjusting grade
BEGIN TRANSACTION;
SELECT grade FROM enrollments WHERE enrollment_id = 1; --reads 85
UPDATE enrollments SET grade = 90 WHERE enrollment_id = 1;
COMMIT TRANSACTION;

--then the professor changes will be merged
UPDATE enrollments SET grade = grade + 5 WHERE enrollment_id = 1; --become 95 instead of 90
COMMIT TRANSACTION;

--select * from enrollments

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--3-Isolation Level
--------------------------------------------------------------------------

--READ UNCOMMITTED (Dirty reads allowed)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
--sees only committed data
SELECT * FROM students WHERE student_id = 1;
-- Another transaction can update this student after our read
COMMIT TRANSACTION;


--READ COMMITTED (Default - prevents dirty reads)

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
--current enrollments for a course
SELECT COUNT(*) as 'Registered Count' FROM enrollments 
WHERE available_course_id = 1 AND StatusID = 8;

-- another transactions can't modify enrollments for this record until we commit

COMMIT TRANSACTION;

--REPEATABLE READ (Prevents non-repeatable reads) ---->>> no other transaction can modify or delete rows you read until you finish your transaction.

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT grade FROM Enrollments WHERE enrollment_id = 1; --locks the row
-- another transactions can't modify this row until we commit
SELECT grade FROM Enrollments WHERE enrollment_id = 1; -- will be the same
COMMIT TRANSACTION;

--SERIALIZABLE (Highest isolation)
--No other transaction can Modify these rows , Delete them nor insert new rows have relation to this record

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;
-- Check available seats
DECLARE @seats INT = (SELECT Seats FROM available_courses WHERE available_course_id = 1);

IF @seats > 0
BEGIN
    -- Enroll student
    INSERT INTO enrollments (student_id, available_course_id, enrollment_date, StatusID)
    VALUES (2, 1, GETDATE(), 8);
    
    -- Update seat count
    UPDATE available_courses SET Seats = Seats - 1 WHERE available_course_id = 1;
END

COMMIT TRANSACTION;

-- This prevents concurrent enrollments from exceeding seat capacity




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--4 SQL Server Concurrency Solutions
--------------------------------------------------------------------------

--Pessimistic Locking for Grade Updates

--BEGIN TRANSACTION;
-- Lock the enrollment row for update
SELECT * FROM enrollments WITH (UPDLOCK) WHERE enrollment_id = 1;

-- Now we can safely update the grade
UPDATE enrollments SET grade = 95 WHERE enrollment_id = 1;

-- Log the grade change happened automatically

COMMIT TRANSACTION;

----------------------------------------------------------------------


--Deadlock Handling

DECLARE @retryCount INT = 0;
DECLARE @maxRetries INT = 3;

Declare @StudentID INT=17
Declare @AvailableCourseID INT = 1
Declare @PerformedBy VARCHAR(100) = 'Hamza'

WHILE @retryCount < @maxRetries
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
      
		
		UPDATE enrollments SET grade = 20 WHERE enrollment_id = 1;
		-- COMMIT; (Don't commit yet)
		-- Wait a bit, then try to lock tableB
		WAITFOR DELAY '00:00:05';
		UPDATE students SET first_name = 'hamza2'  WHERE student_id = 1;


        COMMIT TRANSACTION;
        BREAK; -- Success, exit loop
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 1205 -- Deadlock
        BEGIN
            ROLLBACK TRANSACTION;
            SET @retryCount = @retryCount + 1;
            IF @retryCount = @maxRetries
                PRINT 'Maximum retries reached. Enrollment failed.';
            ELSE
                PRINT 'Deadlock occurred. Retrying...';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: ' + ERROR_MESSAGE();
            BREAK;
        END
    END CATCH
END



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- adding some constraints

go;

CREATE TRIGGER trg_CheckMaxEnrollments
ON enrollments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT student_id
        FROM (
            SELECT student_id, COUNT(*) AS course_count
            FROM enrollments
            WHERE StatusID = 8 -- Active, Passed, Registered statuses
              AND student_id IN (SELECT student_id FROM inserted)
            GROUP BY student_id
            HAVING COUNT(*) > 7
        ) AS over_enrolled
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('A student cannot enroll in more than 7 courses', 16, 1);
    END
END;
GO


CREATE TRIGGER trg_ManageCourseSeats
ON enrollments
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	begin transaction
    -- Handle new enrollments (decrease seats)
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        UPDATE ac
        SET ac.Seats = ac.Seats - 1
        FROM available_courses ac
        JOIN inserted i ON ac.available_course_id = i.available_course_id;
    END
    
    -- Handle unenrollments (increase seats)
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE ac
        SET ac.Seats = ac.Seats + 1
        FROM available_courses ac
        JOIN deleted d ON ac.available_course_id = d.available_course_id
        LEFT JOIN inserted i ON d.enrollment_id = i.enrollment_id
        WHERE i.enrollment_id IS NULL; -- Only if not also in inserted (update case)
    END

	commit;
	COMMIT TRANSACTION;
END;
GO

CREATE FUNCTION dbo.CheckAvailableSeats(@AvailableCourseID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @SeatsAvailable BIT = 0;
    
    SELECT @SeatsAvailable = CASE WHEN Seats > 0 THEN 1 ELSE 0 END
    FROM available_courses
    WHERE available_course_id = @AvailableCourseID;
    
    RETURN @SeatsAvailable;
END;
GO

ALTER TABLE enrollments
ADD CONSTRAINT CHK_SeatsAvailable
CHECK (dbo.CheckAvailableSeats(available_course_id) = 1);


go;
