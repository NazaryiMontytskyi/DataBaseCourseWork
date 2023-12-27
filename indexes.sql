---ІНДЕКСИ ДЛЯ ОПТИМІЗАЦІЇ ЗАПИТІВ---


---ІНДЕКС №1---
---Створення індексу для персональних даних студента---
CREATE INDEX idxStudentPersonalData ON Student(firstname, secondname, patronymic)

---ІНДЕКС №2---
---Створення індексу для персональних даних викладача---
CREATE INDEX idxTeacherPersonalData ON Teacher(firstname, lastname, patronymic);

---ІНДЕКС №3---
CREATE INDEX idxStudentAcademicGroup ON Student(academicgroup);
CREATE INDEX idxAcademicGroup ON AcademicGroup(id);

---ІНДЕКС №4---
CREATE INDEX idxChairDepartment ON Chair(structuredepartment);
CREATE INDEX idxStructureDepartment ON StructureDepartment(id);

---ІНДЕКС №5---
CREATE INDEX idxTeacherChair ON Teacher(chair);
CREATE INDEX idxChairID ON Chair(id);

CREATE INDEX idxControlID ON "Control"(id);
CREATE INDEX idxControlTeacher ON "Control"(teacher);
CREATE INDEX idxControlSubject ON "Control"(subject);
CREATE INDEX idxControlTypeOfControl ON "Control"(typeofcontrol);
CREATE INDEX idxControlMark ON "Control"(mark);
CREATE INDEX idxControlStudent ON "Control"(student);

CREATE INDEX idxStudentID ON Student(id);
CREATE INDEX idxTeacherID ON Teacher(id);
CREATE INDEX idxTypeOfControl ON TypeOfControl(id);
CREATE INDEX idxMarkID ON Mark(id);
CREATE INDEX idxSubjectID ON Subject(id);