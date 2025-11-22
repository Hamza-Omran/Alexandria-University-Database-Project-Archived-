use AlexandriaUniversity;

--------------------------------------------------------------------------
--Basic Transaction Examples
--------------------------------------------------------------------------

--Simple Transaction with COMMIT

BEGIN TRANSACTION;
-- Transfer funds between accounts
UPDATE Accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE Accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT TRANSACTION;



--Transaction with SAVEPOINT and ROLLBACK

BEGIN TRANSACTION;
-- First operation
INSERT INTO Orders (customer_id, order_date) VALUES (5, GETDATE());
SAVE TRANSACTION OrderCreated; -- SQL Server uses SAVE TRANSACTION instead of SAVEPOINT

-- Second operation that might fail
BEGIN TRY
    INSERT INTO OrderDetails (order_id, product_id, quantity)
    VALUES (SCOPE_IDENTITY(), 10, 2);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION OrderCreated; -- Rollback to savepoint
    -- Optionally commit the first part
    COMMIT TRANSACTION;
    PRINT 'Partial transaction completed due to error in order details';
END CATCH


--------------------------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--2. Concurrency Problem Demonstrations
--------------------------------------------------------------------------

--Dirty Read Problem

-- Connection 1
BEGIN TRANSACTION;
UPDATE Students SET email = 'new.email@example.com' WHERE student_id = 1;
-- Don't commit yet

-- Connection 2 (with READ UNCOMMITTED isolation level)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT email FROM Students WHERE student_id = 1; -- Sees uncommitted change
COMMIT TRANSACTION;

-- Connection 1
ROLLBACK TRANSACTION; -- The change is undone, but Connection 2 already saw it



--Lost Update Problem


-- Connection 1
BEGIN TRANSACTION;
SELECT grade FROM Enrollments WHERE enrollment_id = 1; -- Reads 85
-- Don't commit yet

-- Connection 2
BEGIN TRANSACTION;
SELECT grade FROM Enrollments WHERE enrollment_id = 1; -- Also reads 85
UPDATE Enrollments SET grade = 90 WHERE enrollment_id = 1;
COMMIT TRANSACTION;

-- Connection 1
UPDATE Enrollments SET grade = 88 WHERE enrollment_id = 1; -- Overwrites the 90
COMMIT TRANSACTION;
-- Final grade is 88 instead of 90

--------------------------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--Isolation Level Examples
--------------------------------------------------------------------------

--READ UNCOMMITTED (Dirty reads allowed)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Students; -- Can see uncommitted changes
COMMIT TRANSACTION;


--READ COMMITTED (Default - prevents dirty reads)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Students; -- Only sees committed data
COMMIT TRANSACTION;


--REPEATABLE READ (Prevents non-repeatable reads)

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT grade FROM Enrollments WHERE enrollment_id = 1; -- Locks the row
-- Another transaction can't modify this row until we commit
SELECT grade FROM Enrollments WHERE enrollment_id = 1; -- Will be the same
COMMIT TRANSACTION;

--SERIALIZABLE (Highest isolation)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Enrollments WHERE course_id = 5; -- Locks the range
-- Other transactions can't insert new enrollments for course_id = 5
COMMIT TRANSACTION;


--SNAPSHOT (Optimistic concurrency)

-- First enable snapshot isolation at database level
ALTER DATABASE AlexandriaUniversity SET ALLOW_SNAPSHOT_ISOLATION ON;

-- Then use it in transactions
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
SELECT * FROM Students; -- Works with a version of the data when transaction started
COMMIT TRANSACTION;

--------------------------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--4. SQL Server Concurrency Solutions
--------------------------------------------------------------------------

--Pessimistic Concurrency Control

-- Using explicit locks
BEGIN TRANSACTION;
SELECT * FROM Students WITH (UPDLOCK) WHERE student_id = 1;
-- Other transactions can't modify this row until we commit
COMMIT TRANSACTION;

--Optimistic Concurrency Control

-- Using rowversion/timestamp
BEGIN TRANSACTION;
DECLARE @currentVersion binary(8);
SELECT @currentVersion = version_column FROM Students WHERE student_id = 1;

-- Later when updating
UPDATE Students 
SET email = 'new@example.com', version_column = NEWID()
WHERE student_id = 1 AND version_column = @currentVersion;

IF @@ROWCOUNT = 0
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('Concurrency conflict detected', 16, 1);
END
ELSE
    COMMIT TRANSACTION;

--Deadlock Handling

BEGIN TRY
    BEGIN TRANSACTION;
    -- Operations that might cause deadlock
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 1205 -- Deadlock error number
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Transaction was chosen as deadlock victim and rolled back';
        -- Optionally retry the transaction
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END
END CATCH




