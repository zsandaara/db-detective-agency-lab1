-- 1. Вывести все дела с именами клиентов и детективов (JOIN 3 таблицы)
SELECT c.title AS case_title, cl.full_name AS client_name, d.full_name AS detective_name
FROM cases c
JOIN clients cl ON c.client_id = cl.id
JOIN detectives d ON c.detective_id = d.id;

-- 2. Вывести список всех допросов: кто, кого и по какому делу (JOIN 4 таблицы)
SELECT i.interrogated_at::date AS date, d.full_name AS detective, s.full_name AS suspect, c.title AS case_title
FROM interrogations i
JOIN detectives d ON i.detective_id = d.id
JOIN suspects s ON i.suspect_id = s.id
JOIN cases c ON i.case_id = c.id;

-- 3. Вывести все улики с названиями дел (JOIN 2 таблицы)
SELECT e.description AS evidence, e.evidence_type, c.title AS case_title
FROM evidence e
JOIN cases c ON e.case_id = c.id;

-- 4. Посчитать, сколько дел ведет каждый детектив (GROUP BY)
SELECT d.full_name AS detective, COUNT(c.id) AS total_cases
FROM detectives d
LEFT JOIN cases c ON d.id = c.detective_id
GROUP BY d.id, d.full_name
ORDER BY total_cases DESC;

-- 5. Найти клиентов, у которых есть хотя бы одно дело (GROUP BY + HAVING)
SELECT cl.full_name AS client, COUNT(c.id) AS case_count
FROM clients cl
JOIN cases c ON cl.id = c.client_id
GROUP BY cl.id, cl.full_name
HAVING COUNT(c.id) >= 1; 

-- 6. Найти подозреваемых, которых ни разу не допрашивали (LEFT JOIN + IS NULL)
SELECT s.full_name AS suspect, s.status
FROM suspects s
LEFT JOIN interrogations i ON s.id = i.suspect_id
WHERE i.id IS NULL;

-- 7. Найти дела, по которым еще не собрано ни одной улики (Подзапрос NOT EXISTS)
SELECT c.title AS case_title
FROM cases c
WHERE NOT EXISTS (
    SELECT 1 FROM evidence e WHERE e.case_id = c.id
);

-- 8. Найти детектива, который провел больше всего допросов (Подзапрос IN)
SELECT full_name 
FROM detectives 
WHERE id IN (
    SELECT detective_id 
    FROM interrogations 
    GROUP BY detective_id 
    ORDER BY COUNT(*) DESC 
    LIMIT 1
);

-- 9. Добавить нового клиента и посмотреть результат (INSERT)
BEGIN;
SELECT count(*) AS clients_before FROM clients;
INSERT INTO clients (full_name, phone, email) VALUES ('Новый клиент', '+79998887766', 'new@client.ru');
SELECT count(*) AS clients_after FROM clients;
ROLLBACK;

-- 10. Перевести все открытые дела в статус "В работе" (UPDATE + WHERE)
BEGIN;
SELECT id, title, status FROM cases WHERE status = 'Открыто';
UPDATE cases SET status = 'В работе' WHERE status = 'Открыто';
SELECT id, title, status FROM cases WHERE status = 'В работе';
ROLLBACK;

-- 11. Удалить одного свидетеля (DELETE + WHERE)
BEGIN;
SELECT full_name, status FROM suspects WHERE status = 'Свидетель';
DELETE FROM suspects WHERE full_name = 'Мария Иванова'; 
SELECT full_name, status FROM suspects WHERE status = 'Свидетель';
ROLLBACK;

-- 12. Вывести дела и количество улик по каждому (JOIN + GROUP BY + ORDER BY)
SELECT c.title AS case_title, COUNT(e.id) AS evidence_count
FROM cases c
LEFT JOIN evidence e ON c.id = e.case_id
GROUP BY c.id, c.title
ORDER BY evidence_count DESC;

-- 13. Топ-3 подозреваемых по количеству допросов в каждом деле (WITH + ROW_NUMBER + PARTITION BY)
WITH SuspectStats AS (
    SELECT 
        case_id, 
        suspect_id, 
        COUNT(*) AS interrogations_count
    FROM interrogations
    GROUP BY case_id, suspect_id
)
SELECT * FROM (
    SELECT 
        case_id, 
        suspect_id, 
        interrogations_count,
        ROW_NUMBER() OVER (PARTITION BY case_id ORDER BY interrogations_count DESC) AS rn
    FROM SuspectStats
) ranked
WHERE rn <= 3;

-- 14. Накопительная сумма открытых дел по датам (SUM() OVER)
SELECT opened_at::date AS date, title, COUNT(*) OVER (ORDER BY opened_at) AS cumulative_cases
FROM cases
ORDER BY opened_at;

-- 15. Сводка по каждому детективу: всего, закрыто, в работе, процент (FILTER)
SELECT 
    d.full_name AS detective,
    COUNT(c.id) AS total_cases,
    COUNT(c.id) FILTER (WHERE c.status = 'Закрыто успешно') AS closed_success,
    COUNT(c.id) FILTER (WHERE c.status = 'В работе') AS in_progress,
    ROUND(100.0 * COUNT(c.id) FILTER (WHERE c.status LIKE 'Закрыто%') / NULLIF(COUNT(c.id), 0), 1) AS closed_percentage
FROM detectives d
LEFT JOIN cases c ON d.id = c.detective_id
GROUP BY d.id, d.full_name
ORDER BY total_cases DESC;