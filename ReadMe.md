# PostgreSQL Database Schema Inspection Script

## Overview
This SQL script retrieves detailed schema information for a PostgreSQL database. It provides insights into:
- Table names and column details
- Data types and default values
- Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, etc.)
- Indexes (including index names and types)
- Foreign key references

## Features
✅ **One row per column**: Prevents duplication due to multiple constraints or indexes.  
✅ **Includes index information**: Shows whether a column has an index, its name, and type (BTREE, HASH, etc.).  
✅ **Includes constraints**: Lists PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK constraints.  
✅ **Foreign key tracking**: Displays referenced columns and tables.  
✅ **Excludes system schemas**: Filters out `pg_catalog` and `information_schema`.  

## Query Breakdown
The script consists of three key components:
1. **Column Information (`column_info`)**: Extracts table, column name, data type, and default value.
2. **Constraint Information (`constraint_info`)**: Aggregates constraints and foreign key references.
3. **Index Information (`index_info`)**: Retrieves index names and types for each column.

The final `SELECT` query joins these components to produce a comprehensive schema report.

## Output Format
| Table Name | Column Name | Column Type | Default Value | Index Name | Index Type | Constraint | Referenced Column Name | Referenced Table Name |
|------------|------------|-------------|--------------|------------|------------|------------|----------------------|------------------|
| users      | id         | integer     | nextval('users_id_seq') | users_pkey | btree | PRIMARY KEY | No Reference | No Reference |
| users      | email      | text        | NULL         | users_email_idx | btree | UNIQUE | No Reference | No Reference |
| orders     | id         | integer     | nextval('orders_id_seq') | orders_pkey | btree | PRIMARY KEY | No Reference | No Reference |
| orders     | user_id    | integer     | NULL         | No Index | No Index | FOREIGN KEY | id | users |

## Usage
1. Connect to your PostgreSQL database using `psql` or any SQL client.
2. Run the script to retrieve a detailed schema report.

## Notes
- This script is designed for **PostgreSQL** and may not work in other databases without modification.
- It only includes **user-defined tables** (excluding system tables).

## License
This script is open-source and can be modified as needed. 🚀
