use hospital_management_system;

select * from hospitals;
select * from doctors;
select * from patients;
select * from appointments;
select * from departments;
select * from medications;
select * from prescriptions;
select * from rooms;

--- alter datetime to date

ALTER TABLE appointments
MODIFY COLUMN appointment_date DATE NOT NULL;

--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------- BASIC QUERIES ------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------


--- 1.Show the number of appointments in each month. 

SELECT 
    MONTH(appointment_date) AS month_no,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY MONTH(appointment_date)
ORDER BY month_no;

--- 2.Show room numbers and their capacities in the Neurology department. 

SELECT r.room_no, r.capacity
FROM rooms r
JOIN departments d ON r.department_id = d.department_id
WHERE d.name = 'Neurology';

--- 3.Find the names, phones and appointment_dates of all patients with appointments in August. 

SELECT p.name, p.phone, a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE MONTH(a.appointment_date) = 8;

--- 4.List all medications that include the keywords pain or infection in the description. 

SELECT medication_id, name, description
FROM medications
WHERE description LIKE '%pain%'
   OR description LIKE '%infection%';

--- 5.Find doctors who have not prescribed any medication yet. 

SELECT d.doctor_id, d.name, d.specialty
FROM doctors d
LEFT JOIN prescriptions pr ON d.doctor_id = pr.doctor_id
WHERE pr.prescription_id IS NULL;

--- 6.Find the names of patients who have been prescribed more than one medication. 

SELECT p.name, COUNT(DISTINCT pr.medication_id) AS medication_count
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
GROUP BY p.patient_id, p.name
HAVING COUNT(DISTINCT pr.medication_id) > 1;

--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------- ADVANCE QUERIES ----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

--- 7.Rank doctors by number of appointments (within their hospitals). 

SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    d.hospital_id,
    COUNT(a.appointment_id) AS appointment_count,
    RANK() OVER (PARTITION BY d.hospital_id ORDER BY COUNT(a.appointment_id) DESC) AS doctor_rank
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name, d.hospital_id;

--- 8.List the last 2 appointments for every patient. 

SELECT *
FROM (
    SELECT 
        a.appointment_id,
        a.patient_id,
        a.appointment_date,
        ROW_NUMBER() OVER (PARTITION BY a.patient_id ORDER BY a.appointment_date DESC) AS rn
    FROM appointments a
) t
WHERE rn <= 2;

--- 9.For all the emergency appointments, show patient name, date of birth as well as age-group according to the following: 
       -- 18 or below - Pediatric 
	   -- 19 to 64 - Adult 
       -- 65 or above - Geriatric 
       
SELECT 
    p.name AS patient_name,
    p.dob,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) <= 18 THEN 'Pediatric'
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) BETWEEN 19 AND 64 THEN 'Adult'
        ELSE 'Geriatric'
    END AS age_group
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE a.reason LIKE '%Emergency%';
       
--- 10.Out of all the consultation appointments with cardiologists, break down how many are by pediatric, adult and geriatric patients each (age criteria is the same as above).  

SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) <= 18 THEN 'Pediatric'
        WHEN TIMESTAMPDIFF(YEAR, p.dob, CURDATE()) BETWEEN 19 AND 64 THEN 'Adult'
        ELSE 'Geriatric'
    END AS age_group,
    COUNT(*) AS total_consultations
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.reason LIKE '%Consultation%'
  AND d.specialty = 'Cardiology'
GROUP BY age_group;

--- 11.Every medication has a prescription frequency, i.e. the number of times it has been prescribed. Find all medications with the top three prescription frequencies (for example if the top 3 frequencies are 8,7 and 6, then list all medications prescribed these number of times). 

WITH med_freq AS (
    SELECT 
        m.medication_id,
        m.name,
        COUNT(pr.prescription_id) AS frequency
    FROM prescriptions pr
    JOIN medications m ON pr.medication_id = m.medication_id
    GROUP BY m.medication_id, m.name
),
ranked_freq AS (
    SELECT DISTINCT frequency
    FROM med_freq
    ORDER BY frequency DESC
    LIMIT 3
)
SELECT mf.medication_id, mf.name, mf.frequency
FROM med_freq mf
WHERE mf.frequency IN (SELECT frequency FROM ranked_freq)
ORDER BY mf.frequency DESC;

--- 12.Show all hospitals with the lowest doctor count. 

WITH doctor_counts AS (
    SELECT h.hospital_id, h.name, COUNT(d.doctor_id) AS doctor_count
    FROM hospitals h
    LEFT JOIN doctors d ON h.hospital_id = d.hospital_id
    GROUP BY h.hospital_id, h.name
)
SELECT hospital_id, name, doctor_count
FROM doctor_counts
WHERE doctor_count = (SELECT MIN(doctor_count) FROM doctor_counts);

--- 13.Out of the cardiology departments in each hospital, find out which hospital(s)s cardiology department has the most number of rooms. 

WITH cardiology_rooms AS (
    SELECT h.hospital_id, h.name AS hospital_name, COUNT(r.room_id) AS room_count
    FROM departments dep
    JOIN hospitals h ON dep.hospital_id = h.hospital_id
    JOIN rooms r ON dep.department_id = r.department_id
    WHERE dep.name = 'Cardiology'
    GROUP BY h.hospital_id, h.name
)
SELECT hospital_id, hospital_name, room_count
FROM cardiology_rooms
WHERE room_count = (SELECT MAX(room_count) FROM cardiology_rooms);

--- 14.Find out the difference in days between the appointment dates of returning patients 

SELECT patient_id,
       appointment_id,
       appointment_date,
       DATEDIFF(appointment_date, LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date)) AS days_between
FROM appointments
ORDER BY patient_id, appointment_date;

