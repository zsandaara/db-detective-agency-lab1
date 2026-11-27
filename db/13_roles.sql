-- Читаем пароли из переменных окружения
\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

-- Создаем роли
CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password';

-- Даем права читателю (только представления)
GRANT SELECT ON v_case_details TO app_reader;
GRANT SELECT ON v_interrogation_summary TO app_reader;

-- Запрещаем всё остальное
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

-- Настраиваем writer (может только вызывать функцию)
GRANT EXECUTE ON FUNCTION add_evidence(integer, text, text) TO app_writer;
GRANT USAGE, SELECT ON SEQUENCE evidence_id_seq TO app_writer;