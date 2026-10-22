-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.
--
-- Пример, замените своими таблицами:
--
-- CREATE TABLE halls (
--     id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--     name  text NOT NULL UNIQUE,
--     seats integer NOT NULL CHECK (seats > 0)
-- );

-- Таблица детективов
CREATE TABLE detectives (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    rank text NOT NULL DEFAULT 'Младший детектив',
    is_active boolean NOT NULL DEFAULT true
);

-- Таблица клиентов
CREATE TABLE clients (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    phone text UNIQUE NOT NULL,
    email text UNIQUE -- email может быть пустым, но если указан — должен быть уникальным
);

-- Таблица дел
CREATE TABLE cases (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title text NOT NULL,
    description text NOT NULL,
    status text NOT NULL DEFAULT 'Открыто' CHECK (status IN ('Открыто', 'В работе', 'Закрыто успешно', 'Закрыто неудачно')),
    opened_at timestamptz NOT NULL DEFAULT now(),
    closed_at timestamptz,
    client_id integer NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    detective_id integer NOT NULL REFERENCES detectives(id) ON DELETE RESTRICT,
    -- Целостность: дата закрытия не может быть раньше даты открытия
    CHECK (closed_at IS NULL OR closed_at >= opened_at)
);

-- Таблица подозреваемых
CREATE TABLE suspects (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    status text NOT NULL DEFAULT 'Подозреваемый' CHECK (status IN ('Подозреваемый', 'Свидетель', 'Обвиняемый', 'Оправдан')),
    case_id integer NOT NULL REFERENCES cases(id) ON DELETE CASCADE
);

-- Таблица улик
CREATE TABLE evidence (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    description text NOT NULL,
    evidence_type text NOT NULL CHECK (evidence_type IN ('Документ', 'Фотография', 'Видео', 'Аудио', 'Физический объект')),
    collected_at timestamptz NOT NULL DEFAULT now(),
    case_id integer NOT NULL REFERENCES cases(id) ON DELETE CASCADE
);

-- Связующая таблица для допросов (N:M)
CREATE TABLE interrogations (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    detective_id integer NOT NULL REFERENCES detectives(id) ON DELETE RESTRICT,
    suspect_id integer NOT NULL REFERENCES suspects(id) ON DELETE CASCADE,
    case_id integer NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    interrogated_at timestamptz NOT NULL DEFAULT now(),
    summary text,
    -- Один и тот же детектив не может допрашивать одного подозреваемого по одному делу дважды
    UNIQUE (detective_id, suspect_id, case_id)
);