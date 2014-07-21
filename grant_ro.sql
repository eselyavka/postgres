WITH r AS (SELECT 'role_to_grant'::text As param_role_name)
SELECT DISTINCT 'GRANT SELECT ON TABLE ' || schemaname || '.' || '"' || tablename || '"' || ' TO ' || quote_ident(r.param_role_name) || ';' As sql
FROM pg_catalog.pg_tables CROSS JOIN r WHERE schemaname != 'information_schema' AND schemaname !~ E'^pg_'
UNION ALL
SELECT DISTINCT 'GRANT SELECT ON ' || schemaname || '.' || '"' || viewname || '"' || ' TO ' || quote_ident(r.param_role_name) || ';' As sql
FROM pg_catalog.pg_views CROSS JOIN r WHERE schemaname != 'information_schema' AND schemaname !~ E'^pg_'
UNION ALL
SELECT DISTINCT 'GRANT EXECUTE ON FUNCTION ' || routine_schema || '.' || '"' || routine_name || '"' || '('
    ||  pg_get_function_identity_arguments(
        (regexp_matches(specific_name, E'.*\_([0-9]+)'))[1]::oid) || ') TO ' || quote_ident(r.param_role_name) || ';' As sql
FROM information_schema.routine_privileges CROSS JOIN r
UNION ALL
SELECT 'GRANT SELECT ON SEQUENCE ' || sequence_schema || '.' || '"' || sequence_name || '"' || ' TO ' || quote_ident(r.param_role_name) || ';' As sql
FROM information_schema.sequences CROSS JOIN r
UNION ALL
SELECT 'GRANT USAGE ON SCHEMA ' || '"' || schema_name || '"' || ' TO ' || quote_ident(r.param_role_name) || ';' As sql
FROM  information_schema.schemata s CROSS JOIN r WHERE s.schema_name NOT IN ('information_schema','public') AND s.schema_name !~ E'^pg_'
