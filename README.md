# Alexandria University Database Project (Archived)

A SQL Server database project developed as part of the Advanced Database Systems course at Alexandria University.  
This repository is preserved only as a historical academic record and does not reflect current professional coding standards.

## Overview

This project implements a complete database system for university operations, covering students, instructors, departments, courses, enrollment, auditing, and security.

The work demonstrates:

- Relational database design and normalization
- SQL Server schema creation
- Stored procedures and scalar functions
- Triggers for integrity and auditing
- Transaction management and concurrency control
- Row-Level Security (RLS) and Dynamic Data Masking (DDM)
- Performance optimization using indexes and sequences

## Contributions

This project was developed collaboratively as a team.  
My personal contributions were:

- Designed and created the full database schema  
- Implemented all main tables (students, departments, instructors, courses, enrollments, available courses)  
- Participated in Tasks 1 and 2 with the team  
- Completed **Task 3 independently**, including transactions, concurrency control, and isolation levels  
- Wrote and tested advanced triggers, stored procedures, and indexing scripts

## Database Schema (Summary)

Core tables include:

- **Departments** – Department records  
- **Students** – Student information with email uniqueness and audit logging  
- **Instructors** – Faculty data  
- **Courses** – Course catalog  
- **Available_Courses** – Offered courses by semester  
- **Enrollments** – Student registrations with status and grade tracking  

Audit tables:
- **student_changes_log** – Tracks updates/deletions  
- **enrollment_activity_log** – Logs enrollment changes  

## Key Features (Summary)

### Functions and Procedures
- Lookup utilities for course name, instructor name, enrollment details  
- Student registration with validation and seat checks  

### Triggers
- Prevent duplicate emails  
- Log all student changes  
- Log enrollment activity  
- Manage course seat availability  
- Enforce maximum course load  

### Views
- Student course history with grades  
- Student performance summary  
- Instructor teaching load  

### Security
- Row-Level Security for student isolation  
- Dynamic Data Masking for sensitive fields  
- Role-based access for students, instructors, registrar, and admin  

### Performance
- Targeted indexes for students, courses, enrollments  
- Sequences for auto-incremented IDs  

### Transactions and Concurrency
- Demonstrates all SQL Server isolation levels  
- Protection against dirty reads, lost updates, and concurrency conflicts  
- Includes pessimistic and optimistic locking examples  

## Installation

1. Create the database:
   ```sql
   CREATE DATABASE AlexandriaUniversity;
Run the SQL scripts in order:

1-Creation.sql

2-Functions, Procedures and Triggers.sql

3-Views And Complex Queries.sql

4-Transactions and Concurrency.sql

5-Indexing and Security.sql

(Optional) Enable snapshot isolation:

sql
Copy code
ALTER DATABASE AlexandriaUniversity SET ALLOW_SNAPSHOT_ISOLATION ON;
Usage Examples
sql
Copy code
-- Register a student in a course
DECLARE @msg NVARCHAR(200);
EXEC dbo.RegisterStudentInCourse 
    @StudentID = 1, 
    @AvailableCourseID = 5,
    @Message = @msg OUTPUT;
PRINT @msg;

-- View student progress
SELECT * FROM StudentProgress WHERE student_id = 1;

-- Instructor course load
SELECT * FROM InstructorLoad WHERE courses_teaching > 3;

-- Apply RLS context
EXEC sp_set_session_context 'student_id', 1;
SELECT * FROM students;
Notes
This project was part of an academic requirement.
It is archived and not maintained.
Its purpose is to document early database development work completed during undergraduate study.

Author
Hamza
Advanced Database Systems
Alexandria University