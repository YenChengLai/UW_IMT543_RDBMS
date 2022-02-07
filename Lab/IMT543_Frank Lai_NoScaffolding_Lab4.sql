
/*
Q1: Write the SQL to create a stored procedure to UPDATE the BeginDate column in the 
-- STUDENT_DORMROOM table. USE THROW error-handling if variable is NULL.
*/

CREATE PROCEDURE uspUPDATE_BeginDate
@StudentFname VARCHAR(60),
@StudentLname VARCHAR(60),
@StudentBirth DATE,
@DormRoomNumber VARCHAR(50),
@DormRoomTypeName VARCHAR(50),
@BuildingName VARCHAR(125),
@OldDate DATE,
@NewDate DATE
AS
DECLARE @SDR_ID INT

SET @SDR_ID = (SELECT SDR.StudentDormRoomID
               FROM tblSTUDENT_DORMROOM SDR
               JOIN tblSTUDENT S 
                 ON SDR.StudentID = S.StudentID
               JOIN tblDORMROOM DR 
                 ON SDR.DormRoomID = DR.DormRoomID
               JOIN tblDORMROOM_TYPE DRT
                 ON DR.DormRoomTypeID = DRT.DormRoomTypeID
               JOIN tblBUILDING B 
                 ON DR.BuildingID = B.BuildingID
               WHERE SDR.BeginDate = @OldDate
                 AND S.StudentFname = @StudentFname
                 AND S.StudentLname = @StudentLname
                 AND S.StudentBirth = @StudentBirth
                 AND DR.DormRoomNumber = @DormRoomNumber
                 AND DRT.DormRoomTypeName = @DormRoomTypeName
                 AND B.BuildingName = @BuildingName)

IF @SDR_ID IS NULL
	BEGIN
		PRINT 'Variable has come back NULL; check spelling of all parameters';
		THROW 55555, 'StudentDormRoomID cannot be NULL; process is terminating', 1; 
		RETURN
	END


UPDATE tblStudent_DORMROOM
SET BeginDate = @NewDate
WHERE StudentDormRoomID = @SDR_ID
GO

/*
Q2: Write the SQL to create a stored procedure to DELETE a row in the STUDENT_DORMROOM table.
-- USE RAISERROR error-handling if any variable is NULL.
*/

CREATE PROCEDURE uspDELETE_StudentDormroom
@StudentFname VARCHAR(60),
@StudentLname VARCHAR(60),
@StudentBirth DATE,
@DormRoomNumber VARCHAR(50),
@DormRoomTypeName VARCHAR(50),
@BuildingName VARCHAR(125)
AS
DECLARE @SDR_ID INT

SET @SDR_ID = (SELECT SDR.StudentDormRoomID
               FROM tblSTUDENT_DORMROOM SDR
               JOIN tblSTUDENT S 
                 ON SDR.StudentID = S.StudentID
               JOIN tblDORMROOM DR 
                 ON SDR.DormRoomID = DR.DormRoomID
               JOIN tblDORMROOM_TYPE DRT
                 ON DR.DormRoomTypeID = DRT.DormRoomTypeID
               JOIN tblBUILDING B 
                 ON DR.BuildingID = B.BuildingID
               WHERE S.StudentFname = @StudentFname
                 AND S.StudentLname = @StudentLname
                 AND S.StudentBirth = @StudentBirth
                 AND DR.DormRoomNumber = @DormRoomNumber
                 AND DRT.DormRoomTypeName = @DormRoomTypeName
                 AND B.BuildingName = @BuildingName)

IF @SDR_ID IS NULL
	BEGIN
    PRINT 'Variable has come back NULL; check spelling of all parameters'
    RAISERROR ('StudentDormRoomID cannot be NULL; process is terminating', 11, 1)
    RETURN
  END

DELETE FROM tblSTUDENT_DORMROOM
WHERE StudentDormRoomID = @SDR_ID
GO

/*
Q3: Write the SQL to create a stored procedure to INSERT a row in the DEPARTMENT table.
USE THROW error-handling if variable is NULL.
*/

CREATE PROCEDURE uspINSERT_Department
@DeptName VARCHAR(75),
@CollegeName VARCHAR(125)
AS
  DECLARE @C_ID INT

SET @C_ID = (SELECT CollegeID
               FROM tblCOLLEGE
               WHERE CollegeName = @CollegeName)
