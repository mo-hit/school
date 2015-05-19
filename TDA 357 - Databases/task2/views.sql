CREATE OR REPLACE VIEW StudentsFollowing AS
  SELECT DISTINCT Students.id, Students.name, Students.branch, Students.program, Programs.name as programname, Branches.name as branchname
  FROM Students
  LEFT OUTER JOIN Programs ON Students.program = Programs.abbreviation
  LEFT OUTER JOIN Branches ON Students.branch = Branches.id;

--  
CREATE OR REPLACE VIEW FinishedCourses AS
  SELECT course, Courses.name AS coursename,
  student, Students.name as studentName, grade, credits
  FROM Finishes
  JOIN Students ON student = id
  JOIN Courses ON course = courses.code;
  
CREATE OR REPLACE VIEW Registrations AS
	WITH
  		WaitingRegistrations AS
			(SELECT course, Courses.name AS courseName, student,
				Students.name AS studentName, 'waiting' AS Status
			FROM Waits
			JOIN Courses  ON course = code
			JOIN Students ON student = id),
      
		CompleteRegistrations AS
			(SELECT course, Courses.name AS courseName, student,
				Students.name AS studentName, 'registered' AS Status
			FROM Takes
			JOIN Courses  ON course = code
			JOIN Students ON student = id)
	SELECT * FROM CompleteRegistrations
	UNION
	SELECT * FROM WaitingRegistrations;
  
CREATE OR REPLACE View PassedCourses AS
	SELECT
	course AS code, courseName AS name, student, grade, credits
	FROM FinishedCourses
	WHERE grade != 'U';
  
CREATE OR REPLACE VIEW UnreadMandatory AS
  WITH 
  Mandatory AS
   (SELECT id as student, course FROM Students
    JOIN MandatoryInBranch ON Students.branch = MandatoryInBranch.branch
    AND Students.program = MandatoryInBranch.program
    UNION
    SELECT id AS student, course FROM Students
    JOIN MandatoryInProgram ON Students.program = MandatoryInProgram.program),
  Unread AS
   (SELECT * FROM Mandatory WHERE NOT EXISTS 
    (SELECT * FROM PassedCourses P WHERE 
      Mandatory.student = P.student AND Mandatory.course = P.code))
  
  SELECT Unread.student,Unread.course, Courses.name AS cname
  FROM Unread
  JOIN Courses ON Unread.course = Courses.code;
  
  
CREATE OR REPLACE VIEW PathToGraduation AS
  WITH GradCols AS
    (SELECT id, COALESCE(SUM(credits),0)
    AS numCredits,
    
      (SELECT COALESCE(SUM(credits),0) FROM PassedCourses
       JOIN Recommends ON PassedCourses.code = Recommends.course
       WHERE id = student and branch IN (SELECT branch FROM Students where Students.id = id) )
    AS recommendedCredits,
    
      (SELECT COALESCE(SUM(credits),0) FROM PassedCourses
       JOIN MandatoryInBranch ON PassedCourses.code = MandatoryInBranch.course
       WHERE id = student and branch IN (SELECT branch FROM Students where Students.id = id) ) 
    AS branchCredits,
    
       (SELECT COUNT(*) FROM UnreadMandatory WHERE id = student) 
    AS coursesLeft,
    
       (SELECT COALESCE(SUM(credits), 0) FROM PassedCourses
				JOIN HasClassification ON PassedCourses.code = HasClassification.course
				WHERE id = student AND classification = 'mathematical') 
    AS mathCredits,
    
       (SELECT COALESCE(SUM(credits), 0) FROM PassedCourses
				JOIN HasClassification ON PassedCourses.code = HasClassification.course
				WHERE id = student AND classification = 'research') 
    AS researchCredits,
    
       (SELECT COALESCE(SUM(credits), 0) FROM PassedCourses
				JOIN HasClassification ON PassedCourses.code = HasClassification.course
				WHERE id = student AND classification = 'seminar') 
    AS seminarCredits
    
    FROM Students 
    FULL OUTER JOIN PassedCourses ON id=student
    GROUP BY id )
    
    SELECT id, numCredits, recommendedCredits, branchCredits, coursesLeft, mathCredits, researchCredits, seminarCredits, 
        CASE
            WHEN coursesLeft < 1
              AND branchCredits >=10
              AND mathCredits >= 20
              AND researchCredits >= 10
              AND seminarCredits > 1
            THEN 1
            ELSE 0
        END
        AS graduated
    FROM GradCols;
    
CREATE OR REPlACE VIEW RegisteredCoursesRelation AS
    SELECT Registrations.course, Registrations.student, Registrations.coursename, status, credits, queuePos
     FROM Registrations
     JOIN Courses ON course = Courses.code
     FULL OUTER JOIN CourseQueuePositions ON Registrations.course = CourseQueuePositions.course AND Registrations.student = CourseQueuePositions.student;
  
  
CREATE OR REPLACE VIEW CourseQueuePositions AS
	SELECT student, course, Courses.name AS courseName, queueNum,
		(SELECT COUNT(*) FROM Waits W 
		WHERE W.course = Waits.course AND W.queueNum <= Waits.queueNum)
		AS queuePos
	FROM Waits
	JOIN Courses ON course = Courses.code;
  
  