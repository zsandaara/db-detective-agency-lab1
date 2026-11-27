-- [setup] Детектив 1 имеет 2 дела. Освобождаем место для теста.
UPDATE cases SET detective_id = 1, status = 'В работе' WHERE id IN (1, 2);
UPDATE cases SET status = 'Открыто' WHERE id IN (3, 4);

-- [A] Окно А: берет дело 3
BEGIN;
UPDATE cases SET detective_id = 1, status = 'В работе' WHERE id = 3;

-- [B] Окно В: одновременно берет дело 4
BEGIN;
UPDATE cases SET detective_id = 1, status = 'В работе' WHERE id = 4;

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Проверяем, не нарушено ли правило (у детектива не больше 3 дел)
-- expect: false
SELECT count(*) <= 3 FROM cases WHERE detective_id = 1 AND status = 'В работе';

-- [cleanup]
UPDATE cases SET status = 'Открыто', detective_id = 3 WHERE id IN (3, 4);