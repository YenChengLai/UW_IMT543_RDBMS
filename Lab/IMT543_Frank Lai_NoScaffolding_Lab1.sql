

/*
1) Write the SQL code to determine who the oldest student from California, Texas, or Washington who has a LastName beginning with the letter 'M'
*/

SELECT TOP(1)* 
FROM tblSTUDENT 
WHERE StudentPermState in ('California, CA', 'Texas, TX', 'Washington, WA')
  AND StudentLname like 'M%'
  ORDER BY StudentBirth ASC;

/*
2) Write the SQL to determine which states have at least 6,500 students born before 1956
*/

SELECT StudentPermState, COUNT(StudentID) AS StudentCount
FROM  (
    SELECT * 
    FROM tblSTUDENT
    WHERE StudentBirth <= '1955-12-31'
) S
GROUP BY StudentPermState
HAVING COUNT(StudentID) >= 6500;

/*
3) Write SQL query to determine the number of students who have received a grade of exactly 3.7 for any class from the Department of Anthropology since 1963. 

DISTINCT keyword will change results by eliminating duplicate rows!
*/
SELECT COUNT(DISTINCT(S.StudentID)) AS StudentNumber
FROM tblSTUDENT Ｓ
INNER JOIN tblCLASS_LIST CL
  ON S.StudentID = CL.StudentID
INNER JOIN tblCLASS CS
  ON CL.ClassID = CS.ClassID
INNER JOIN tblCOURSE course
  ON CS.CourseID = course.CourseID
INNER JOIN tblDEPARTMENT D
  ON course.DeptID = D.DeptID
WHERE CL.Grade = 3.7
  AND D.DeptName = 'Anthropology'
  AND CS.[YEAR] > '1962';


/*
4) Write the SQL code to determine the 12 most popular courses in the College of Engineering by number of registrations between 1998 and 2015.
*/

SELECT TOP(12) CR.CourseName, COUNT(CL.StudentID) AS RegistrationNumbers
FROM tblCOURSE CR
INNER JOIN tblDEPARTMENT D
  ON CR.DeptID = D.DeptID
INNER JOIN tblCOLLEGE C
  ON D.CollegeID = C.CollegeID
INNER JOIN tblCLASS CS
  ON CR.CourseID = CS.CourseID
INNER JOIN tblCLASS_LIST CL
  ON CS.ClassID = CL.ClassID
WHERE C.CollegeName = 'Engineering'
  AND CL.RegistrationDate BETWEEN '1998-01-01' AND '2015-12-31'
GROUP BY CR.CourseName
ORDER BY RegistrationNumbers DESC;

/*
5) Write the SQL to determine which courses generated more than XXX in total registration fees for classes held in 
either Johnson Hall or Mary Gates Hall before June 3, 2013.
*/

SELECT C.CourseName, SUM(CL.RegistrationFee) AS 'Total Registration Fees'
FROM tblCLASS CS
INNER JOIN tblCLASS_LIST CL
  ON CS.ClassID = CL.ClassID
INNER JOIN tblCOURSE C 
  ON CS.CourseID = C.CourseID
INNER JOIN tblCLASSROOM CR
  ON CS.ClassroomID = CR.ClassroomID
INNER JOIN tblBUILDING B
  ON CR.BuildingID = B.BuildingID
WHERE B.BuildingName in ('Mary Gates Hall', 'Johnson Hall')
  AND CL.RegistrationDate < '2013-06-03'
GROUP BY C.CourseName
HAVING SUM(CL.RegistrationFee) > 'XXX';

/*
6) Write the SQL to determine average registration fee for a 4 credit course held on Stevens Way in the 1980's
*/

SELECT AVG(CL.RegistrationFee) AS 'Average Registration Fee'
FROM tblCLASS_LIST CL
INNER JOIN tblCLASS CS
  ON CL.ClassID = CS.ClassID
INNER JOIN tblCOURSE C
  ON CS.CourseID = C.CourseID
INNER JOIN tblCLASSROOM CR
  ON CS.ClassroomID = CR.ClassroomID
INNER JOIN tblBUILDING B
  ON CR.BuildingID = B.BuildingID
INNER JOIN tblLOCATION L 
  ON B.LocationID = L.LocationID
WHERE C.Credits = 4
  AND L.LocationName = 'Stevens Way'
  AND CS.[YEAR] BETWEEN 1980 AND 1989;

/*
7) Write the SQL to determine how many students born between November 15, 1986 and July 2, 1991 finished a class from College of Medicine with at least a 3.8 grade in any Spring quarter after 2011?
*/

SELECT COUNT(DISTINCT(Ｓ.StudentID)) AS StudentCount
FROM tblSTUDENT S
INNER JOIN tblCLASS_LIST CL
  ON Ｓ.StudentID = CL.StudentID
INNER JOIN tblCLASS CS
  ON CL.ClassID = CS.ClassID
INNER JOIN tblCOURSE C 
  ON CS.CourseID = C.CourseID
INNER JOIN tblDEPARTMENT D
  ON C.DeptID = D.DeptID
INNER JOIN tblCOLLEGE CO
  ON D.CollegeID = CO.CollegeID
INNER JOIN tblQUARTER Q
  ON CS.QuarterID = Q.QuarterID
WHERE S.StudentBirth BETWEEN '1986-11-15' AND '1991-07-02'
  AND CO.CollegeName = 'Medicine'
  AND CL.Grade >= 3.8
  AND Q.QuarterName = 'Spring'
  AND CS.[YEAR] > 2011;

/*
8) Write the SQL to determine which colleges had at least 300 classes offered Autumn quarter 2016?
*/

SELECT CO.CollegeName, COUNT(DISTINCT(CS.CourseID)) AS 'Classes Offered'
FROM tblCOLLEGE CO
INNER JOIN tblDEPARTMENT D
  ON CO.CollegeID = D.CollegeID
INNER JOIN tblCOURSE CR
  ON D.DeptID = CR.DeptID
INNER JOIN tblCLASS CS
  ON CR.CourseID = CS.CourseID
INNER JOIN tblQUARTER Q
  ON CS.QuarterID = Q.QuarterID
WHERE CS.[Year] = '2016'
  AND Q.QuarterName = 'Autumn'
GROUP BY CO.CollegeName
HAVING COUNT(distinct CS.CourseID) >= 300;