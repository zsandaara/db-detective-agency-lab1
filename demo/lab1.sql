-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql
--
-- Каждый шаг: строка «-- N. что показываем», под ней «-- expect: ответ базы», под ней запрос.
-- Пример, замените своими запросами:
--
-- -- 1. Таблицы на месте: 6 таблиц
-- -- expect: rows 6
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1;
--
-- -- 2. Отрицательная цена билета: ошибка CHECK
-- -- expect: error check
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, -100);
--
-- -- 3. Несуществующий сеанс: ошибка внешнего ключа
-- -- expect: error fk
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (9999, 1, 300);
--
-- -- 4. То же место на тот же сеанс второй раз: ошибка UNIQUE
-- -- expect: error unique
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, 300);

-- 1. Нарушение UNIQUE: пытаемся вставить клиента с уже существующим телефоном
-- expect: error unique
INSERT INTO clients (full_name, phone) VALUES ('Дубль', '+79161234567');

-- 2. Нарушение CHECK: пытаемся создать улику с недопустимым типом
-- expect: error check
INSERT INTO evidence (description, evidence_type, case_id) VALUES ('Странная улика', 'Неизвестный тип', 1);

-- 3. Нарушение FOREIGN KEY: пытаемся создать дело для несуществующего клиента
-- expect: error fk
INSERT INTO cases (title, description, client_id, detective_id) VALUES ('Дело-призрак', 'Описание', 999, 1);