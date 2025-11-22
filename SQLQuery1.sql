BEGIN TRANSACTION;
UPDATE students SET first_name = 'hamza'  WHERE student_id = 1;
-- Wait a bit, then try to lock tableB
WAITFOR DELAY '00:00:05';
UPDATE enrollments SET grade = 10 WHERE enrollment_id = 1;
-- COMMIT; (Don't commit yet)

select *from students;