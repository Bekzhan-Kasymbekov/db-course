-- Basic Aggregates

SELECT COUNT(*) AS total_employees FROM employees;

SELECT SUM(salary) AS total_salary FROM employees;

SELECT AVG(salary) AS average_salary FROM employees;

SELECT MIN(salary) AS min_salary,
       MAX(salary) AS max_salary
FROM employees;

-- GROUP BY
SELECT
    department,
    COUNT(*) AS employee_count,
    SUM(salary) AS total_salary,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

-- HAVING
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 2;

-- STING_AGG
SELECT
    department,
    STRING_AGG(first_name, ', ') AS employees
FROM employees
GROUP BY department;

-- ARRAY_AGG
SELECT
    department,
    ARRAY_AGG(salary) AS salary_list
FROM employees
GROUP BY department;

-- Statistical functions
SELECT
    department,
    STDDEV(salary) AS salary_std_dev,
    VARIANCE(salary) AS salary_variance
FROM employees
GROUP BY department;

-- Conditional Aggregation
SELECT
    department,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary > 60000 THEN 1 END) AS high_earners
FROM employees
GROUP BY department;

-- Percentage of Total
SELECT
    department,
    COUNT(*) AS dept_count,
    COUNT(*)::FLOAT / (SELECT COUNT(*) FROM employees) * 100 AS percentage
FROM employees
GROUP BY department
ORDER BY percentage DESC;

-- NULL Handling
SELECT
    COUNT(*) AS total_rows,
    COUNT(bonus) AS employee_with_bonus,
    COUNT(*) - COUNT(bonus) AS employees_without_bonus
FROM employees;
