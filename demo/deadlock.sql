-- [A] Блокируем дело 1
BEGIN;
UPDATE cases SET status = 'В работе' WHERE id = 1;

-- [B] Блокируем дело 2
BEGIN;
UPDATE cases SET status = 'В работе' WHERE id = 2;

-- [A] Ждем дело 2
UPDATE cases SET status = 'В работе' WHERE id = 2;
-- expect: blocked

-- [B] Ждем дело 1 (тут случится deadlock)
UPDATE cases SET status = 'В работе' WHERE id = 1;
-- expect: error "deadlock detected"