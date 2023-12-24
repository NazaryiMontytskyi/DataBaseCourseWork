----###ЗАПИТ №1###----
--Визначити студентів структурного підрозділу Х, які склали екзамени у 2022 році
--на незадовільну оцінку
--Візьмемо структурний підрозділ з id = 10
SELECT StructureDepartment.name AS "Department",
Student.firstName || ' ' || Student.secondName AS "Student name",
AcademicGroup.name AS "Group", 
Subject.name AS "Discipline",
Mark.markECTS AS "Resulting Mark"
FROM StructureDepartment
JOIN Chair ON Chair.structuredepartment = StructureDepartment.id
JOIN AcademicGroup ON AcademicGroup.chair = Chair.id
JOIN Student ON Student.academicgroup = AcademicGroup.id
JOIN "Control" ON "Control".student = Student.id
JOIN Mark ON "Control".mark = Mark.id
JOIN TypeOfControl ON "Control".typeofcontrol = TypeOfControl.id
JOIN Subject ON "Control".subject = Subject.id
WHERE Chair.structuredepartment = 10 AND Mark.score < 60 AND "Control".typeOfControl = 4
AND EXTRACT(YEAR FROM "Control".dateOfControl) = 2022;


----###ЗАПИТ №2###----
--Відобразити групи та кількість їх студентів структурного підрозділу 
--Х за спаданням (від більшого до меншого)
--Для прикладу візьмемо структурний підрозділ з id = 25
SELECT
StructureDepartment.name,
AcademicGroup.name AS "Group",
COUNT(Student.id) AS "Amount of students"
FROM Student
JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
JOIN Chair ON Chair.id = AcademicGroup.chair
JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
WHERE StructureDepartment.id = 25
GROUP BY AcademicGroup.name, StructureDepartment.name
ORDER BY "Amount of students" DESC;


----###ЗАПИТ №3###----
---Відобразити викладачів кафедри Х,які викладають на цій
---кафедрі більше 10 років, їх імена, час роботи на кафедрі
SELECT Chair.name, Teacher.firstName || ' ' || Teacher.lastName,
EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningWorking) AS Experience
FROM Chair
JOIN Teacher ON Teacher.chair = Chair.id
WHERE Chair = 66 AND 
EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningWorking) >= 10;


----###ЗАПИТ №4###----
--Відобразити дисципліни викладача X, по яким він проводив весняний календарний контроль 2023 року
SELECT DISTINCT Subject.name,
Teacher.firstName || ' ' || Teacher.lastName AS "Teacher name",
"Control".dateOfControl,
(SELECT typeOfControl FROM TypeOfControl WHERE id = (SELECT id FROM TypeOfControl WHERE typeOfControl = 'Calendar control'))
FROM "Control"
JOIN Subject ON "Control".subject = Subject.id
JOIN Teacher ON "Control".teacher = Teacher.id
WHERE Teacher.id = 55 AND 
"Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeOfControl = 'Calendar control')
AND EXTRACT(YEAR FROM "Control".dateOfControl) = 2023 AND EXTRACT(MONTH FROM "Control".dateOfControl) = 3;


----###ЗАПИТ №5### (з підзапитом)----
---Відобразити дисципліну з найбільшою кількістю студентів, які склали по ній осінній
---календарний контроль 2022 року.
WITH CalendarControl2022 AS(
	SELECT Subject.id AS idSubject, 
	Subject.name AS nameSubject, 
	COUNT(Student.id) AS "Amount of students"
	FROM "Control"
	JOIN Subject ON "Control".subject = Subject.id
	JOIN Student ON "Control".student = Student.id
	WHERE EXTRACT(YEAR FROM "Control".dateOfControl) = 2022 AND EXTRACT(MONTH FROM "Control".dateOfControl) = 10
	AND "Control".attestation = TRUE
	GROUP BY Subject.id, "Control".typeOfControl, "Control".dateOfControl
	ORDER BY "Amount of students" DESC
)
SELECT CalendarControl2022.idSubject, CalendarControl2022.nameSubject, CalendarControl2022."Amount of students"
FROM CalendarControl2022 
WHERE CalendarControl2022."Amount of students" = (SELECT MAX(CalendarControl2022."Amount of students") FROM CalendarControl2022);


