-- [setup]
UPDATE cases SET detective_id = 1, status = 'В работе' WHERE id IN (1, 2);
UPDATE cases SET status = 'Открыто' WHERE id IN (3, 4);

-- [A] Окно А: вызывает функцию с блокировкой
BEGIN;
SELECT assign_case_to_detective(3, 1);

-- [B] Окно В: стучится в ту же функцию
BEGIN;
SELECT assign_case_to_detective(4, 1);
-- expect: blocked (второе окно ждет, пока первое не закоммитит)

-- [A]
COMMIT;

-- [B]
ROLLBACK; -- откатываем, так как сработала бы ошибка лимита

-- [check]
-- expect: true
SELECT count(*) <= 3 FROM cases WHERE detective_id = 1 AND status = 'В работе';

-- [cleanup]
UPDATE cases SET status = 'Открыто', detective_id = 3 WHERE id IN (3, 4);