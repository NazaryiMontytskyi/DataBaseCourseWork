--Вказуємо, що типи структурних підрозділів мають бути унікальними
ALTER TABLE TypeOfDepartment ADD CONSTRAINT uniqueDepartmentType UNIQUE(type);

--Вказуємо, що структурний підрозділ має мати унікальні:
--ім'я, номер мобільного, електронну пошту, та вебсайт
ALTER TABLE StructureDepartment ADD CONSTRAINT uniqueDepartmentName UNIQUE(name);
ALTER TABLE StructureDepartment ADD CONSTRAINT uniqueDepartmentPhoneNumber UNIQUE(phoneNumber);
ALTER TABLE StructureDepartment ADD CONSTRAINT uniqueDepartmentEmail UNIQUE(email);
ALTER TABLE StructureDepartment ADD CONSTRAINT uniqueDepartmentWebsite UNIQUE(website);

--Встановимо обмеження для кафедри, щоб вона мала унікальні:
--ім'я, номер мобільного, веб-сайт та електронну пошту
ALTER TABLE Chair ADD CONSTRAINT ChairUniqueName UNIQUE(name);
ALTER TABLE Chair ADD CONSTRAINT ChairUniquePhoneNumber UNIQUE(phoneNumber);
ALTER TABLE Chair ADD CONSTRAINT ChairUniqueWebsite UNIQUE(website);
ALTER TABLE Chair ADD CONSTRAINT ChairUniqueEmail UNIQUE(email);

--Встановимо обмеження для сутності AcademicGroup
--щоб вона мала унікальне ім'я
ALTER TABLE AcademicGroup ADD CONSTRAINT GroupUniqueName UNIQUE(name);

--Встановим обмеження для AcademicGroup, щоб кожна група
--мала унікального академічного куратора, тобто щоб утворився зв'язок
--один до одного
ALTER TABLE AcademicGroup ADD CONSTRAINT GroupUniqueCurator UNIQUE(academicCurator);

--Створимо умову, яка забезпечить унікальність всіх наукових ступенів
ALTER TABLE EducationalDegree ADD CONSTRAINT DegreeUniqueValue UNIQUE(educationalDegree);

--Створимо обмеження, де вкажемо, що тип предмету має бути унікальним
ALTER TABLE TypeOfSubject ADD CONSTRAINT SubjectUniqueType UNIQUE(type);

--Створимо обмеження, де вкажемо, що тип контролю має бути унікальним
ALTER TABLE TypeOfControl ADD CONSTRAINT ControlUniqueType UNIQUE(typeOfControl);

--Створимо обмеження, де вкажемо, що назва предмету має бути унікаьлною
ALTER TABLE Subject ADD CONSTRAINT SubjectUniqueName UNIQUE(name);