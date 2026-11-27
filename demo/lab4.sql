-- 1. Проверяем статус дела 11 (у него нет улик)
-- expect: value Открыто
SELECT status FROM cases WHERE id = 11;

-- 2. Начинаем транзакцию, которая упадет на триггере
BEGIN;
-- expect: error "Дело нельзя закрыть без улик"
UPDATE cases SET status = 'Закрыто успешно' WHERE id = 11;
COMMIT;

-- 3. Проверяем, что статус не изменился (откатился)
-- expect: same 1
SELECT status FROM cases WHERE id = 11;