IF @C_ID IS NULL
  BEGIN
    PRINT 'Variable has come back NULL; check spelling of all parameters';
		THROW 55555, 'CollegeID cannot be NULL; process is terminating', 1; 
		RETURN
  END

INSERT INTO tblDEPARTMENT (DeptName, CollegeID)
VALUES (@DeptName, @C_ID)
GO

/*
Q4: Write the SQL to create a stored procedure to UPDATE the DeptDescr column in the DEPARTMENT table.
Use RAISERROR method of error-handling if variable is NULL.
*/

GO
CREATE PROCEDURE uspUPDATE_Department
@DeptDescr VARCHAR(500),
@DeptName VARCHAR(75),
@CollegeName VARCHAR(125)
AS
  DECLARE @DeptID INT 

SET @DeptID = (SELECT D.DeptID 
               FROM tblDEPARTMENT D
               JOIN tblCOLLEGE C 
                 ON D.CollegeID = C.CollegeID
               WHERE D.DeptName = @DeptName
                 AND C.CollegeName = @CollegeName)

IF @DeptID IS NULL
	BEGIN
    PRINT 'Variable has come back NULL; check spelling of all parameters'
    RAISERROR ('DeptID cannot be NULL; process is terminating', 11, 1)
    RETURN
  END
UPDATE tblDEPARTMENT
SET DeptDescr = @DeptDescr
WHERE DeptID = @DeptID
GO

/*
Q5: Write the SQL to create a stored procedure to DELETE a row in the DEPARTMENT table.
*/

CREATE PROCEDURE uspDELETE_Department
@DeptName VARCHAR(75),
@CollegeName VARCHAR(125)
AS
  DECLARE @DeptID INT 

SET @DeptID = (SELECT D.DeptID 
               FROM tblDEPARTMENT D
               JOIN tblCOLLEGE C 
                 ON D.CollegeID = C.CollegeID
               WHERE D.DeptName = @DeptName
                 AND C.CollegeName = @CollegeName)

IF @DeptID IS NULL
	BEGIN
    PRINT 'Variable has come back NULL; check spelling of all parameters'
    RAISERROR ('DeptID cannot be NULL; process is terminating', 11, 1)
    RETURN
  END

DELETE FROM tblDEPARTMENT
WHERE DeptID = @DeptID
GO

/*
Q6: Write the SQL query to determine which classes meet all of the following conditions: 
1) have associate professors that taught a philosophy class in the last 7 years
2) are part of department that have more than 3 students living in a double dorm room type.
*/

SELECT DISTINCT(CS.ClassID)
FROM tblCLASS CS
JOIN tblCOURSE C 
  ON CS.CourseID = C.CourseID
JOIN tblINSTRUCTOR_CLASS IC
  ON CS.ClassID = IC.ClassID
JOIN tblINSTRUCTOR I 
  ON IC.InstructorID = I.InstructorID
JOIN tblINSTRUCTOR_INSTRUCTOR_TYPE IIT 
  ON I.InstructorID = IIT.InstructorID
JOIN tblINSTRUCTOR_TYPE IT 
  ON IIT.InstructorTypeID = IT.InstructorTypeID
JOIN (
  SELECT DISTINCT(CS.ClassID)
  FROM tblCLASS CS 
  JOIN tblCOURSE C
    ON CS.CourseID = C.CourseID
  JOIN tblDEPARTMENT D 
    ON C.DeptID = D.DeptID
  JOIN tblCLASS_LIST CL
    ON CS.ClassID = CL.ClassID
  JOIN tblSTUDENT S 
    ON CL.StudentID = S.StudentID
  JOIN tblSTUDENT_DORMROOM SD 
    ON S.StudentID = SD.StudentID
  JOIN tblDORMROOM DR 
    ON SD.DormRoomID = DR.DormRoomID
  JOIN tblDORMROOM_TYPE DRT
    ON DR.DormRoomTypeID = DRT.DormRoomTypeID
  WHERE DRT.DormRoomTypeName = 'Double'
  GROUP BY D.DeptID, CS.ClassID
  HAVING COUNT(S.StudentID) > 3
) SUB1
  ON CS.ClassID = SUB1.ClassID
WHERE C.CourseName like 'PHIL%'
  AND IT.InstructorTypeName = 'Associate Professor'
  AND CS.[YEAR] BETWEEN YEAR(GETDATE()) - 7 AND YEAR(GETDATE());
