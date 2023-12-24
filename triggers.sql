

--Створюємо тригер, який перевіряє чи входить створена оцінка з контролю у діапазон 0-100
CREATE OR REPLACE FUNCTION validateMarkTriggerFunction() RETURNS TRIGGER AS $$
BEGIN
	IF NEW.score < 0 OR NEW.score > 100 THEN
		RAISE EXCEPTION 'Значення оцінки має входити у діапазон від 0 до 100 балів.';
	END IF;
	
	IF NEW.isResultingMark = TRUE THEN
		NEW.nationalMark := CASE
			WHEN NEW.score BETWEEN 0 AND 39 THEN 'Not allowed'
			WHEN NEW.score BETWEEN 40 AND 59 THEN 'Not enough'
			WHEN NEW.score BETWEEN 60 AND 64 THEN 'Enough'
			WHEN NEW.score BETWEEN 65 AND 74 THEN 'Satisfactory'
			WHEN NEW.score BETWEEN 75 AND 84 THEN 'Good'
			WHEN NEW.score BETWEEN 85 AND 94 THEN 'Very Good'
			ELSE 'Excellent'
		END;

		NEW.markECTS := CASE
			WHEN NEW.score BETWEEN 0 AND 39 THEN 'F'
			WHEN NEW.score BETWEEN 40 AND 59 THEN 'E'
			WHEN NEW.score BETWEEN 60 AND 64 THEN 'D'
			WHEN NEW.score BETWEEN 65 AND 74 THEN 'C'
			WHEN NEW.score BETWEEN 75 AND 84 THEN 'B'
			WHEN NEW.score BETWEEN 85 AND 94 THEN 'B+'
			ELSE 'A'
		END;
	ELSE
		NEW.nationalMark := NULL;
		NEW.markECTS := NULL;
	END IF;

	RETURN NEW;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;


--Створюємо тригер безпосередньо для таблиці Mark
CREATE TRIGGER markValidationTrigger
BEFORE INSERT ON Mark
FOR EACH ROW 
EXECUTE FUNCTION validateMarkTriggerFunction();


--Створюємо тригер для перевірки коректності введення мобільного телефону
--відповідно до національного телефонного коду України +380
CREATE OR REPLACE FUNCTION validationPhoneNumberTriggerFunction()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.phoneNumber LIKE '+380%' THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Мобільний номер має належати до українського оператора звязку і мати код +380.';
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--Встановлюємо тригер на перевірку мобільного номера для структурного підрозділу та для кафедри
CREATE TRIGGER strDepPhoneValidationTrigger
BEFORE INSERT ON StructureDepartment
FOR EACH ROW 
EXECUTE FUNCTION validationPhoneNumberTriggerFunction();

CREATE TRIGGER chairPhoneValidationTrigger
BEFORE INSERT ON Chair
FOR EACH ROW
EXECUTE FUNCTION validationPhoneNumberTriggerFunction();

--Створюємо тригерну функцію для перевірки коректності вводу електронної пошти, щоб
--вона відповідала шаблону '@kpi.ua'
CREATE OR REPLACE FUNCTION checkEmailTriggerFunction()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.email LIKE '%@kpi.ua' THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Пошта структурного підрозділу або кафедри має належати до домену університету @kpi.ua';
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER strDepEmailValidationTrigger
BEFORE INSERT ON StructureDepartment
FOR EACH ROW 
EXECUTE FUNCTION checkEmailTriggerFunction();

CREATE TRIGGER chairEmailValidationTrigger
BEFORE INSERT ON Chair
FOR EACH ROW
EXECUTE FUNCTION checkEmailTriggerFunction();

--Створюємо тригерну функцію для перевірки домену веб-сайту структурного підрозділу
--або кафедри. Домен має мати закінчення .edu.kpi.ua
CREATE OR REPLACE FUNCTION websiteValidationTriggerFunction()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.website LIKE '%.edu.kpi.ua' THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Веб-сайт кафедри або структурного підрозділу має функціонувати під доменом університету .edu.kpi.ua';
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chairWebsiteValidationTrigger
BEFORE INSERT ON Chair
FOR EACH ROW
EXECUTE FUNCTION websiteValidationTriggerFunction();

CREATE TRIGGER strDepWebsiteValidationTrigger
BEFORE INSERT ON StructureDepartment
FOR EACH ROW
EXECUTE FUNCTION websiteValidationTriggerFunction();

--Ствоюємо тригер, який перевіряє чи дата вступу студента не утворює
--6 років різниці із поточною датою (бакалаврат + магістратура)
CREATE OR REPLACE FUNCTION studentEntryDateTriggerFunction()
RETURNS TRIGGER AS $$
DECLARE
	maxDifference INTEGER := 6;
BEGIN
	IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM NEW.dateOfEntry) < maxDifference THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Студент вже випустився з університету';
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER studentEntryYearTrigger
BEFORE INSERT ON Student
FOR EACH ROW
EXECUTE FUNCTION studentEntryDateTriggerFunction();


--За законодавством України кожна дисципліна є кредитним модулем, яка має кількість годин
--відповідно до кредитів ЄКТС, яку на дисципліну було витрачено
CREATE OR REPLACE FUNCTION checkSubjectHoursTriggerFunction()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.hours > 0 AND NEW.hours < 192 THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Кількість годин на предмет має входити у діапазон від 0 до 192 академічних годин';
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER checkSubjectHoursTrigger
BEFORE INSERT ON Subject
FOR EACH ROW
EXECUTE FUNCTION checkSubjectHoursTriggerFunction();

--Встановлюємо тригер, який перевіряє обмеження по кількості годин для типу контролю
CREATE OR REPLACE FUNCTION typeOfControlTriggerFunction()
RETURNS TRIGGER AS $$
BEGIN
	NEW.hours := CASE
		WHEN NEW.typeOfControl = 'Laboratory work' THEN 2
		WHEN NEW.typeOfControl = 'Computer practicum' THEN 2
		WHEN NEW.typeOfControl = 'Module controling work' THEN 2
		WHEN NEW.typeOfControl = 'Exam' THEN 4
		WHEN NEW.typeOfControl = 'Offset' THEN 4
		WHEN NEW.typeOfControl = 'Calendar control' THEN 10
		WHEN NEW.typeOfControl = 'Semester control' THEN 10
		WHEN NEW.typeOfControl = 'Practice' THEN 2
		ELSE 0
	END;
	
	IF NEW.hours = 0 THEN
		RAISE EXCEPTION 'Невідомий тип контролю';
	ELSE
		RETURN NEW;
	END IF;
EXCEPTION
	WHEN SQLSTATE 'P0001' THEN
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER typeOfControllTrigger
BEFORE INSERT ON typeOfControl
FOR EACH ROW
EXECUTE FUNCTION typeOfControlTriggerFunction();

