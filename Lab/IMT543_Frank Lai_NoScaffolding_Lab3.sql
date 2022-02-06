
/*
1) Write the SQL to determine the top three StudentPermStates with the highest average grade earned for 300-level course from 
the college of 'Arts and Sciences' over the last 15 years?
*/

SELECT TOP(3) S.StudentPermState, AVG(CL.Grade) AS 'Average Grade'
FROM tblSTUDENT S 
JOIN tblCLASS_LIST CL 
  ON S.StudentID = CL.StudentID
JOIN tblCLASS CS 
  ON CL.ClassID = CS.ClassID
JOIN tblCOURSE C 
  ON CS.CourseID = C.CourseID
JOIN tblDEPARTMENT D 
  ON C.DeptID = D.DeptID
JOIN tblCOLLEGE CO 
  ON D.CollegeID = CO.CollegeID
WHERE CO.CollegeName = 'Arts and Sciences'
  AND C.CourseNumber BETWEEN 300 AND 399
  AND CS.[YEAR] BETWEEN YEAR(GETDATE()) - 15 AND YEAR(GETDATE())
GROUP BY S.StudentPermState
  ORDER BY AVG(CL.Grade) DESC;

/*
2) Write the SQL to determine which students have completed at least 15 credits of classes each from the colleges of Medicine, 
Information School, and Arts and Sciences since 2009 that also completed more than 3 classes held in buildings on Stevens Way 
in classrooms of type 'large lecture hall'. 
*/

SELECT S.StudentID
FROM tblSTUDENT S
JOIN (
    SELECT S.StudentID
    FROM tblSTUDENT S 
    JOIN tblCLASS_LIST CL 
      ON S.StudentID = CL.StudentID
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Medicine'
      AND CS.[YEAR] >= 2009
    GROUP BY S.StudentID
    HAVING SUM(C.Credits) >= 15
) SUB1
  ON S.StudentID = SUB1.StudentID
JOIN (
    SELECT S.StudentID
    FROM tblSTUDENT S 
    JOIN tblCLASS_LIST CL 
      ON S.StudentID = CL.StudentID
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Information School'
      AND CS.[YEAR] >= 2009
    GROUP BY S.StudentID
    HAVING SUM(C.Credits) >= 15
) SUB2
  ON SUB1.StudentID = SUB2.StudentID
JOIN (
    SELECT S.StudentID
    FROM tblSTUDENT S 
    JOIN tblCLASS_LIST CL 
      ON S.StudentID = CL.StudentID
    JOIN tblCLASS CS 
      ON CL.ClassID = CS.ClassID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    JOIN tblCOLLEGE CO 
      ON D.CollegeID = CO.CollegeID
    WHERE CO.CollegeName = 'Arts and Sciences'
      AND CS.[YEAR] >= 2009
    GROUP BY S.StudentID
    HAVING SUM(C.Credits) >= 15
) SUB3
  ON SUB2.StudentID = SUB3.StudentID
JOIN tblCLASS_LIST CL 
  ON S.StudentID = CL.StudentID
JOIN tblCLASS CS 
  ON CL.ClassID = CS.ClassID
JOIN tblCLASSROOM CR 
  ON CS.ClassroomID = CR.ClassroomID
JOIN tblCLASSROOM_TYPE CRT
  ON CR.ClassroomTypeID = CRT.ClassroomTypeID
JOIN tblBUILDING B 
  ON CR.BuildingID = B.BuildingID
JOIN tblLOCATION L 
  ON B.LocationID = L.LocationID
WHERE L.LocationName = 'Stevens Way'
  AND CRT.ClassroomTypeName = 'Large Lecture Hall'
GROUP BY S.StudentID
HAVING COUNT(CS.ClassID) >= 3;

/*
3) Write the SQL to determine the buildings that have held more than 10 classes from the Mathematics department since 1997 that have also
that have also held fewer than 20 classes from the Anthropology department since 2016.
*/

SELECT B.BuildingID, B.BuildingName
FROM tblBUILDING B
JOIN (
    SELECT B.BuildingID, B.BuildingName
    FROM tblBUILDING B
    JOIN tblCLASSROOM CR 
      ON B.BuildingID = CR.BuildingID
    JOIN tblCLASS CS 
      ON CR.ClassroomID = CS.ClassroomID
    JOIN tblCOURSE C 
      ON CS.CourseID = C.CourseID
    JOIN tblDEPARTMENT D 
      ON C.DeptID = D.DeptID
    WHERE D.DeptName = 'Mathematics'
      AND CS.[YEAR] >= 1997
    GROUP BY B.BuildingID, B.BuildingName
    HAVING COUNT(CS.ClassID) > 10
) SUB1
  ON B.BuildingID = SUB1.BuildingID
JOIN tblCLASSROOM CR 
    ON B.BuildingID = CR.BuildingID
JOIN tblCLASS CS 
    ON CR.ClassroomID = CS.ClassroomID
JOIN tblCOURSE C 
    ON CS.CourseID = C.CourseID
JOIN tblDEPARTMENT D 
    ON C.DeptID = D.DeptID
WHERE D.DeptName = 'Anthropology'
  AND CS.[YEAR] >= 2016
GROUP BY B.BuildingID, B.BuildingName
HAVING COUNT(CS.ClassID) < 20;

/*
4) Write the SQL to determine which location on campus has held the classes that generated the most combined money in registration fees for
 the colleges of 'Engineering', 'Nursing', 'Pharmacy', and 'Public Affairs (Evans School)'.
*/ 

SELECT TOP(1)L.LocationID, L.LocationName, SUM(CL.RegistrationFee) AS 'Combined Money in Registration Fees'
FROM tblLOCATION L 
JOIN tblBUILDING B
  ON L.LocationID = B.LocationID
JOIN tblCLASSROOM CR 
  ON B.BuildingID = CR.BuildingID
JOIN tblCLASS CS 
  ON CR.ClassroomID = CS.ClassroomID
JOIN tblCOURSE C 
  ON CS.CourseID = C.CourseID
JOIN tblDEPARTMENT D 
  ON C.DeptID = D.DeptID
JOIN tblCOLLEGE CO 
  ON D.CollegeID = CO.CollegeID
JOIN tblCLASS_LIST CL 
  ON CS.ClassID = CL.ClassID
WHERE CO.CollegeName in ('Engineering', 'Nursing', 'Pharmacy', 'Public Affairs (Evans School)')
GROUP BY L.LocationID, L.LocationName
ORDER BY SUM(CL.RegistrationFee) DESC;

