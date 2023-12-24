
---Процедура №1---
---Зміна кафедри викладача---
CREATE OR REPLACE PROCEDURE changeChairOfTeacher(teacherID INTEGER, newChairID INTEGER)
LANGUAGE plpgsql AS $$
DECLARE 
	oldChair INTEGER;
BEGIN
	IF EXISTS(SELECT 1 FROM Teacher WHERE Teacher.id = teacherID) AND
	EXISTS(SELECT 1 FROM Chair WHERE Chair.id = newChairID) THEN
		SELECT chair INTO oldChair FROM Teacher WHERE Teacher.id = teacherID;
		UPDATE Teacher SET Chair = newChairID WHERE Teacher.id = teacherID;
		RAISE NOTICE 'Teacher with id % has change chair from % to %', teacherID, oldChair, newChairID;
	ELSE
		RAISE NOTICE 'Chair or teacher is incorrect';
	END IF;
END;
$$;

INSERT INTO Teacher(id,firstname, lastname, patronymic, chair, educationaldegree, beginningworking)
VALUES (1555,'Joseph', 'Biden', 'Robinett',5, 1, '12-10-2023');
CALL changeChairOfTeacher(1555, 6);
DELETE FROM Teacher WHERE Teacher.id = 1555;



---Функція №2---
---Відображення штатного розкладу структурного підрозділу
CREATE OR REPLACE FUNCTION queryOfStaffDepartment(department INTEGER)
RETURNS TABLE("Teacher" TEXT, "Chair" VARCHAR(150), "Department" VARCHAR(150)) AS $$
BEGIN
	RETURN QUERY SELECT Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic AS "Teacher",
	Chair.name AS "Chair", StructureDepartment.name AS "Department"
	FROM Teacher
	JOIN Chair ON Chair.id = Teacher.chair
	JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
	WHERE StructureDepartment.id = department;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION queryOfStaffDepartment(department INTEGER);
SELECT * FROM queryOfStaffDepartment(1);


---Процедура №3---
---Зміна персональних даних студента за його ID та новими даними---
CREATE OR REPLACE PROCEDURE updateStudentPersonalData(studentID INTEGER, newFirstName VARCHAR(50), newSecondName VARCHAR(50), newPatronymic VARCHAR(50))
LANGUAGE plpgsql AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM Student WHERE Student.id = studentID) THEN
		UPDATE Student SET firstname = newFirstName,
		secondname = newSecondName, patronymic = newPatronymic
		WHERE id = studentID;
		RAISE NOTICE 'Name of student with id % changed to % % %', studentID, newSecondName, newFirstName, newPatronymic;
	ELSE
		RAISE NOTICE 'There is no student with such id';
	END IF;
END;
$$;

INSERT INTO Student(id, firstname, secondname, patronymic, academicgroup, dateofentry)
VALUES (5000, 'Donald', 'Trump', 'John', 34, '01-01-2021');
SELECT * FROM Student WHERE id = 5000;
CALL updateStudentPersonalData(5000, 'Michael', 'Pence', 'Richard');
SELECT * FROM Student WHERE id = 5000;

---Функція №4---
---Обрахувати кількість студентів для певного структурного підрозділу
---яка незадовільно склала семестровий контроль поточного року
CREATE OR REPLACE FUNCTION defineUnsuccessfulStudents(department INTEGER)
RETURNS INTEGER AS $$
DECLARE
	resultValue INTEGER;
BEGIN
	SELECT COUNT(Student.id) INTO resultValue
	FROM StructureDepartment
	JOIN Chair ON Chair.structureDepartment = StructureDepartment.id
	JOIN AcademicGroup ON AcademicGroup.chair = Chair.id
	JOIN Student ON Student.academicgroup = AcademicGroup.id
	JOIN "Control" ON Student.id = "Control".student
	WHERE StructureDepartment = department
	AND "Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeOfControl = 'Semester control')
	AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM "Control".dateOfControl)
	AND "Control".attestation = FALSE;
	
	RETURN resultValue;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM defineUnsuccessfulStudents(5);


---Функція №5----
---Повернути таблицю, де будуть показані викладачі з вказаним
---вченим званням та стажем роботи для конкретного структурного підрозділу
CREATE OR REPLACE FUNCTION queryDefinedStaffDepartment(department INTEGER, experineceValue INTEGER, degreeID INTEGER)
RETURNS TABLE("Department" VARCHAR(150), "Teacher" TEXT, "Degree" VARCHAR(100), "Experience" NUMERIC) AS $$
BEGIN
	RETURN QUERY SELECT StructureDepartment.name AS "Department",
	Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic AS "Teacher",
	EducationalDegree.educationaldegree AS "Degree",
	EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) AS "Experience"
	FROM StructureDepartment
	JOIN Chair ON Chair.structuredepartment = StructureDepartment.id
	JOIN Teacher ON Teacher.chair = Chair.id
	JOIN EducationalDegree ON EducationalDegree.id = Teacher.educationalDegree
	WHERE StructureDepartment.id = department 
	AND EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) >= experineceValue
	AND Teacher.educationalDegree = degreeID;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM queryDefinedStaffDepartment(
	(SELECT StructureDepartment.id FROM StructureDepartment WHERE StructureDepartment.name = 'Institute of Aerospace Technologies')::INTEGER,
	12,
	(SELECT EducationalDegree.id FROM EducationalDegree WHERE educationaldegree = 'Senior Lecturer')::INTEGER
);