----###ЗАПИТ №6###----
---Відобразити всіх професорів університету (ім'я, структурний підрозділ, кафедра та їх вчене звання)
SELECT Teacher.firstname || ' ' || Teacher.lastname || ' ' || Teacher.patronymic AS "Teacher name",
EducationalDegree.educationalDegree AS "Degree", StructureDepartment.name AS "Structure Department",
Chair.name AS "Chair"
FROM StructureDepartment
JOIN Chair ON Chair.structureDepartment = StructureDepartment.id
JOIN Teacher ON Teacher.chair = Chair.id
JOIN EducationalDegree ON Teacher.educationalDegree = EducationalDegree.id
WHERE EducationalDegree.id = 
(SELECT EducationalDegree.id FROM EducationalDegree WHERE EducationalDegree = 'Professor');


----###ЗАПИТ №7###----
----Відобразити імена студентів, які склали модульну контрольну роботу з дисципліни "Історія України"
----де оцінка приймає значення в діапазоні від 25 до 40 балів.
SELECT Student.firstName || ' ' || Student.secondName || ' ' || Student.patronymic AS "Student",
Mark.score AS "Mark", Subject.name AS "Subject"
FROM "Control" 
JOIN Student ON "Control".student = Student.id
JOIN Subject ON "Control".subject = Subject.id
JOIN Mark ON "Control".mark = Mark.id
WHERE 
"Control".typeOfControl = 
(SELECT TypeOfControl.id FROM TypeOfControl WHERE TypeOfControl.typeOfControl = 'Module controling work')
AND "Control".subject = (SELECT Subject.id FROM Subject WHERE Subject.name = 'History of Ukraine')
AND "Control".mark BETWEEN (SELECT Mark.id FROM Mark WHERE score = 25 AND isResultingMark = FALSE) AND
(SELECT Mark.id FROM Mark WHERE score = 40 AND isResultingMark = FALSE);


----###ЗАПИТ №8###----
----Відобразити найкращого студента в університеті, що має найбільший середній бал
WITH UniversityAverageMark AS(
SELECT Student.id AS "StudentID", Student.firstName || ' ' || Student.secondName || ' ' || Student.patronymic AS "Student",
AcademicGroup.name AS "Group",
AVG(score) AS "Average mark", StructureDepartment.name AS "Structure Department"
FROM "Control"
JOIN Student ON "Control".student = Student.id
JOIN Mark ON "Control".mark = Mark.id
JOIN AcademicGroup ON Student.academicgroup = AcademicGroup.id
JOIN Chair ON Chair.id = AcademicGroup.chair
JOIN StructureDepartment ON Chair.structuredepartment = StructureDepartment.id
GROUP BY Student.id, "Student", AcademicGroup.id, StructureDepartment.name)
SELECT UniversityAverageMark."StudentID", UniversityAverageMark."Student", UniversityAverageMark."Group",
MAX(UniversityAverageMark."Average mark") AS "Max mark", UniversityAverageMark."Structure Department"
FROM UniversityAverageMark WHERE UniversityAverageMark."Average mark" = 
(SELECT MAX(UniversityAverageMark."Average mark") FROM UniversityAverageMark)
GROUP BY UniversityAverageMark."StudentID", UniversityAverageMark."Student", UniversityAverageMark."Group",
UniversityAverageMark."Structure Department";


----###ЗАПИТ №9###----
----Відобразити всіх академічних кураторів груп кафедри Х, які працюють на цій кафедрі більше ніж 5 років
----Візьмемо Кафедру права ('Law Department')
SELECT AcademicGroup.name AS "Group",
Teacher.firstName || ' ' || Teacher.lastname AS "Curator",
Chair.name AS "Chair",
EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) AS "Experience"
FROM AcademicGroup
JOIN Teacher ON AcademicGroup.academiccurator = Teacher.id
JOIN Chair ON Chair.id = AcademicGroup.chair
WHERE Chair.id = (SELECT Chair.id FROM Chair WHERE Chair.name = 'Law Department')
AND EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Teacher.beginningworking) >= 5;


----###ЗАПИТ №10###----
----Відобразити сумарну оцінку студентів певної групи, яку потрібно відсортувати за
----спаданням по оцінкам. Якщо кількість балів студента не задовільна для виставлення
----оцінки по дисципліні, то відобразити у комірці "Додаткова сесія", а якщо задовільна,
----то відобразити "Основна сесія"
----В якості групи візьмемо групу з id 125
----В якості дисципліни візьмемо
SELECT Student.firstname || ' ' || Student.secondname AS "Student",
Subject.name AS "Subject",
Mark.score AS "Mark",
Mark.markECTS AS "ECTS",
CASE
	WHEN Mark.score >= 60 THEN 'Default session'
	ELSE 'Extra session'
