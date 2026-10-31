-- Генерируем 1000 клиентов (чтобы перевалить порог в 1000 строк)
INSERT INTO clients (full_name, phone)
SELECT 
    'Сгенерированный Клиент ' || i, 
    '+7999' || lpad(i::text, 7, '0')
FROM generate_series(1, 1000) AS i;

-- Генерируем 1000 допросов (связываем существующих детективов и подозреваемых)
INSERT INTO interrogations (detective_id, suspect_id, case_id, summary)
SELECT 
    (i % 10) + 1,  -- берем ID детектива от 1 до 10
    (i % 10) + 1,  -- берем ID подозреваемого от 1 до 10
    (i % 10) + 1,  -- берем ID дела от 1 до 10
    'Автоматически сгенерированный протокол допроса №' || i
FROM generate_series(1, 1000) AS i;