---Процедура №6---
---Виставлення оцінки студенту по певному виду контролю
---Вхідними параметрами будуть id студента, дата контролю
---id предмета, id викладача та оцінка, id контролю
CREATE OR REPLACE PROCEDURE createMarkForStudent(
	studentID INTEGER, 
	requiredDate DATE,
	subjectID INTEGER,
	teacherID INTEGER,
	markScore INTEGER,
	controlID INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
	markID INTEGER;
BEGIN
	IF controlID != (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Semester control') 
	AND controlID != (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Calendar control')
	THEN
		IF NOT EXISTS(SELECT 1 FROM Student WHERE Student.id = studentID) THEN
			RAISE NOTICE 'There is no such student in table.';
			RETURN;
		ELSIF NOT EXISTS(SELECT 1 FROM Subject WHERE Subject.id = subjectID) THEN
			RAISE NOTICE 'There is no such subject in table.';
			RETURN;
		ELSIF NOT EXISTS(SELECT 1 FROM Teacher WHERE Teacher.id = teacherID) THEN
			RAISE NOTICE 'There is no such teacher in table.';
			RETURN;
		ELSIF NOT EXISTS(SELECT 1 FROM TypeOfControl WHERE TypeOfControl.id = controlID) THEN
			RAISE NOTICE 'There is no such type of control in table.';
			RETURN;
		ELSIF markScore < 0 OR markScore > 100 THEN
			RAISE NOTICE 'Mark is not in required diapason.';
		ELSE
			SELECT id INTO markID FROM Mark WHERE Mark.score = markScore AND Mark.isResultingMark = FALSE;
			INSERT INTO "Control"(student, dateofcontrol, subject, teacher, mark, typeofcontrol) VALUES
			(studentID, requiredDate, subjectID, teacherID, markID, controlID);
			RAISE NOTICE 'New data about student control is created.';
			RAISE NOTICE 'Control id: %',
			(SELECT id FROM "Control" WHERE student = studentID AND teacher = teacherID
			AND subject = subjectID AND mark = markID AND typeofcontrol = controlID AND
			dateofcontrol = requiredDate);
			RAISE NOTICE 'Student: %', 
			(SELECT Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic FROM Student
			 WHERE Student.id = studentID);
			RAISE NOTICE 'Teacher: %',
			(SELECT Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic FROM Teacher WHERE
			Teacher.id = teacherID);
			RAISE NOTICE 'Subject: %', (SELECT Subject.name FROM Subject WHERE Subject.id = subjectID);
			RAISE NOTICE 'Event: %', (SELECT TypeOfControl.typeofcontrol FROM TypeOfControl WHERE TypeOfControl.id = controlID);
			RAISE NOTICE 'Mark: %', markScore;
		END IF;
	ELSE
		RAISE NOTICE 'You can not set numeric marks for calendar and semester control';
	END IF;
END;
$$;

CALL createMarkForStudent(
	1, '2023-01-01', 3, 3, 15, 2
);


---Процедура №7---
---Залікова книжка студента---
CREATE OR REPLACE PROCEDURE studentRecordBook(studentID INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
	recordBookCursor CURSOR FOR
	SELECT Subject.name AS "Subject",
	"Control".dateofcontrol AS "Date",
	Mark.score AS "Total score",
	Mark.markECTS AS "ECTS"
	FROM "Control"
	JOIN Subject ON Subject.id = "Control".subject
	JOIN Mark ON "Control".mark = Mark.id
	WHERE "Control".student = studentID
	AND "Control".typeofcontrol = (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Exam');
	
	recordBookRecord RECORD;
BEGIN
	OPEN recordBookCursor;
	
	RAISE NOTICE 'Record book of %',
	(SELECT Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic
	FROM Student WHERE Student.id = studentID);
	LOOP
		FETCH recordBookCursor INTO recordBookRecord;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE 'Subject: % | Date: % | Score: % | ECTS: % ',
		recordBookRecord."Subject", recordBookRecord."Date",
		recordBookRecord."Total score", recordBookRecord."ECTS";
	END LOOP;
	
	CLOSE recordBookCursor;
END;
$$;

CALL studentRecordBook(55);


---Процедура №8---
---Пошук студента за його персональними параметрами
---Якщо відповідне ім'я існує, то відобразиться необхідна інформація про студента
---Якщо ні, то процедура відобразить відповідне повідомлення
CREATE OR REPLACE PROCEDURE findStudent(f_secondName VARCHAR(50), f_firstName VARCHAR(50), f_patronymic VARCHAR(50))
LANGUAGE plpgsql AS $$
DECLARE
	studentRecord RECORD;
BEGIN
	IF EXISTS(SELECT 1 FROM Student WHERE firstname = f_firstname 
			  AND secondname = f_secondname 
			  AND patronymic = f_patronymic) THEN
			  SELECT Student.secondName || ' ' || Student.firstName || ' ' || Student.patronymic AS "Student",
			  AcademicGroup.name AS "Group", Chair.name AS "Chair", StructureDepartment.name AS "Department"
			  INTO studentRecord
			  FROM Student
			  JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
			  JOIN Chair ON Chair.id = AcademicGroup.chair
			  JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
			  WHERE firstname = f_firstname 
			  AND secondname = f_secondname 
			  AND patronymic = f_patronymic;
			  RAISE NOTICE 'Student: %', studentRecord."Student";
			  RAISE NOTICE 'Group: %', studentRecord."Group";
			  RAISE NOTICE 'Chair: %', studentRecord."Chair";
			  RAISE NOTICE 'Structure Department: %', studentRecord."Department";
	ELSE
		RAISE NOTICE 'There is no such student in University.';
	END IF;
END;
$$;

DROP PROCEDURE findStudent(f_secondName VARCHAR(50), f_firstName VARCHAR(50), f_patronymic VARCHAR(50));
CALL findStudent('Henstone','Henry','Sobtka');


---Функція №9---
---Повертає кількість студентів, які незадовільно склали
---екзамени та підлягають відрахуванню

CREATE OR REPLACE FUNCTION countDismissalStudents()
RETURNS INTEGER AS $$
DECLARE
	resultVariable INTEGER;
BEGIN
	SELECT COUNT(DISTINCT Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic)
	INTO resultVariable
	FROM "Control"
	JOIN Student ON Student.id = "Control".student
	JOIN Mark ON Mark.id = "Control".mark
	WHERE "Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Exam')
	AND Mark.score < 60
	AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM "Control".dateofcontrol);
	RETURN resultVariable;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM countDismissalStudents();

---Процедура №10---
---Відобразити всю необхідну контактну інформацію про університет
CREATE OR REPLACE PROCEDURE universityInfo()
LANGUAGE plpgsql AS $$
DECLARE
	amountOfFaculties INTEGER;
	amountOfInsistutes INTEGER;
	amountOfColleges INTEGER;
	amountOfProjInst INTEGER;
	departmentCursor CURSOR FOR
	SELECT StructureDepartment.name AS "Department",
	StructureDepartment.phoneNumber AS "Phone Number",
	StructureDepartment.website AS "Website",
	StructureDepartment.email AS "Email",
	TypeOfDepartment.type AS "Type"
	FROM StructureDepartment
	JOIN TypeOfDepartment ON TypeOfDepartment.id = StructureDepartment.type;
	departmentRecord RECORD;
BEGIN
	SELECT COUNT(*) INTO amountOfFaculties FROM StructureDepartment 
	WHERE type = (SELECT id FROM TypeOfDepartment WHERE type = 'Faculty');
	SELECT COUNT(*) INTO amountOfInsistutes FROM StructureDepartment 
	WHERE type = (SELECT id FROM TypeOfDepartment WHERE type = 'Research and Educational Institute');
	SELECT COUNT(*) INTO amountOfColleges FROM StructureDepartment 
	WHERE type = (SELECT id FROM TypeOfDepartment WHERE type = 'Vocational College');
	SELECT COUNT(*) INTO amountOfProjInst FROM StructureDepartment 
	WHERE type = (SELECT id FROM TypeOfDepartment WHERE type = 'Projecting Institute');
	
	RAISE NOTICE 'Information about University';
	RAISE NOTICE 'Faculties: %', amountOfFaculties;
	RAISE NOTICE 'Insitutes: %', amountOfInsistutes;
	RAISE NOTICE 'Colleges: %', amountOfColleges;
	RAISE NOTICE 'Projectin institues: %', amountOfProjInst;
	
	OPEN departmentCursor;
	
	LOOP
		FETCH departmentCursor INTO departmentRecord;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '--------------------------------';
		RAISE NOTICE '%', departmentRecord."Department";
		RAISE NOTICE '%', departmentRecord."Phone Number";
		RAISE NOTICE '%', departmentRecord."Website";
		RAISE NOTICE '%', departmentRecord."Email";
		RAISE NOTICE '%', departmentRecord."Type";
	END LOOP;
	
	CLOSE departmentCursor;
END;
$$;

CALL universityInfo();