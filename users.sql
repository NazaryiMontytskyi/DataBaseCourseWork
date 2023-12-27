CREATE ROLE controlReviewerRole;
GRANT SELECT ON "Control", Teacher,
Student, TypeOfControl, TypeOfSubject TO controlReviewerRole;

CREATE ROLE controlEditorRole;
GRANT INSERT, SELECT, UPDATE, DELETE ON "Control" TO controlEditorRole;

CREATE ROLE studentManagement;
GRANT INSERT, DELETE, UPDATE, SELECT ON Student, AcademicGroup TO studentManagement;

CREATE ROLE subjectManagement;
GRANT INSERT, DELETE, UPDATE, SELECT ON Subject TO subjectManagement; 

CREATE USER student WITH PASSWORD 'abc';
CREATE USER cathedra WITH PASSWORD 'abc';
CREATE USER university WITH PASSWORD 'abc';
CREATE USER teacher WITH PASSWORD 'abc';

GRANT controlReviewerRole TO student;

GRANT controlReviewerRole TO Teacher;
GRANT controlEditorRole TO Teacher;

GRANT studentManagement TO cathedra;
GRANT subjectManagement TO cathedra;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO university;
