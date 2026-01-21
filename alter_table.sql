-- 1) Adding a column
ALTER TABLE students
ADD COLUMN date_of_birth DATE;

-- 2) Dropping a column
ALTER TABLE students
DROP COLUMN date_of_birth;

-- 3) Changing a Column's Data Type
ALTER TABLE students
ALTER COLUMN first_name TYPE TEXT;

-- 4) Adding a Constraint
ALTER TABLE students
ADD CONSTRAINT enrolment_year_from_2010
CHECK (enrolment_year >= DATE '2010-01-01');
