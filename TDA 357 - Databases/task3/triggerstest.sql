--It is recommended that the statements be run individually so that you can see the state of the db between statements
--Case 1: This is a regular insert into an open class
INSERT INTO Registrations(course,student) VALUES ('FFR166','ckent');

--Case 2: This insert should be normal and registered for the limited course TDA357, with the course now being full
--(There should already be one student registered for the course from the insert.sql file)
INSERT INTO Registrations(course,student) VALUES ('TDA357','mohitg');

--Case 3: This insert should not allow for the student to register, and instead get placed on a waiting list
INSERT INTO Registrations(course,student) VALUES ('TDA357','boonen');

--Case 4: Student does not have prereqs and attempts to register (should error)
INSERT INTO Registrations(course,student) VALUES ('TDA550','samplper');

--Case 5: Student has already passed the course and attempts to register (should error)
INSERT INTO Registrations(course, student) VALUES ('EDA387','mohitg');

--Case 6: Unregister a student in an open course
DELETE FROM Registrations WHERE course = 'FFR166' AND student = 'ckent';

--Case 7: Unregister a student in a limited course with a queue
DELETE FROM Registrations WHERE course = 'TDA357' AND student = 'mohitg';

--Case 8: Unregister a student in the waits table
DELETE FROM Registrations WHERE course = 'TDA383' AND student = 'mohitg';