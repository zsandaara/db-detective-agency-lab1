-- 1. Представление: Карточка дела (собирает данные из 3 таблиц)
CREATE OR REPLACE VIEW v_case_details AS
SELECT 
    c.id AS case_id,
    c.title AS case_title,
    c.status AS case_status,
    cl.full_name AS client_name,
    d.full_name AS detective_name
FROM cases c
JOIN clients cl ON c.client_id = cl.id
JOIN detectives d ON c.detective_id = d.id;

-- 2. Представление: Сводка по допросам (кто, кого, когда)
CREATE OR REPLACE VIEW v_interrogation_summary AS
SELECT 
    i.id AS interrogation_id,
    i.interrogated_at::date AS date,
    d.full_name AS detective,
    s.full_name AS suspect,
    c.title AS case_title
FROM interrogations i
JOIN detectives d ON i.detective_id = d.id
JOIN suspects s ON i.suspect_id = s.id
JOIN cases c ON i.case_id = c.id;

-- (ДОП. БАЛЛ): Материализованное представление (Отчет по нагрузке детективов)
CREATE MATERIALIZED VIEW mv_detective_workload AS
SELECT 
    d.full_name AS detective,
    COUNT(c.id) AS total_cases,
    COUNT(c.id) FILTER (WHERE c.status = 'В работе') AS active_cases
FROM detectives d
LEFT JOIN cases c ON d.id = c.detective_id
GROUP BY d.id, d.full_name;