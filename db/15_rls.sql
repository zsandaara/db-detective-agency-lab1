ALTER TABLE cases ENABLE ROW LEVEL SECURITY;
CREATE POLICY detective_own_cases ON cases 
FOR ALL TO app_writer 
USING (detective_id = (SELECT id FROM detectives WHERE full_name = session_user));