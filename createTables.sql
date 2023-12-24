

--Створюємо тип структурного підрозділу, щоб надалі пов'язати його із сутністю
--структурного підрозділу

CREATE TABLE TypeOfDepartment(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	type VARCHAR(50) NOT NULL
);


--Створюємо таблицю структурного підрозділу і пов'язуємо її з таблицею
--типу структурного підрозділу

CREATE TABLE StructureDepartment(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(100) NOT NULL,
	phoneNumber VARCHAR(30) NOT NULL,
	email VARCHAR(50) NOT NULL,
	website VARCHAR(50) NOT NULL,
	type BIGSERIAL NOT NULL REFERENCES TypeOfDepartment(id)
);

--Створємо таблицю кафедри, яку прив'яжемо до конкретного структурного підрозділу,
--в межах якого вона функціонує

CREATE TABLE Chair(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(50) NOT NULL,
	phoneNumber VARCHAR(30) NOT NULL,
	email VARCHAR(50) NOT NULL,
	website VARCHAR(50) NOT NULL,
	structureDepartment BIGSERIAL NOT NULL REFERENCES StructureDepartment(id)
);


--Створюємо таблицю наукових ступенів, щоб згодом прив'язати її до науково-педагогічного працівника

CREATE TABLE EducationalDegree(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	educationalDegree VARCHAR(30) NOT NULL
);

--Створюємо таблицю вчителя до якої прив'язуємо кафедру на якій він викладає та
--науковий ступінь який він має

CREATE TABLE Teacher(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	firstName VARCHAR(50) NOT NULL,
	lastName VARCHAR(50) NOT NULL,
	patronymic VARCHAR(50) NOT NULL,
	beginningWorking DATE NOT NULL,
	chair BIGSERIAL NOT NULL REFERENCES Chair(id),
	educationalDegree BIGSERIAL NOT NULL REFERENCES EducationalDegree(id)
);

--Створимо таблицю сутності академічної групи, яка буде посилатися на кафедру,
--в межах якої вона функціонує та на викладача, який є академічним куратором групи

CREATE TABLE AcademicGroup(
	id BIGSERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(10) NOT NULL,
	chair BIGSERIAL NOT NULL REFERENCES Chair(id),
	academicCurator BIGSERIAL NOT NULL REFERENCES Teacher(id)
);


--Переходимо до початку імплементації типу контролю
--Спочатку створюємо сутність типу контролю, яка його визначатиме
CREATE TABLE TypeOfControl(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	typeOfControl VARCHAR(50) NOT NULL,
	hours INTEGER NOT NULL
);

--Створюємо тип оцінки для відображення у таблиці контролю
CREATE TABLE Mark(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	score NUMERIC NOT NULL,
	nationalMark VARCHAR(15) NOT NULL,
	markECTS VARCHAR(5) NOT NULL
);

--Створюємо таблицю типу предмету, щоб пов'язати її з типом предмету
CREATE TABLE TypeOfSubject(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	type VARCHAR(20) NOT NULL
);

--Створюємо таблицю предмету, у яку агрегуємо тип предмету
CREATE TABLE Subject(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	hours INTEGER NOT NULL,
	typeOfSubject BIGSERIAL NOT NULL REFERENCES TypeOfSubject(id)
);

--Створюємо таблицю студента, у яку агрегуємо групу
CREATE TABLE Student(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	firstName VARCHAR(50) NOT NULL,
	secondName VARCHAR(50) NOT NULL,
	patronymic VARCHAR(50) NOT NULL,
	dateOfEntry DATE NOT NULL,
	academicGroup BIGSERIAL NOT NULL REFERENCES AcademicGroup(id)
);


--Створюємо тип контролю, у який агрегуємо
--студента, який проходить контроль
--оцінку, яку студент за контроль отримує
--тип контролю, який студент проходить
--викладача, який оцінює студента
--предмет, по якому контроль проводиться


CREATE TABLE "Control"(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	attestation BOOL,
	dateOfControl DATE NOT NULL,
	typeOfControl BIGSERIAL NOT NULL REFERENCES TypeOfControl(id),
	mark INTEGER REFERENCES Mark(id),
	subject BIGSERIAL NOT NULL REFERENCES Subject(id),
	student BIGSERIAL NOT NULL REFERENCES Student(id),
	teacher BIGSERIAL NOT NULL REFERENCES Teacher(id)
);
