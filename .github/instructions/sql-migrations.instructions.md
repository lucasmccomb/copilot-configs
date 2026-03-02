---
name: 'SQL Migration Standards'
description: 'Conventions for Supabase SQL migration files'
applyTo: '**/migrations/**/*.sql'
---

## Reserved Keywords

Always double-quote these PostgreSQL reserved words when used as identifiers:
`position`, `order`, `user`, `offset`, `limit`, `key`, `value`, `type`, `name`, `check`, `default`, `time`, `index`, `comment`

Example: `"position" integer` not `position integer`

## Idempotent Patterns (REQUIRED)

- Functions: `CREATE OR REPLACE FUNCTION`
- Triggers: `DROP TRIGGER IF EXISTS ... ; CREATE TRIGGER ...`
- Indexes: `CREATE INDEX IF NOT EXISTS`
- Tables: `CREATE TABLE IF NOT EXISTS`
- Columns: `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- Policies: `DROP POLICY IF EXISTS ... ; CREATE POLICY ...`

## Common Gotchas

- `ON CONFLICT` requires a unique constraint on the conflict columns
- `SECURITY DEFINER` functions run as the owner, not the caller
- RLS policies need `USING` (for SELECT/UPDATE/DELETE) and/or `WITH CHECK` (for INSERT/UPDATE)

## Supabase Key Terminology

- **Publishable key** (not "anon key") - client-side, safe to expose
- **Secret key** (not "service_role key") - server-side only, never expose
