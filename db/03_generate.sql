-- Генерируем 1000 клиентов (чтобы перевалить порог в 1000 строк)
INSERT INTO clients (full_name, phone)
SELECT 
    'Сгенерированный Клиент ' || i, 
    '+7999' || lpad(i::text, 7, '0')
FROM generate_series(1, 1000) AS i;

-- Генерируем 1000 допросов (связываем существующих детективов и подозреваемых)
INSERT INTO interrogations (detective_id, suspect_id, case_id, summary)
SELECT 
    (i % 10) + 1,  
    (i % 10) + 1,  
    (i % 10) + 1,  
    'Автоматически сгенерированный протокол допроса №' || i
FROM generate_series(1, 1000) AS i
ON CONFLICT (detective_id, suspect_id, case_id) DO NOTHING; 
-- ^^^ Эта строчка говорит базе: если совпало по UNIQUE, просто пропустить