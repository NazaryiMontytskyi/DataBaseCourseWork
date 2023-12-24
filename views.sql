---ПРЕДСТАВЛЕННЯ---

---Представлення №1---
---Представлення списку студентів, що числяться
---в групі HA-21
CREATE VIEW HA21Students AS
SELECT Student.id,
Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic AS "Name"
FROM Student WHERE academicGroup = (SELECT id FROM AcademicGroup WHERE name = 'HA-21');

SELECT * FROM HA21Students;


---Представлення №2---
---Представлення студентів структурного підрозділу, що склали
---екзамени на оцінки щонайменше на В.
CREATE VIEW FICSBestStudents AS
SELECT Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic AS "Student",
AcademicGroup.name AS "Group", (SELECT Subject.name FROM Subject WHERE Subject.id = "Control".subject) AS "Subject", Mark.markECTS AS "Mark"
FROM "Control"
JOIN Student ON "Control".student = Student.id
JOIN AcademicGroup ON AcademicGroup.id = Student.academicGroup
JOIN Chair ON Chair.id = AcademicGroup.chair
JOIN StructureDepartment ON StructureDepartment.id = Chair.structureDepartment
JOIN Mark ON "Control".mark = Mark.id
WHERE StructureDepartment.id = (SELECT id FROM StructureDepartment WHERE name = 'Faculty of Informatics and Computer Science')
AND "Control".typeofcontrol = (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Exam')
AND Mark.score >= (SELECT MIN(score) FROM Mark WHERE markECTS = 'B');

SELECT * FROM FICSBestStudents;

---Представлення №3---
---Представлення викладачів структурного підрозділу, що мають
---робочий стаж більше 15 років
CREATE VIEW IPSAHighEmployee AS
SELECT Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic AS "Employee",
(SELECT educationalDegree FROM EducationalDegree WHERE id = Teacher.educationalDegree) AS "Degree",
EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) AS "Experience"
FROM Teacher
JOIN Chair ON Chair.id = Teacher.chair
JOIN StructureDepartment ON Chair.structuredepartment = StructureDepartment.id
WHERE EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) >= 15
AND StructureDepartment.id = (SELECT id FROM StructureDepartment WHERE name = 'Institute for Applied Systems Analysis')

SELECT * FROM IPSAHighEmployee;


---Представлення №4---
---Відображення всіх типів контролів, які проводилися з певного предмету---
CREATE VIEW HOUControlType AS
SELECT DISTINCT TypeOfControl.typeofcontrol, (SELECT Subject.name FROM Subject WHERE "Control".subject = Subject.id) 
FROM "Control"
JOIN TypeOfControl ON "Control".typeofcontrol = TypeOfControl.id
WHERE "Control".subject = (SELECT id FROM Subject WHERE name = 'History of Ukraine');

SELECT * FROM HOUControlType;


---Представлення №5---
---Відображення академічних кураторів груп окремої кафедри
CREATE VIEW LawDepartmentCurators AS
SELECT Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic AS "Curator",
AcademicGroup.name AS "Group", Chair.name AS "Chair"
FROM AcademicGroup
JOIN Teacher ON Teacher.id = AcademicGroup.academiccurator
JOIN Chair ON Chair.id = AcademicGroup.chair
WHERE Chair.id = (SELECT id FROM Chair WHERE name = 'Law Department');

SELECT * FROM LawDepartmentCurators;