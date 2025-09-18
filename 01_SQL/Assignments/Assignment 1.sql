USE employees;

--- 1. The CEO wants to greet the newest recruits. List the newest 10 employees with their names and hire dates.

SELECT emp_no, first_name, last_name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 10;

--- 2. HR suspects a pattern of new hires post-Y2K. Find all employees hired after the year 2000.

SELECT emp_no, first_name, last_name, hire_date
FROM employees
WHERE Year (hire_date) > 2000
ORDER BY hire_date;

--- 3. There is a bet going on about how many employees are named John. Can you settle it.

SELECT COUNT(*) AS total_johns
FROM employees
WHERE first_name = 'John';

--- 4. Match employees with their departments. Show full names and department names.

SELECT  e.first_name, e.last_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no;

--- 5. The CEO forgot which managers lead which departments — retrieve that info for the next all-hands.

SELECT d.dept_name,e.emp_no,e.first_name,e.last_name
FROM dept_manager dm
JOIN employees e ON dm.emp_no = e.emp_no
JOIN departments d ON dm.dept_no = d.dept_no;

--- 6. Some employees are changing roles. Show each employee’s current title (hint: it’s the one with to_date = '9999-01-01').

SELECT e.emp_no, e.first_name, e.last_name, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.to_date = '9999-01-01';

--- 7. The CFO wants to know how many people work in each department. Give him the counts.

SELECT d.dept_name, COUNT(de.emp_no) AS num_employees
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
GROUP BY d.dept_name
ORDER BY num_employees DESC;

--- 8. What’s the average salary across the company? Is it too high?

SELECT AVG(salary) AS avg_salary
FROM salaries;

--- 9. Which department pays the best? Find the top salary by department.

SELECT d.dept_name, MAX(s.salary) AS top_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
GROUP BY d.dept_name
ORDER BY top_salary DESC;

--- 10. Classify employees into bands:
--- • <40,000 → 'Low'
--- • 40,000–80,000 → 'Medium'
--- • 80,000 → 'High'
--- Return employee number and the band label.

SELECT s.emp_no,
       CASE
           WHEN s.salary < 40000 THEN 'Low'
           WHEN s.salary BETWEEN 40000 AND 80000 THEN 'Medium'
           WHEN s.salary > 80000 THEN 'High'
       END AS salary_band
FROM salaries s;
