WITH r AS (SELECT 'role_to_revoke'::text As param_role_name)
SELECT DISTINCT 'REVOKE ALL ON TABLE ' || table_schema || '.' || '"' || table_name || '"' || ' FROM ' || quote_ident(r.param_role_name) || ';' As sql
FROM information_schema.table_privileges CROSS JOIN r
WHERE grantee ~* r.param_role_name
UNION ALL
SELECT DISTINCT 'REVOKE ALL ON ' || schemaname || '.' || '"' || viewname || '"' || ' FROM ' || quote_ident(r.param_role_name) || ';' As sql
FROM pg_catalog.pg_views CROSS JOIN r WHERE schemaname != 'information_schema' AND schemaname !~ E'^pg_'
UNION ALL
SELECT DISTINCT 'REVOKE ALL ON FUNCTION ' || routine_schema || '.' || '"' || routine_name || '"' || '('
    ||  pg_get_function_identity_arguments(
        (regexp_matches(specific_name, E'.*\_([0-9]+)'))[1]::oid) || ') FROM ' || quote_ident(r.param_role_name) || ';' As sql
FROM information_schema.routine_privileges CROSS JOIN r
WHERE grantee ~* r.param_role_name
UNION ALL
SELECT 'REVOKE ALL ON SEQUENCE ' || sequence_schema || '.' || '"' || sequence_name || '"' || ' FROM ' || quote_ident(r.param_role_name) || ';' As sql
FROM information_schema.sequences CROSS JOIN r
UNION ALL
SELECT 'REVOKE ALL ON SCHEMA ' || '"' || schema_name || '"' || ' FROM ' || quote_ident(r.param_role_name) || ';' As sql
FROM  information_schema.schemata s CROSS JOIN r WHERE s.schema_name NOT IN ('information_schema','public') AND s.schema_name !~ E'^pg_'
