# Week 7 — Triggers, Recursive CTEs, Migrations, and Security

## Overview

This lab covered four production-grade database practices:

1. **Audit logging with triggers** — automatic change tracking
2. **Recursive CTEs** — querying hierarchical (tree) data
3. **Versioned migrations** — controlled schema evolution with Flyway
4. **Least-privilege security** — roles and grants for fine-grained access

## Step 1 — Audit Log

Created:

- `audit_log` table with `tbl`, `op`, `old_row`, `new_row`, `changed_by`, `at`
- `audit()` trigger function using `to_jsonb(OLD)` / `to_jsonb(NEW)`
- `trg_audit` trigger on `students` for INSERT/UPDATE/DELETE

## Step 2 — Verifying the Audit Log

Ran:

    INSERT INTO students (name, level) VALUES
    ('Kofi Mensah', 'Level 100'),
    ('Ama Boateng', 'Level 200'),
    ('Yaw Darko', 'Level 300');

    UPDATE students SET name = 'Kofi M.' WHERE id = 1;
    DELETE FROM students WHERE id = 3;

Audit query result — 5 rows captured:

| op | was | now |
|---|---|---|
| DELETE | Yaw Darko | (none) |
| UPDATE | Kofi Mensah | Kofi M. |
| INSERT | (none) | Kofi Mensah |
| INSERT | (none) | Ama Boateng |
| INSERT | (none) | Yaw Darko |

The trigger captured every change — no application code needed.

## Step 3 — Category Tree with Recursive CTE

Created a self-referencing `categories` table with `parent_id INT REFERENCES categories(id)`.

Inserted a small hierarchy:

    Electronics
      Computers
        Laptops
      Phones

Used a `WITH RECURSIVE` CTE to walk the tree:

- **Base case:** `WHERE parent_id IS NULL` (roots)
- **Recursive step:** `JOIN tree t ON c.parent_id = t.id`
- **Indentation:** `repeat('  ', depth) || name`

## Step 4 — Versioned Migrations with Flyway

Created three migration files:

- `V1__core_tables.sql` — courses
- `V2__audit_log.sql` — audit_log
- `V3__categories.sql` — categories

Ran:

    flyway -url=jdbc:postgresql://localhost/bootcamp_flyway \
      -user=postgres -password=postgres \
      -locations=filesystem:./migrations migrate

Result: 3 migrations applied successfully.

Verified:

- `flyway info` — all 3 migrations "Success"
- `flyway_schema_history` table — tracks each migration
- `\dt` in bootcamp_flyway — shows courses, audit_log, categories

## Step 5 — Least-Privilege Security

Created:

- `app_read` — SELECT only
- `app_write` — SELECT, INSERT, UPDATE, DELETE
- `api` user — a member of `app_write`

Granted:

    GRANT CONNECT ON DATABASE bootcamp TO app_read, app_write;
    GRANT USAGE ON SCHEMA public TO app_read, app_write;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
    GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA public TO app_write;

Verified with `\dp students`:

- `app_read=r` — read only
- `app_write=arwd` — read + write, no TRUNCATE / REFERENCES / TRIGGER

## Key Takeaways

1. **Triggers** capture every change centrally — no application code required
2. **Recursive CTEs** elegantly walk hierarchical data
3. **Versioned migrations** make schema changes repeatable and auditable
4. **Least privilege** limits the blast radius if credentials leak
5. **Immutable migrations** are a cardinal rule — never edit an applied migration

## Files

- `migrations/` — the three Flyway migration files
- `screenshots/` — evidence of each step
- `README.md` — this file
