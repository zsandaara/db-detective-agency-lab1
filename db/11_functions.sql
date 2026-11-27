-- 1. Функция возвращает значение (сколько улик собрано по делу)
CREATE OR REPLACE FUNCTION get_evidence_count(p_case_id integer) 
RETURNS integer 
LANGUAGE sql 
AS $$
    SELECT COUNT(*) FROM evidence WHERE case_id = p_case_id;
$$;

-- 2. БИЗНЕС-ОПЕРАЦИЯ: Добавление улики одной командой
CREATE OR REPLACE FUNCTION add_evidence(
    p_case_id integer, 
    p_description text, 
    p_type text
) 
RETURNS integer 
LANGUAGE plpgsql 
AS $$
DECLARE 
    v_evidence_id integer;
BEGIN
    INSERT INTO evidence (case_id, description, evidence_type)
    VALUES (p_case_id, p_description, p_type)
    RETURNING id INTO v_evidence_id;
    
    RETURN v_evidence_id;
END;
$$;

-- (ДОП. БАЛЛ): Функция поиска с фильтрами, которая возвращает таблицу
CREATE OR REPLACE FUNCTION search_suspects(
    p_name text DEFAULT NULL,
    p_status text DEFAULT NULL
)
RETURNS TABLE (
    suspect_name text,
    suspect_status text,
    case_title text
)
LANGUAGE sql
AS $$
    SELECT s.full_name, s.status, c.title
    FROM suspects s
    JOIN cases c ON s.case_id = c.id
    WHERE 
        (p_name IS NULL OR s.full_name ILIKE '%' || p_name || '%')
        AND (p_status IS NULL OR s.status = p_status);
$$;