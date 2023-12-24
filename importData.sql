--Імпортуємо дані про типи структурних підрозділів у відповідну таблицю
--з CSV файлу та виконуємо вибірку даних для перевірки успішності імпорту
\copy TypeOfDepartment(id, type) 
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\typeofdepartment.csv'
WITH DELIMITER ',';

SELECT * FROM TypeOfDepartment;

\copy EducationalDegree(id, educationalDegree)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\educationaldegree.csv'
WITH DELIMITER ',';

SELECT * FROM EducationalDegree;

\copy TypeOfControl(id, typeOfControl)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\typeofcontrol.csv'
WITH DELIMITER ',';

SELECT * FROM TypeOfControl;

\copy TypeOfSubject(id, type)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\typeofsubject.csv'
WITH DELIMITER ',';

SELECT * FROM TypeOfSubject;

\copy StructureDepartment(id, name, phoneNumber, email, website, type)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\structuredepartment.csv'
WITH DELIMITER ',';

SELECT * FROM StructureDepartment;

\copy Chair(id, name, phoneNumber, email, website, type)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\chair.csv'
WITH DELIMITER ',';

SELECT * FROM Chair;

\copy Teacher(id, firstname, lastname, patronymic, beginningworking, chair, educationaldegree)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\teacher.csv'
WITH DELIMITER ',';

SELECT * FROM Teacher;

\copy AcademicGroup(id, name, chair, academiccurator)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\academicgroup.csv'
WITH DELIMITER ',';

SELECT * FROM AcademicGroup;

\copy Student(firstname, secondname, patronymic, dateofentry, academicgroup)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\student.csv'
WITH DELIMITER ',';

SELECT * FROM Student;

\copy Subject(id, name, hours, typeofsubject)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\subject.csv'
WITH DELIMITER ',';

SELECT * FROM Subject;

\copy Mark(id, score, isResultingMark)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\resultingmarks.csv'
WITH DELIMITER ',';

SELECT * FROM Mark WHERE isResultingMark = TRUE ORDER BY score DESC;

\copy Mark(score, isResultingMark)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\nonresultingmarks.csv'
WITH DELIMITER ',';

\copy "Control"(attestation, dateofcontrol, typeofcontrol, subject, student, teacher)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\calendarcontrol.csv'
WITH DELIMITER ',';

\copy "Control"(dateofcontrol, typeofcontrol, subject, student, teacher, mark)
FROM 'C:\Users\nazar\OneDrive\Робочий стіл\ІП-22\ІІІ семестр\Курсова робота. Бази даних\Скрипти\DataToImport\control.csv'
WITH DELIMITER ',';