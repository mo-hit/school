CREATE TABLE Departments(
  name VARCHAR(64) NOT NULL,
  id VARCHAR(8),
  CONSTRAINT DepartmentId PRIMARY KEY(id),
  CONSTRAINT DepartmentName UNIQUE(name)
);

CREATE TABLE Programs(
  name VARCHAR(64) NOT NULL,
  abbreviation CHAR(5),
  CONSTRAINT ProgId PRIMARY KEY(abbreviation),
  CONSTRAINT ProgUniqueName UNIQUE(name)
);

CREATE TABLE Branches(
  name VARCHAR(64) NOT NULL,
  id CHAR(5),
  program CHAR(5),
  CONSTRAINT BranchIdProgram PRIMARY KEY(id,program),
  CONSTRAINT BranchIdProgramReference UNIQUE(name,program),
  CONSTRAINT BranchProgramReference FOREIGN KEY (program) REFERENCES Programs(abbreviation)
);

CREATE TABLE Courses(
  code CHAR(6),
  name VARCHAR(64) NOT NULL,
  credits INTEGER NOT NULL,
  department VARCHAR(8),
  CONSTRAINT CourseCode PRIMARY KEY(code),
  CONSTRAINT CourseDepartmentReference FOREIGN KEY (department) REFERENCES Departments(id),
  CONSTRAINT CourseInvalidCredits CHECK (credits >= 0)
);

CREATE TABLE LimitedCourses(
  code CHAR(6),
  students INTEGER NOT NULL,
  CONSTRAINT LimitedCourseCode PRIMARY KEY (code),
  CONSTRAINT LimitedCourseReference FOREIGN KEY (code) REFERENCES Courses(code),
  CONSTRAINT LimitedCourseInvalidStudents CHECK (students >= 0)
);

CREATE TABLE Students(
  id VARCHAR(8),
  name VARCHAR(64) NOT NULL,
  program CHAR(5),
  branch CHAR(5),
  CONSTRAINT StudentId PRIMARY KEY (id),
  CONSTRAINT StudentProgramReference FOREIGN KEY (program) REFERENCES Programs(abbreviation),
  CONSTRAINT StudentBranchReference FOREIGN KEY (program,branch) REFERENCES Branches(program, id),
  CONSTRAINT StudentIdProgramUnique UNIQUE (id, program)
);

CREATE TABLE Hosts(
  department VARCHAR(8),
  program CHAR(5),
  CONSTRAINT HostDepartmentProgram PRIMARY KEY(department,program),
  CONSTRAINT HostDepartmentReference FOREIGN KEY (department) REFERENCES Departments(id),
  CONSTRAINT HostProgramReference FOREIGN KEY (program) REFERENCES Programs(abbreviation)
);

CREATE TABLE Classifications(
  type VARCHAR(64) PRIMARY KEY
);

