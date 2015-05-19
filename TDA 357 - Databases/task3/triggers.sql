CREATE OR REPLACE TRIGGER CourseRegistration
    INSTEAD OF INSERT ON Registrations
    REFERENCING NEW AS new
    FOR EACH ROW
    DECLARE
      maxNum INT;
      currentNum INT;
      limited INT;
      passed INT;
      registered INT;
      preReqs INT;
      waiting INT;
      placementFlag BOOLEAN := FALSE; -- 
    BEGIN
      SELECT COUNT(*) INTO limited FROM LimitedCourses WHERE code = :new.course;
      IF limited > 0 THEN --limited course
        SELECT students INTO maxNum FROM LimitedCourses WHERE code = :new.course;
        SELECT COUNT(*) INTO currentNum
        FROM Takes T
        WHERE T.course = :new.course;
        IF currentNum < maxNum THEN -- still has a place
          placementFlag := TRUE;
        ELSE -- the course is full
          SELECT COUNT(*) INTO waiting FROM Waits WHERE
            :new.student = Waits.student AND :new.course = Waits.course;
          IF waiting != 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Already Waiting!');
          ELSE
            INSERT INTO Waits VALUES(:new.student, :new.course, QueueNumber.nextval);
          END IF;
        END IF;
      END IF; -- normal course
      IF (limited < 1) OR (placementFlag = TRUE) THEN 
          SELECT COUNT(*) INTO preReqs FROM Requires R WHERE
          R.course = :new.course AND NOT EXISTS
            (SELECT * FROM PassedCourses P WHERE P.student = :new.student AND P.code = R.requiredcourse);
          SELECT COUNT(*) INTO registered FROM Takes WHERE 
            :new.student = Takes.student AND :new.course = Takes.course;
          SELECT COUNT(*) INTO passed FROM PassedCourses P WHERE
            P.student = :new.student AND P.code = :new.course;
          IF registered != 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Already Registered!');
          ELSIF preReqs != 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Prerequisites not met');
          ELSIF passed != 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Already Passed!');
          ELSE
            INSERT INTO Takes VALUES (:new.student,:new.course);
          END IF;
        END IF;
    END;
/
CREATE OR REPLACE TRIGGER CourseUnregistration
  INSTEAD OF DELETE ON Registrations
  REFERENCING OLD AS old
  FOR EACH ROW
  DECLARE
  maxNum INT;
  currentNum INT;
  firstStuInQueue Students.ID%TYPE;
  waitingNum INT;
  overfullFlag BOOLEAN := FALSE;
  BEGIN
    IF :old.status = 'registered' THEN
      SELECT COUNT(*) INTO waitingNum FROM Registrations R
      WHERE R.course = :old.course AND R.status = 'waiting';
      IF waitingNum > 0 THEN
        SELECT students INTO maxNum FROM LimitedCourses WHERE code = :old.course;
        SELECT COUNT(*) INTO currentNum FROM Takes T WHERE T.course = :old.course;
        IF currentNum - 1 < maxNum THEN --make sure the course isn't overfull 
          --check currentNum -1 because we are technically still removing a student
          SELECT CQP.student INTO firstStuInQueue
          FROM CourseQueuePositions CQP
          WHERE CQP.course = :old.course AND CQP.queuePos=1;
          
          DELETE FROM Waits W 
          WHERE W.student = firstStuInQueue AND W.course = :old.course;
          
          UPDATE Takes T 
          SET T.student = firstStuInQueue
          WHERE T.student = :old.student AND T.course = :old.course;
        ELSE --course is overfull and just delete don't change the waiting list (set flag to be deleted)
          overfullFlag := TRUE;
        END IF;
      END IF;
      -- avoid repeating the same code for both cases
      IF (waitingNum < 1 OR overfullFlag = TRUE ) THEN
        DELETE FROM Takes T
        WHERE T.student = :old.student AND T.course = :old.course;
      END IF;
    ELSE --remove from waiting list then
      DELETE FROM Waits W
      WHERE W.student = :old.student AND W.course = :old.course;
    END IF;
  END;
/