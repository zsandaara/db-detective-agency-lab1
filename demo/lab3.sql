-- 1. Проверяем представление
SELECT * FROM v_case_details LIMIT 3;

-- 2. Проверяем функцию (возвращает число)
SELECT get_evidence_count(1) AS evidence_count_for_case_1;

-- 3. Проверяем бизнес-операцию (добавляем улику делу 1)
SELECT add_evidence(1, 'Новый отпечаток пальца', 'Физический объект') AS new_evidence_id;
SELECT * FROM evidence WHERE case_id = 1;

-- 4. ОШИБКА: Пытаемся закрыть дело, у которого НЕТ УЛИК (дело 11)
-- expect: error "Дело нельзя закрыть без улик"
UPDATE cases SET status = 'Закрыто успешно' WHERE id = 11;

-- 5. УСПЕХ: Закрываем дело 1, у которого есть улики
UPDATE cases SET status = 'Закрыто успешно' WHERE id = 1;

-- 6. Проверяем служебный триггер (поле updated_at обновилось)
SELECT id, title, status, opened_at, updated_at FROM cases WHERE id = 1;

-- 7. ★ Проверяем материализованное представление и обновляем его
SELECT * FROM mv_detective_workload LIMIT 3;
REFRESH MATERIALIZED VIEW mv_detective_workload;

-- 8. ★ Проверяем функцию поиска с фильтрами (ищем свидетеля)
SELECT * FROM search_suspects(p_status := 'Свидетель');

-- 9. ★★ Проверяем журнал изменений (история по делу 1)
SELECT case_id, operation, old_data->>'status' AS old_status, new_data->>'status' AS new_status, changed_by 
FROM cases_history WHERE case_id = 1;

-- 10. ★★ Проверяем функцию «состояние на дату» (каким было дело 1 секунду назад)
SELECT get_case_state(1, now() - interval '1 second') AS state_1_sec_ago;