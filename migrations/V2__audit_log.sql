CREATE TABLE audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tbl TEXT,
    op TEXT,
    old_row JSONB,
    new_row JSONB,
    changed_by TEXT DEFAULT current_user,
    at TIMESTAMPTZ DEFAULT now()
);
