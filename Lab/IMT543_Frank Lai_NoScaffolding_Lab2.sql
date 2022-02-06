/*
1) Write the SQL query to determine the departments that held fewer than 230 classes in buildings on Stevens Way 
between 2011 and 2016 that also generated more than $16.5 million from registration fees in the 1990's that also 
had more than 400 distinct (!!) students complete a 400-level course in the 1980's
*/

SELECT SUB1.DeptID, SUB1.DeptName
FROM (
    SELECT COUNT(CS.ClassID) AS CLASSES, D.DeptID, D.DeptName
    FROM tblDEPARTMENT D 
    JOIN tblCOURSE C 
      ON D.DeptID = C.DeptID
    JOIN tblCLASS CS 
      ON C.CourseID = CS.CourseID
    JOIN tblCLASSROOM CR 
      ON CS.ClassroomID = CR.ClassroomID
    JOIN tblBUILDING B 
      ON CR.BuildingID = B.BuildingID
    JOIN tblLOCATION LO 
      ON B.LocationID = LO.LocationID
    WHERE LO.LocationName = 'Stevens Way'
      AND CS.[YEAR] BETWEEN '2011' AND '2016'
    GROUP BY D.DeptID, D.DeptName
    HAVING COUNT(CS.ClassID) < 230
) SUB1
JOIN (
    SELECT SUM(CL.RegistrationFee) RegistrationFeeSum, D.DeptID
    FROM tblCLASS_LIST CL
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    WHERE CS.[YEAR] BETWEEN '1990' AND '1999'
    GROUP BY D.DeptID
    HAVING SUM(CL.RegistrationFee) > 16500000
) SUB2
  ON SUB1.DeptID = SUB2.DeptID
JOIN (
    SELECT COUNT(DISTINCT(CL.StudentID)) AS StudentCount, D.DeptID
    FROM tblCLASS_LIST CL
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    WHERE CS.[YEAR] BETWEEN '1980' AND '1989'
      AND C.CourseNumber BETWEEN 400 AND 499
    GROUP BY D.DeptID
    HAVING COUNT(DISTINCT(CL.StudentID)) > 400
) SUB3
  ON SUB1.DeptID = SUB3.DeptID
ORDER BY DeptID;

/*
2) Which students with the special need of 'Anxiety' have completed more than 13 credits of 300-level 
Information School classes with a grade less than 3.1 in the last 3 years?
*/

SELECT S.StudentID, S.StudentFname, S.StudentLname
FROM tblSTUDENT S
JOIN (
    SELECT StudentID 
    FROM tblSTUDENT_SPECIAL_NEED SSN
    JOIN tblSPECIAL_NEED SN 
      ON SSN.SpecialNeedID = SN.SpecialNeedID
    WHERE SN.SpecialNeedName = 'Anxiety'
) SUB1
  ON S.StudentID = SUB1.StudentID
JOIN (
    SELECT CL.StudentID
    FROM tblCLASS_LIST CL 
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Information School'
      AND CS.[YEAR] BETWEEN YEAR(GETDATE()) - 3 AND YEAR(GETDATE())
      AND C.CourseNumber BETWEEN 300 AND 399
      AND CL.Grade < 3.1
    GROUP BY CL.StudentID
    HAVING SUM(C.Credits) > 13
) SUB2
  ON SUB1.StudentID = SUB2.StudentID;

/*
3) Write the SQL to determine the top 10 states by number of students who have completed both 15 credits of Arts and Science courses
as well as between 5 and 18 credits of Medicine since 2003.
*/

SELECT TOP(10) S.StudentPermState AS STATE, COUNT(S.StudentID) AS StudentCount 
FROM tblSTUDENT S
JOIN (
    SELECT CL.StudentID
    FROM tblCLASS_LIST CL 
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Arts and Sciences'
      AND CS.[YEAR] >= 2003
    GROUP BY CL.StudentID
    HAVING SUM(C.Credits) = 15
) SUB1
  ON S.StudentID = SUB1.StudentID
JOIN (
    SELECT CL.StudentID
    FROM tblCLASS_LIST CL 
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Medicine'
      AND CS.[YEAR] >= 2003
    GROUP BY CL.StudentID
    HAVING SUM(C.Credits) BETWEEN 5 AND 8
) SUB2
  ON SUB1.StudentID = SUB2.StudentID
GROUP BY S.StudentPermState
ORDER BY StudentCount DESC;


/*
4) Write the SQL to determine the students who are currently assigned a dormroom type 'Triple' on West Campus 
who have paid more than $2,000 in registration fees in the past four years?
*/

SELECT S.StudentID, S.StudentFname, S.StudentLname
FROM tblSTUDENT S
JOIN (
    SELECT SD.StudentID
    FROM tblSTUDENT_DORMROOM SD
    JOIN tblDORMROOM DR 
      ON SD.DormRoomID = DR.DormRoomID
    JOIN tblDORMROOM_TYPE DT 
      ON DR.DormRoomTypeID = DT.DormRoomTypeID
    JOIN tblBUILDING B
      ON DR.BuildingID = B.BuildingID
    JOIN tblLOCATION LO 
      ON B.LocationID = LO.LocationID
    WHERE DT.DormRoomTypeName = 'Triple'
      AND LO.LocationName = 'West Campus'
) SUB1
  ON S.StudentID = SUB1.StudentID
JOIN (
    SELECT StudentID
    FROM tblCLASS_LIST 
    WHERE RegistrationDate BETWEEN DATEADD(YEAR, -4,GETDATE()) AND GETDATE()
    GROUP BY StudentID
    HAVING SUM(RegistrationFee) > 2000 
) SUB2
  ON SUB1.StudentID = SUB2.StudentID;