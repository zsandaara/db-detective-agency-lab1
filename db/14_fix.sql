CREATE OR REPLACE FUNCTION assign_case_to_detective(p_case_id integer, p_detective_id integer)
RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    v_active_cases integer;
BEGIN
    -- Блокируем строку детектива, чтобы другие сессии ждали
    PERFORM id FROM detectives WHERE id = p_detective_id FOR UPDATE;

    -- Считаем его активные дела
    SELECT COUNT(*) INTO v_active_cases
    FROM cases 
    WHERE detective_id = p_detective_id AND status = 'В работе';

    IF v_active_cases >= 3 THEN
        RAISE EXCEPTION 'У детектива уже максимум активных дел';
    END IF;

    -- Назначаем дело
    UPDATE cases SET detective_id = p_detective_id, status = 'В работе' WHERE id = p_case_id;
    RETURN true;
END;
$$;