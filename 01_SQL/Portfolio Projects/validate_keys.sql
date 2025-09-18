use hospital_management_system;

--- Doctors belong to Hospitals---

SELECT d.doctor_id, d.name AS doctor_name, d.specialty, h.name AS hospital_name
FROM doctors d
JOIN hospitals h ON d.hospital_id = h.hospital_id;

--- Patients and their Appointments with Doctors---

SELECT a.appointment_id, p.name AS patient_name, d.name AS doctor_name, a.appointment_date, a.reason
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

--- Departments within Hospitals

SELECT dep.department_id, dep.name AS department_name, h.name AS hospital_name
FROM departments dep
JOIN hospitals h ON dep.hospital_id = h.hospital_id;

--- Rooms assigned to Departments

SELECT r.room_id, r.room_no, r.capacity, dep.name AS department_name
FROM rooms r
JOIN departments dep ON r.department_id = dep.department_id;

--- Prescriptions linking Patients, Doctors, and Medications

SELECT pr.prescription_id, p.name AS patient_name, d.name AS doctor_name, m.name AS medication_name, pr.prescribed_date
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
JOIN doctors d ON pr.doctor_id = d.doctor_id
JOIN medications m ON pr.medication_id = m.medication_id;


--------------------------------
--- Foreign Key Integrity Checks
--------------------------------

--- Doctors without a valid hospital

SELECT * FROM doctors d
WHERE d.hospital_id NOT IN (SELECT hospital_id FROM hospitals);

--- Appointments with invalid patients or doctors

SELECT * FROM appointments a
WHERE a.patient_id NOT IN (SELECT patient_id FROM patients)
   OR a.doctor_id NOT IN (SELECT doctor_id FROM doctors);
   
--- Prescriptions with invalid references

SELECT * FROM prescriptions pr
WHERE pr.patient_id NOT IN (SELECT patient_id FROM patients)
   OR pr.doctor_id NOT IN (SELECT doctor_id FROM doctors)
   OR pr.medication_id NOT IN (SELECT medication_id FROM medications);
