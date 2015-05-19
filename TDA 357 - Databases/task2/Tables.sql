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