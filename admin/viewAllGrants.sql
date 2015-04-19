CREATE OR REPLACE VIEW view_all_grants AS
SELECT
  use.usename as subject,
  nsp.nspname as namespace,
  c.relname as item, 
  c.relkind as type,
  use2.usename as owner,
  c.relacl,
  (use2.usename != use.usename and c.relacl::text !~ ('({|,)' || use.usename || '=')) as public
FROM
  pg_user use 
  cross join pg_class c
  left join pg_namespace nsp on (c.relnamespace = nsp.oid)
  left join pg_user use2 on (c.relowner = use2.usesysid)
WHERE 
  c.relowner = use.usesysid or 
  c.relacl::text ~ ('({|,)(|' || use.usename || ')=')
ORDER BY
  subject,
  namespace,
  item
;