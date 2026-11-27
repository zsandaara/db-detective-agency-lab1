-- Добавляем колонку updated_at для служебного триггера
ALTER TABLE cases ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- ==========================================
-- СЛУЖЕБНЫЙ ТРИГГЕР (обновляет время изменения)
-- ==========================================
CREATE OR REPLACE FUNCTION set_updated_at() 
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_cases_updated_at 
BEFORE UPDATE ON cases
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ==========================================
-- ТРИГГЕР БИЗНЕС-ПРАВИЛА (Дело нельзя закрыть без улик)
-- ==========================================
CREATE OR REPLACE FUNCTION check_case_evidence() 
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Если новый статус начинается со слова 'Закрыто', а старый был не закрыт
    IF NEW.status LIKE 'Закрыто%' AND OLD.status NOT LIKE 'Закрыто%' THEN
        -- Проверяем, есть ли улики по этому делу
        IF (SELECT COUNT(*) FROM evidence WHERE case_id = NEW.id) = 0 THEN
            RAISE EXCEPTION 'Дело нельзя закрыть без улик';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_case_evidence
BEFORE UPDATE ON cases
FOR EACH ROW EXECUTE FUNCTION check_case_evidence();

-- ==========================================
-- ★★ ЖУРНАЛ ИЗМЕНЕНИЙ (History Table)
-- ==========================================
CREATE TABLE IF NOT EXISTS cases_history (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_id integer,
    operation text,
    old_data jsonb,
    new_data jsonb,
    changed_by text,
    changed_at timestamptz DEFAULT clock_timestamp()
);

CREATE OR REPLACE FUNCTION log_case_changes() 
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO cases_history (case_id, operation, new_data, changed_by)
        VALUES (NEW.id, TG_OP, to_jsonb(NEW), session_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO cases_history (case_id, operation, old_data, new_data, changed_by)
        VALUES (NEW.id, TG_OP, to_jsonb(OLD), to_jsonb(NEW), session_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO cases_history (case_id, operation, old_data, changed_by)
        VALUES (OLD.id, TG_OP, to_jsonb(OLD), session_user);
    END IF;
    RETURN NULL; -- AFTER-триггер возвращает NULL
END;
$$;

CREATE TRIGGER trg_log_cases
AFTER INSERT OR UPDATE OR DELETE ON cases
FOR EACH ROW EXECUTE FUNCTION log_case_changes();

-- ==========================================
-- ФУНКЦИЯ «СОСТОЯНИЕ НА ДАТУ»
-- ==========================================
CREATE OR REPLACE FUNCTION get_case_state(p_case_id integer, p_time timestamptz)
RETURNS jsonb LANGUAGE sql AS $$
    SELECT new_data 
    FROM cases_history 
    WHERE case_id = p_case_id AND changed_at <= p_time
    ORDER BY changed_at DESC 
    LIMIT 1;
$$;