END AS "Session"
FROM "Control"
JOIN Student ON Student.id = "Control".student
JOIN AcademicGroup ON Student.academicgroup = AcademicGroup.id
JOIN Mark ON "Control".mark = Mark.id
JOIN Subject ON "Control".subject = Subject.id
WHERE AcademicGroup.id = 125
AND "Control".typeOfControl = (SELECT TypeOfControl.id FROM TypeOfControl WHERE TypeOfControl.typeOfControl = 'Exam')
GROUP BY "Student", Subject.name, Mark.markECTS, "Session", Mark.score 
ORDER BY Mark.score DESC;


----###ЗАПИТ №11###----
----Відобразити відомість про залікову книжку студента, який навчається
----у структурному підрозділі А, на кафедрі В, у групі С
SELECT Student.id AS "Student ID",
Student.secondname || ' ' || Student.firstname || ' ' || Student.patronymic AS "Student",
Subject.name AS "Subject",
Mark.score AS "Grade mark",
Mark.markECTS AS "Result mark",
Mark.nationalMark AS "National grade",
Chair.name AS "Chair",
StructureDepartment.name AS "Structure Department"
FROM "Control"
JOIN Student ON "Control".student = Student.id
JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
JOIN Chair ON AcademicGroup.chair = Chair.id
JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
JOIN Mark ON Mark.id = "Control".mark
JOIN Subject ON Subject.id = "Control".subject
WHERE StructureDepartment.id = 1 AND 
"Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeOfControl = 'Exam')
AND Student.id = 2816
AND Chair.id = 1;


----###ЗАПИТ №12###----
----Відобразити всі можливі комбінації, де певний студент міг би обрати конкретний
----структурний підрозділ та конкретну кафедру цього структурного підрозділу
SELECT Student.id, Student.secondname, StructureDepartment.name, Chair.name FROM Student
CROSS JOIN StructureDepartment
JOIN Chair ON Chair.structureDepartment = StructureDepartment.id
WHERE Student.id = 1;


----###ЗАПИТ №13###----
----Відобразити студентів структурного підрозділу, що були атестовані по
----осінньому календарному контролю 2023 року і одночасно по календарному контролю 2022 року
WITH AtestatedStudents AS(
WITH ResultingAttestation AS(
	SELECT Student.id AS "Student ID",Student.firstname || ' ' || Student.secondname AS "Student",
	Subject.name AS "Subject", "Control".attestation AS "Attestation",
	"Control".dateofcontrol AS "Date", TypeOfControl.typeofcontrol AS "Control"
	FROM "Control"
	JOIN Student ON Student.id = "Control".student
	JOIN Subject ON Subject.id = "Control".subject
	JOIN TypeOfControl ON TypeOfControl.id = "Control".typeofcontrol
	JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
	JOIN Chair ON AcademicGroup.chair = Chair.id
	JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
	WHERE StructureDepartment.id = 10 AND "Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeOfControl = 'Calendar control')
) SELECT ResultingAttestation."Student ID" FROM ResultingAttestation
WHERE EXTRACT(MONTH FROM ResultingAttestation."Date") = 10 AND EXTRACT(YEAR FROM ResultingAttestation."Date") = 2023
AND ResultingAttestation."Attestation" = TRUE
INTERSECT
SELECT ResultingAttestation."Student ID" FROM ResultingAttestation 
WHERE EXTRACT(MONTH FROM ResultingAttestation."Date") = 10 AND EXTRACT(YEAR FROM ResultingAttestation."Date") = 2022
AND ResultingAttestation."Attestation" = TRUE)
SELECT "Student ID",Student.firstname || ' ' || Student.secondname AS "Student"
FROM AtestatedStudents
JOIN Student ON Student.id = AtestatedStudents."Student ID";


