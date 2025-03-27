WITH column_info AS (
    SELECT 
        c.table_schema,
        c.table_name,
        c.column_name,
        c.data_type,
        c.column_default
    FROM information_schema.columns c
    WHERE c.table_schema NOT IN ('pg_catalog', 'information_schema')
),
constraint_info AS (
    SELECT 
        kcu.table_schema,
        kcu.table_name,
        kcu.column_name,
        STRING_AGG(DISTINCT tc.constraint_type, ', ') AS constraint_types,
        STRING_AGG(DISTINCT ccu.column_name, ', ') AS referenced_column_name,
        STRING_AGG(DISTINCT ccu.table_name, ', ') AS referenced_table_name
    FROM information_schema.table_constraints tc
    LEFT JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    LEFT JOIN information_schema.constraint_column_usage ccu 
        ON tc.constraint_name = ccu.constraint_name
    WHERE tc.table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY kcu.table_schema, kcu.table_name, kcu.column_name
),
index_info AS (
    SELECT 
        i.schemaname AS schema_name,
        i.tablename AS table_name,
        a.attname AS column_name,
        STRING_AGG(DISTINCT i.indexname, ', ') AS index_name,
        STRING_AGG(DISTINCT am.amname, ', ') AS index_type
    FROM pg_indexes i
    JOIN pg_class c ON i.indexname = c.relname  
    JOIN pg_index pi ON c.oid = pi.indexrelid  
    JOIN pg_attribute a ON pi.indrelid = a.attrelid AND a.attnum = ANY(pi.indkey)  
    JOIN pg_am am ON c.relam = am.oid  
    WHERE i.schemaname NOT IN ('pg_catalog', 'information_schema')
    GROUP BY i.schemaname, i.tablename, a.attname
)
SELECT 
    col.table_schema AS "Schema Name",  -- Added schema column
    col.table_name AS "Table Name",
    col.column_name AS "Column Name",
    col.data_type AS "Column Type",
    col.column_default AS "Default Value",
    COALESCE(idx.index_name, 'No Index') AS "Index Name",
    COALESCE(idx.index_type, 'No Index') AS "Index Type",
    COALESCE(con.constraint_types, 'No Constraint') AS "Constraint",
    COALESCE(con.referenced_column_name, 'No Reference') AS "Referenced Column Name",
    COALESCE(con.referenced_table_name, 'No Reference') AS "Referenced Table Name"
FROM column_info col
LEFT JOIN constraint_info con 
    ON col.table_schema = con.table_schema
    AND col.table_name = con.table_name
    AND col.column_name = con.column_name
LEFT JOIN index_info idx 
    ON col.table_schema = idx.schema_name
    AND col.table_name = idx.table_name
    AND col.column_name = idx.column_name
ORDER BY col.table_schema, col.table_name, col.column_name;
