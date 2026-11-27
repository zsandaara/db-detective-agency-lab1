-- [setup] Приводим дело 5 в статус 'Открыто'
UPDATE cases SET status = 'Открыто' WHERE id = 5;

-- [A] Окно A: читаем статус
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value Открыто
SELECT status FROM cases WHERE id = 5;

-- [B] Окно B: меняем статус
BEGIN;
UPDATE cases SET status = 'В работе' WHERE id = 5;
COMMIT;

-- [A] Окно A: читаем статус снова (видим старое значение!)
-- expect: value Открыто
SELECT status FROM cases WHERE id = 5;
COMMIT;