----####Запит №14----
----Перевірити чи існує певний студент в університеті, якщо існує,
----то вивести інформацію про його ім'я, групу, кафедру та структурний підрозділ
SELECT Student.firstname || ' ' || Student.secondname AS "Student",
AcademicGroup.name AS "Group", Chair.name AS "Chair", StructureDepartment.name AS "Structure Department"
FROM Student
JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
JOIN Chair ON AcademicGroup.chair = Chair.id
JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
WHERE EXISTS(SELECT 1 FROM Student WHERE firstname = 'Henry' AND secondname = 'Henstone' AND patronymic = 'Sobtka')
AND Student.id = (SELECT id FROM Student WHERE firstname = 'Henry' AND secondname = 'Henstone' AND patronymic = 'Sobtka');


----####Запит №15----
----Для певної кафедри відобразити список викладачів та кількість предметів, яку вони викладають
----відсортувати цей список за зростанням
SELECT Chair.name AS "Chair",
Teacher.firstName || ' ' || Teacher.lastName AS "Teacher",
COUNT("Control".subject) AS "Amount of subjects"
FROM "Control"
JOIN Teacher ON Teacher.id = "Control".teacher
JOIN Chair ON Chair.id = Teacher.chair
WHERE Chair.id = 55
GROUP BY Chair.name, "Teacher"
ORDER BY "Amount of subjects" ASC;

----####Запит №16----
----Відобразити студентів структурного підрозділу Х, підсумкові оцінки, по предмету У менші
----за 90 балів
SELECT Student.secondname AS "Student", Subject.name AS "Subject", Mark.score AS "Mark",
Mark.markECTS AS "ECTS", StructureDepartment.name AS "Department"
FROM "Control"
JOIN Student ON Student.id = "Control".student
JOIN AcademicGroup ON AcademicGroup.id = Student.academicgroup
JOIN Chair ON Chair.id = AcademicGroup.chair
JOIN Mark ON Mark.id = "Control".mark
JOIN StructureDepartment ON StructureDepartment.id = Chair.structuredepartment
JOIN Subject ON "Control".subject = Subject.id
WHERE StructureDepartment.id = 10 AND
"Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Exam')
AND Subject.id = 7;


----###Запит №17###----
----Відобразити кафедру, тип структурного підрозділу в якій вона перебуває
----та кількість викладачів, які на цій кафедрі працюють
SELECT 
    c.name AS "Chair", 
    td.type "Type of department", 
    COUNT(t.id) AS "Amount of teachers"
FROM Chair c
JOIN StructureDepartment sd ON c.structureDepartment = sd.id
JOIN TypeOfDepartment td ON sd.type = td.id
LEFT JOIN Teacher t ON c.id = t.chair
GROUP BY c.name, td.type;

----####Запит №18####----
----Відобразити контакті дані всіх кафедр певного структурного підрозділу
SELECT StructureDepartment.name AS "Structure Department",
Chair.name AS "Chair", Chair.phoneNumber AS "Phone",
Chair.website AS "Website"
FROM StructureDepartment
JOIN Chair ON Chair.structureDepartment = StructureDepartment.id
WHERE StructureDepartment.id = 18;


----####Запит №19####----
----Відобразити всі вчені звання, які викладачі певної кафедри
----теоретично могли б мати
SELECT Teacher.lastname || ' ' || Teacher.firstname || ' ' || Teacher.patronymic AS "Teacher",
Teacher.chair AS "Chair", EducationalDegree.educationaldegree
FROM Teacher
CROSS JOIN EducationalDegree
WHERE Teacher.chair = 15;


----####Запит №20####----
----Виведення контрольних заходів та їх предметів, які
----мають фіксований розмір більший за 100 академічних годин
SELECT 
s.name AS "Subject", 
COUNT(ctrl.id) AS "Amount of hours"
FROM  Subject s
JOIN "Control" ctrl ON s.id = ctrl.subject
WHERE  s.hours > 100
GROUP BY s.name
ORDER BY "Amount of hours" DESC;


----####Запит №21####----
----Відобразити студентів певного викладача, які мають оцінки з його предметів
----більші за 90 балів
SELECT Teacher.lastname AS "Teacher", Student.secondname AS "Student",
Mark.score AS "Mark", Mark.markECTS AS "ECTS"
FROM "Control"
JOIN Student ON "Control".student = Student.id
JOIN Teacher ON "Control".teacher = Teacher.id
JOIN Mark ON "Control".mark = Mark.id
WHERE "Control".typeOfControl = (SELECT id FROM TypeOfControl WHERE typeofcontrol = 'Exam')
GROUP BY Teacher.lastname, Student.secondname, Mark.score, Mark.markECTS
HAVING (Mark.score) >= 90;