CREATE TABLE HasClassification(
  course CHAR(6),
  classification VARCHAR(64),
  CONSTRAINT HasClassifCourseClass PRIMARY KEY(course, classification),
  CONSTRAINT HasClassifClassReference FOREIGN KEY (classification) REFERENCES Classifications(type),
  CONSTRAINT HasClassifCourseReference FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Requires(
  course CHAR(6),
  requiredCourse CHAR(6),
  CONSTRAINT RequiresCourseRequiredCourse PRIMARY KEY(course, requiredCourse),
  CONSTRAINT CourseReference FOREIGN KEY (course) REFERENCES Courses(code),
  CONSTRAINT RequiredCourseReference FOREIGN KEY (requiredCourse) REFERENCES Courses(code)
);

CREATE TABLE MandatoryInProgram(
  program CHAR(5),
  course CHAR(6),
  CONSTRAINT MandInProgramCourse PRIMARY KEY(program, course),
  CONSTRAINT MandInProgProgramReference FOREIGN KEY (program) REFERENCES Programs(abbreviation),
  CONSTRAINT MandInProgCourseReference FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE MandatoryInBranch(
  program CHAR(5),
  branch CHAR(5),
  course CHAR(6),
  CONSTRAINT MandInBranchProgBranchCourse PRIMARY KEY(program, branch, course),
  CONSTRAINT MandInBranchProgBranchRef FOREIGN KEY (program, branch) REFERENCES Branches(program, id),
  CONSTRAINT MandInBranchCourseRef FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Recommends(
  program CHAR(5),
  branch CHAR(5),
  course CHAR(6),
  CONSTRAINT RecommendsProgramBranchCourse PRIMARY KEY(program, branch, course),
  CONSTRAINT RecommendsProgBranchRef FOREIGN KEY (program, branch) REFERENCES Branches(program, id),
  CONSTRAINT RecommendsCourseReference FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Finishes(
  student VARCHAR(8),
  course CHAR(6),
  grade CHAR(1) NOT NULL,
  PRIMARY KEY(student, course),
  FOREIGN KEY (student) REFERENCES Students(id),
  FOREIGN KEY (course) REFERENCES Courses(code),
  CONSTRAINT ValidGrade CHECK (grade IN ('U', '3', '4', '5'))
);

CREATE TABLE Takes(
  student VARCHAR(8),
  course CHAR(6),
  CONSTRAINT TakesStudentCourse PRIMARY KEY(student, course),
  CONSTRAINT TakesStudentReference FOREIGN KEY (student) REFERENCES Students(id),
  CONSTRAINT TakesCourseReference FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Waits(
  student VARCHAR(8),
  course CHAR(6),
  queueNum INTEGER NOT NULL,
  CONSTRAINT WwaitsStudentCourse PRIMARY KEY(student, course),
  CONSTRAINT WaitsStudentReference FOREIGN KEY (student) REFERENCES Students(id),
  CONSTRAINT WaitsCourseReference FOREIGN KEY (course) REFERENCES LimitedCourses(code),
  CONSTRAINT WaitsCourseQueueUnique UNIQUE(course, queueNum)
);

CREATE SEQUENCE QueueNumber
START WITH 1
INCREMENT BY 1;

INSERT ALL
  INTO Departments VALUES('Mathematical Sciences', 'Math')
  INTO Departments VALUES('Applied Mechanics','AM')
  INTO Departments VALUES('Applied Physics', 'AP')
  INTO Departments VALUES('Applied Information Technology', 'AIT')
  INTO Departments VALUES('Computer Science and Engineering', 'CSE')
  INTO Departments VALUES('Architecture', 'Arch')
  INTO Departments VALUES('Energy and Environment','ENV')
  INTO Departments VALUES('Civil and Environmental Engineering','CEE')
  INTO Programs VALUES('AUTOMATION AND MECHATRONICS ENGINEERING', 'TKAUT')
  INTO Programs VALUES('ENGINEERING PHYSICS', 'TKTFY')
  INTO Programs VALUES('SOFTWARE ENGINEERING', 'TKITE')
  INTO Programs VALUES('ARCHITECTURE', 'TKARK')
  INTO Programs VALUES('COMPUTER SCIENCE AND ENGINEERING', 'TKDAK')
  INTO Programs VALUES('COMPUTER ENGINEERING', 'TIDAL')
  INTO Programs VALUES('SYSTEMS, CONTROL AND MECHATRONICS','TKDAT')
  INTO Branches VALUES('SYSTEMS, CONTROL AND MECHATRONICS', 'MPSYS', 'TKDAT')
  INTO Branches VALUES('INTERACTION DESIGN AND TECHNOLOGIES', 'MPIDE', 'TKITE')
  INTO Branches VALUES('NUCLEAR ENGINEERING', 'MPNUE', 'TKTFY')
  INTO Branches VALUES('SOFTWARE ENGINEERING', 'MPSOF', 'TKITE')
  INTO Branches VALUES('SOFTWARE ENGINEERING', 'MPSOF', 'TIDAL')
  INTO Branches VALUES('SOFTWARE ENGINEERING', 'MPSOF', 'TKDAK')
  INTO Courses VALUES('TDA357', 'Databases', 100, 'CSE')
  INTO Courses VALUES('TDA545', 'Object-oriented programming', 100, 'CSE')
  INTO Courses VALUES('EDA344', 'Computer Communication', 100, 'CSE')
  INTO Courses VALUES('TDA596', 'Distributed Systems', 100, 'CSE')
  INTO Courses VALUES('EDA387', 'Computer Networks', 100, 'CSE')
  INTO Courses VALUES('DAT093', 'Introduction to Electronic Systems Design', 75, 'CSE')
  INTO Courses VALUES('DAT116', 'Mixed Signal Systems Design', 100, 'CSE')
  INTO Courses VALUES('TDA550', 'Object-oriented programming, advanced course', 100, 'CSE')
  INTO Courses VALUES('TMV200', 'Discrete mathematics', 100, 'AM')
  INTO Courses VALUES('TMV206', 'Linear algebra', 150, 'AM')
  INTO Courses VALUES('TDA361', 'Computer graphics', 130, 'AM')
  INTO Courses VALUES('KTK111', 'Chemistry for engineers', 100, 'CEE')
  INTO Courses VALUES('FFR166', 'Science of Environmental Change',100,'ENV')
  INTO Courses VALUES('FFY621', 'Physics for engineers', 85, 'AP')
  INTO Courses VALUES('FFR105', 'Stochastic Optimization Algorithms', 75, 'AP')
  INTO Courses VALUES('TDA383', 'Concurrent programming', 75, 'AIT')
  INTO Courses VALUES('DAT240', 'Model-driven engineering', 100, 'AIT')
  INTO Courses VALUES('TMV027', 'Finite Automata Theory and Formal Languages',75,'CSE')
  INTO LimitedCourses VALUES('TDA357', 2)
  INTO LimitedCourses VALUES('DAT116', 4)
  INTO LimitedCourses VALUES('DAT093',6 )
  INTO LimitedCourses VALUES('TDA550', 8)
  INTO LimitedCourses VALUES('TDA383',2)
  INTO Classifications VALUES('mathematical')
  INTO Classifications VALUES('research')
  INTO Classifications VALUES('seminar')
  INTO HasClassification VALUES('TMV200','mathematical')
  INTO HasClassification VALUES('TMV206','mathematical')
  INTO HasClassification VALUES('FFR105','research')
  INTO HasClassification VALUES('FFR166','seminar')
  INTO HasClassification VALUES('KTK111','seminar')
  INTO Requires VALUES('TDA596','EDA387')
  INTO Requires VALUES('EDA387','EDA344')
  INTO Requires VALUES('TDA550','TDA545')
  INTO Requires VALUES('TDA596','EDA344')
  INTO Requires VALUES('TDA361','TMV206')
  INTO MandatoryInProgram VALUES('TKITE','EDA387')
  INTO MandatoryInProgram VALUES('TKDAT','DAT093')
  INTO MandatoryinProgram VALUES('TKITE','TDA545')
  INTO MandatoryInProgram VALUES('TKITE','TDA357')
  INTO MandatoryInBranch VALUES('TKITE','MPIDE','TDA357')
  INTO MandatoryInBranch VALUES('TKITE','MPSOF','TDA550')
  INTO MandatoryInBranch VALUES('TKITE','MPSOF','TDA383')
  INTO MandatoryInBranch VALUES('TKITE','MPSOF','TMV027')
  INTO Recommends VALUES('TKITE','MPIDE','TDA357')
  INTO Recommends VALUES('TKITE','MPSOF','TDA357')
  INTO Recommends VALUES('TKITE', 'MPSOF', 'TDA383')
  INTO Recommends VALUES('TKDAT','MPSYS','DAT093')
  INTO Students VALUES('mohitg','Mohit Gupta', 'TIDAL', 'MPSOF')
  INTO Students VALUES('boonen','Sophie Boonen','TKITE', 'MPIDE')
  INTO Students VALUES('mynameis','My Name', 'TKDAT','MPSYS')
  INTO Students VALUES('samplper','Sample Person','TKDAK', 'MPSOF')
  INTO Students VALUES('imname','Imaginary Name','TKITE', 'MPSOF')
  INTO Students VALUES('bwayne','Bruce Wayne','TKITE', 'MPSOF')
  INTO Students VALUES('ckent','Clark Kent','TKITE', 'MPSOF')
  INTO Finishes VALUES('mohitg','EDA387','4')
  INTO Finishes VALUES('boonen','TDA357','U')
  INTO Finishes VALUES('mohitg','FFR166','3')
  INTO Finishes VALUES('bwayne','TDA357','5')
  INTO Finishes VALUES('ckent','DAT093','5')
  INTO Finishes VALUES('ckent','TDA383','4')
  INTO Finishes VALUES('ckent','TDA550','4')
  INTO Finishes VALUES('ckent','TDA545','5')
  INTO Finishes VALUES('ckent','EDA387','4')
  INTO Finishes VALUES('ckent','TMV200','4')
  INTO Finishes VALUES('ckent','EDA344','4')
  INTO Finishes VALUES('ckent','TMV027', '4')
  INTO Finishes VALUES('ckent','FFR105', '5')
  INTO Finishes VALUES('ckent','KTK111', '4') 
  INTO Finishes VALUES('imname','TDA357','U')
  INTO Finishes VALUES('mynameis','EDA387','U')
  INTO Finishes VALUES('ckent','TDA357','5')  
  INTO Takes VALUES('samplper','DAT093')
  INTO Takes VALUES('samplper','FFR166')
  INTO Takes VALUES('imname','TDA357')
  INTO Takes VALUES('imname','TDA383')
  INTO Takes VALUES('bwayne','TDA383')
  INTO Takes VALUES('samplper','TDA357')
  INTO Takes VALUES('mynameis', 'TDA357')
SELECT 1 FROM DUAL;

INSERT INTO Waits VALUES('mohitg','TDA383',QueueNumber.nextval);
INSERT INTO Waits VALUES('boonen','TDA383',QueueNumber.nextval);
INSERT INTO Waits VALUES('bwayne','TDA550',QueueNumber.nextval);
INSERT INTO Waits VALUES('samplper','DAT116',QueueNumber.nextval);
  
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
  
  
